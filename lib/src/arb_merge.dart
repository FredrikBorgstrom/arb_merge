import 'dart:convert';
import 'dart:io';

import 'package:arb_merge/src/file_operations.dart';

import 'options.dart';

/// Result of merging ARB files
class ArbMergeResult {
  /// Map of locale codes to their merged content as JSON strings
  final Map<String, String> mergedFiles;

  /// Map of locale codes to their merged content as Map objects
  final Map<String, Map<String, dynamic>> mergedData;

  /// List of locales that were processed
  List<String> get locales => mergedFiles.keys.toList();

  const ArbMergeResult({
    required this.mergedFiles,
    required this.mergedData,
  });
}

class ArbMerge {
  final Options options;

  const ArbMerge(this.options);

  /// Create an ArbMerge instance with simplified parameters
  ///
  /// [sourceFolders] - List of source folder paths to merge from
  /// [destinationFolder] - Destination folder path (will be created if it doesn't exist)
  /// [filePattern] - File naming pattern, defaults to 'intl_{lang}.arb'
  /// [sortKeys] - Whether to sort keys alphabetically, defaults to true
  /// [verbose] - Whether to enable verbose logging, defaults to false
  factory ArbMerge.create({
    required List<String> sourceFolders,
    required String destinationFolder,
    String filePattern = 'intl_{lang}.arb',
    bool sortKeys = true,
    bool verbose = false,
  }) {
    final options = Options(
      sources: sourceFolders,
      destination: destinationFolder,
      pattern: filePattern,
      sort: sortKeys,
      verbose: verbose,
    );
    return ArbMerge(options);
  }

  /// Merge ARB files and write them to the destination folder
  ///
  /// Returns an [ArbMergeResult] containing the merged content
  Future<ArbMergeResult> run() async {
    final result = await merge();
    await writeFiles(result);
    return result;
  }

  /// Merge ARB files and return the result without writing to files
  ///
  /// This is useful when you want to process the merged content programmatically
  /// without writing files to disk
  Future<ArbMergeResult> merge() async {
    options.validate();

    final files = FileOperations.getMultiFiles(options.sources!).toList();
    final Map<String, Map<String, dynamic>> localeMap = {};

    for (var file in files) {
      final content = await File(file.path).readAsString();
      final Map<String, dynamic> jsonContent = json.decode(content);

      final locale = jsonContent['@@locale'];
      if (locale != null) {
        if (!localeMap.containsKey(locale)) {
          localeMap[locale] = {};
        }
        localeMap[locale]?.addAll(jsonContent);
      }
    }

    const encoder = JsonEncoder.withIndent('  ');
    final sortedLocaleKeys = localeMap.keys.toList()..sort();
    final Map<String, String> mergedFiles = {};
    final Map<String, Map<String, dynamic>> mergedData = {};

    for (var locale in sortedLocaleKeys) {
      var langContent = localeMap[locale];
      if (options.sort) {
        if (options.verbose) print('sorting $locale');
        langContent = sortArbKeys(langContent!);
      }
      mergedData[locale] = Map<String, dynamic>.from(langContent!);
      mergedFiles[locale] = encoder.convert(langContent);
    }

    return ArbMergeResult(
      mergedFiles: mergedFiles,
      mergedData: mergedData,
    );
  }

  /// Write the merged files to the destination folder
  ///
  /// [result] - The result from calling [merge()]
  Future<void> writeFiles(ArbMergeResult result) async {
    // Ensure destination exists (this is handled in options.validate())
    if (options.destination == null) {
      throw ArgumentError(
          'Destination folder cannot be null when writing files');
    }

    for (var locale in result.locales) {
      final fileName = options.pattern.replaceAll('{lang}', locale);
      final content = result.mergedFiles[locale]!;
      FileOperations.write(options.destination!, fileName, content);
    }
  }

  /// Get merged content for a specific locale
  ///
  /// [locale] - The locale code (e.g., 'en', 'fr')
  /// Returns the merged content as a Map, or null if the locale doesn't exist
  Future<Map<String, dynamic>?> getMergedContentForLocale(String locale) async {
    final result = await merge();
    return result.mergedData[locale];
  }

  /// Get all available locales from the source folders
  ///
  /// Returns a list of locale codes found in the source files
  Future<List<String>> getAvailableLocales() async {
    final result = await merge();
    return result.locales;
  }

  /// Sort ARB keys alphabetically, keeping metadata keys with their associated keys
  Map<String, dynamic> sortArbKeys(Map<String, dynamic> arb) {
    return Map.fromEntries(
      arb.entries.toList()
        ..sort((a, b) {
          final keyA = a.key.startsWith("@") ? a.key.substring(1) : a.key;
          final keyB = b.key.startsWith("@") ? b.key.substring(1) : b.key;
          return keyA.compareTo(keyB);
        }),
    );
  }
}

/* main(List<String> args) {
  const options = Options(
      source: '/Volumes/WD_SN770_2TB/Github/abcx3_flutter/lib/l10n_static',
      secondarySource:
          '/Volumes/WD_SN770_2TB/Github/abcx3_flutter/lib/l10n_auto_translate',
      destination: '/Volumes/WD_SN770_2TB/Github/abcx3_flutter/lib/l10n',
      fileTemplate: "intl_{lang}.arb");
  const arbMerge = ArbMerge(options);
  arbMerge.run();
} */
