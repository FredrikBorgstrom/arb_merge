import 'package:arb_merge/arb_merge.dart';

/// Example demonstrating how to use arb_merge as a library
Future<void> main() async {
  print('=== ARB Merge Library Usage Examples ===\n');

  // Example 1: Simple usage with the factory constructor
  await example1_simpleUsage();

  // Example 2: Merge without writing files
  await example2_mergeOnly();

  // Example 3: Get content for specific locale
  await example3_specificLocale();

  // Example 4: Get available locales
  await example4_availableLocales();

  // Example 5: Advanced usage with custom options
  await example5_advancedUsage();
}

/// Example 1: Simple usage - merge and write files
Future<void> example1_simpleUsage() async {
  print('--- Example 1: Simple Usage ---');

  try {
    // Create merger with simple factory method
    final merger = ArbMerge.create(
      sourceFolders: ['primarySource', 'secondarySource'],
      destinationFolder: 'output',
      filePattern: 'app_{lang}.arb',
      sortKeys: true,
      verbose: true,
    );

    // Merge and write files
    final result = await merger.run();

    print(
        '✅ Successfully merged ${result.locales.length} locales: ${result.locales.join(', ')}');
    print('📁 Files written to: output/\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }
}

/// Example 2: Merge without writing files (useful for processing)
Future<void> example2_mergeOnly() async {
  print('--- Example 2: Merge Only (No File Writing) ---');

  try {
    final merger = ArbMerge.create(
      sourceFolders: ['primarySource', 'secondarySource'],
      destinationFolder: 'temp', // Not used since we're not writing
      sortKeys: false,
    );

    // Just merge, don't write files
    final result = await merger.merge();

    print('✅ Merged content for ${result.locales.length} locales');

    // Process the merged data
    for (final locale in result.locales) {
      final data = result.mergedData[locale]!;
      final keyCount = data.keys.where((key) => !key.startsWith('@')).length;
      print('  📝 $locale: $keyCount translation keys');
    }
    print('');
  } catch (e) {
    print('❌ Error: $e\n');
  }
}

/// Example 3: Get content for a specific locale
Future<void> example3_specificLocale() async {
  print('--- Example 3: Get Specific Locale Content ---');

  try {
    final merger = ArbMerge.create(
      sourceFolders: ['primarySource', 'secondarySource'],
      destinationFolder: 'temp',
    );

    // Get content for English locale
    final englishContent = await merger.getMergedContentForLocale('en');

    if (englishContent != null) {
      print('✅ English content retrieved');
      print(
          '📊 Keys found: ${englishContent.keys.where((k) => !k.startsWith('@')).length}');

      // Example: Access specific translations
      if (englishContent.containsKey('hello')) {
        print('👋 Hello translation: ${englishContent['hello']}');
      }
    } else {
      print('❌ English locale not found');
    }
    print('');
  } catch (e) {
    print('❌ Error: $e\n');
  }
}

/// Example 4: Get all available locales
Future<void> example4_availableLocales() async {
  print('--- Example 4: Available Locales ---');

  try {
    final merger = ArbMerge.create(
      sourceFolders: ['primarySource', 'secondarySource'],
      destinationFolder: 'temp',
    );

    final locales = await merger.getAvailableLocales();

    print('✅ Found ${locales.length} locales:');
    for (final locale in locales) {
      print('  🌍 $locale');
    }
    print('');
  } catch (e) {
    print('❌ Error: $e\n');
  }
}

/// Example 5: Advanced usage with custom Options
Future<void> example5_advancedUsage() async {
  print('--- Example 5: Advanced Usage with Custom Options ---');

  try {
    // Create custom options
    final options = Options(
      sources: ['primarySource', 'secondarySource'],
      destination: 'advanced_output',
      pattern: 'translations_{lang}.json', // Custom pattern
      sort: true,
      verbose: false,
    );

    final merger = ArbMerge(options);

    // First, just merge to inspect the data
    final result = await merger.merge();

    print('✅ Merged ${result.locales.length} locales');

    // Custom processing: filter out metadata keys and count translations
    for (final locale in result.locales) {
      final data = result.mergedData[locale]!;
      final translationKeys =
          data.keys.where((key) => !key.startsWith('@')).toList();

      print('  📋 $locale: ${translationKeys.length} translations');

      // Example: Find keys that might need attention (empty values)
      final emptyKeys = translationKeys
          .where((key) => data[key] is String && (data[key] as String).isEmpty)
          .toList();

      if (emptyKeys.isNotEmpty) {
        print('    ⚠️  Empty translations: ${emptyKeys.join(', ')}');
      }
    }

    // Write the files
    await merger.writeFiles(result);
    print('📁 Files written with custom pattern\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }
}
