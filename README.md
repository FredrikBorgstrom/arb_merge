# ARB Merge

ARB Merge merges translation files from multiple folders of any structure and depth.
What sets this package apart from other merging packages is that it merges the content of files
based on the @@locale language code instead of using imposed file or folder naming conventions or imposed structures.
It can also take an arbitrary number of source folders by using a comma separated string of paths,
and each one of these folders will be recursed through so files can be nested to any depth.

**✨ New in v1.1.0**: Now works both as a command-line tool AND as a library with a clean API!

## Background

I created this package because I couldn't find a package that supported multiple input folders (with different paths).
I have one folder with small translation files that are continuously updated and automatically translated by Google,
and I have another folder with large translation files that don't auto-translate.
So basically it was an economic incentive to develop this package because Google had started to charge me for
translating those large monolithic files

## Credits and Copyright
This package is based on the excellent [arb_glue] package by Shueh Chou Lu, but I needed some other
features so I modified his code, made some additions and created this package.


Features:

-   Supports [JSON] and [ARB] source files
-   Supports unlimited nesting, arbitrary file and folder naming convention
-   Supports unlimited* source folders
-   The translation keys of the merged files can, if so desired, be sorted alphabetically
-   Supports optional verbose output for debugging purposes
-   **NEW**: Library API for programmatic usage
-   **NEW**: Automatic creation of destination directories

* limited by your command line's input buffer

## Installation

```shell
flutter pub add dev:arb_merge
```

Or add dependencies to `pubspec.yaml`:

```yaml
dev_dependencies:
  arb_merge: *
```

## Usage

### Command Line Usage

inline command options:

`--sources`
A comma separated string with all the paths of the folders you would like to merge files from.

Example:
```shell
dart run arb_merge --sources intl_autoTranslated,intl_static,assets/manual_translations --destination lib/intl
```

`--destination`
The path of the destination folder for the merged files (will be created automatically if it doesn't exist)

`--pattern`
A string that will be used to name the created files where `{lang}` will be replaced by the language code.
Default value: `intl_{lang}.arg` which will render the file name `intl_en.arb` for english 

`--verbose` 
Setting verbose will output details on the files processed, default value: false

`--sort`
Will sort the keys in each output file alphabetically, default value: false

```shell
dart run arb_glue --
# or
flutter pub run arb_glue
```

You can also set all the options' values in your pubspec.yaml file,
and then simply run `dart run arb_merge` to run arb_merge with the values from pubspec.
Please not that any options set on the command line will then override those values.

```yaml
arb_merge:
  sources: example/primarySource,example/secondarySource
  destination: example/merged
  sort: false
  pattern: 'intl_{lang}.arb'
  verbose: false
```

### Library API Usage

You can now use arb_merge programmatically in your Dart/Flutter applications:

#### Simple Usage

```dart
import 'package:arb_merge/arb_merge.dart';

Future<void> main() async {
  // Create merger with simple factory method
  final merger = ArbMerge.create(
    sourceFolders: ['lib/l10n/manual', 'lib/l10n/auto'],
    destinationFolder: 'lib/l10n/merged',
    filePattern: 'app_{lang}.arb',
    sortKeys: true,
    verbose: true,
  );

  // Merge and write files
  final result = await merger.run();
  
  print('Merged ${result.locales.length} locales: ${result.locales.join(', ')}');
}
```

#### Advanced Usage - Merge Without Writing Files

```dart
import 'package:arb_merge/arb_merge.dart';

Future<void> processTranslations() async {
  final merger = ArbMerge.create(
    sourceFolders: ['translations/base', 'translations/overrides'],
    destinationFolder: 'output', // Not used when only merging
  );

  // Just merge, don't write files
  final result = await merger.merge();
  
  // Process the merged data programmatically
  for (final locale in result.locales) {
    final data = result.mergedData[locale]!;
    final translationCount = data.keys.where((key) => !key.startsWith('@')).length;
    print('$locale: $translationCount translations');
    
    // Access specific translations
    if (data.containsKey('welcome_message')) {
      print('Welcome message in $locale: ${data['welcome_message']}');
    }
  }
  
  // Optionally write files later with custom logic
  await merger.writeFiles(result);
}
```

#### Get Content for Specific Locale

```dart
Future<void> getEnglishTranslations() async {
  final merger = ArbMerge.create(
    sourceFolders: ['translations/en'],
    destinationFolder: 'temp',
  );

  final englishContent = await merger.getMergedContentForLocale('en');
  
  if (englishContent != null) {
    // Use the English translations in your app
    final welcomeMessage = englishContent['welcome'] ?? 'Welcome!';
    print(welcomeMessage);
  }
}
```

#### Check Available Locales

```dart
Future<List<String>> getAvailableLanguages() async {
  final merger = ArbMerge.create(
    sourceFolders: ['assets/translations'],
    destinationFolder: 'temp',
  );

  return await merger.getAvailableLocales();
}
```

#### API Reference

**Classes:**

- `ArbMerge` - Main class for merging ARB files
- `ArbMergeResult` - Contains the results of a merge operation
- `Options` - Configuration options (for advanced usage)

**ArbMerge Methods:**

- `ArbMerge.create()` - Factory constructor with simplified parameters
- `run()` - Merge files and write to destination
- `merge()` - Merge files without writing (returns `ArbMergeResult`)
- `writeFiles(result)` - Write merged files to destination
- `getMergedContentForLocale(locale)` - Get content for specific locale
- `getAvailableLocales()` - Get list of available locale codes

**ArbMergeResult Properties:**

- `mergedFiles` - Map of locale codes to JSON strings
- `mergedData` - Map of locale codes to Map objects
- `locales` - List of processed locale codes

## Supported formats

arb_merge supports JSON and ARB files.


[ARB]: https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification
[arb_glue]: https://github.com/evan361425/flutter-arb-glue
