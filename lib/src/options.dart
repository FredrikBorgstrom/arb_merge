import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';

/// The available options
class Options {
  /// The source folders
  final List<String>? sources;

  /// The destination folder where the merged files will be stored
  final String? destination;

  /// Whether to sort the keys in the output arb file or leave them in their merged order, defaults to true
  final bool sort;

  /// The file naming pattern for the output arb file, "{lang}" will be replaced by the language code
  final String pattern;

  /// Whether to print verbose output
  final bool verbose;

  const Options({
    required this.sources,
    required this.destination,
    this.sort = true,
    this.pattern = '{lang}.arb',
    this.verbose = false,
  });

  static Map<String, dynamic> createDefaultValues(Map<String, dynamic> map) {
    // Handle sources with null safety
    final sourcesValue = map['sources'];
    final List<String> src;
    if (sourcesValue is String && sourcesValue.isNotEmpty) {
      final sourceArg = sourcesValue.split(',');
      src = sourceArg.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    } else if (sourcesValue is List) {
      src = sourcesValue.cast<String>();
    } else {
      src = <String>[];
    }

    final dst = map['destination'] is String ? map['destination'] : null;
    final sort = map['sort'] is bool ? map['sort'] : false;
    final pattern =
        map['pattern'] is String ? map['pattern'] : 'intl_{lang}.arb';
    final verbose = map['verbose'] is bool ? map['verbose'] : false;

    return {
      'sources': src,
      'destination': dst,
      'sort': sort,
      'pattern': pattern,
      'verbose': verbose,
    };
  }

  static ArgParser createArgParser(Map<String, dynamic> defaultValues) {
    final parser = ArgParser()
      ..addMultiOption('sources',
          abbr: 's', defaultsTo: defaultValues['sources'])
      ..addOption('destination',
          abbr: 'd', defaultsTo: defaultValues['destination'])
      ..addFlag('sort', abbr: 'o', defaultsTo: defaultValues['sort'])
      // ..addFlag('sort', abbr: 'o', defaultsTo: false)
      ..addOption('pattern', abbr: 'p', defaultsTo: defaultValues['pattern'])
      ..addFlag('verbose', abbr: 'v', defaultsTo: defaultValues['verbose']);

    return parser;
  }

  factory Options.fromArgsAndPubSpec(
      List<String> args, Map<String, dynamic> mapFromPubSpec) {
    final defaultValues = createDefaultValues(mapFromPubSpec);
    final parser = createArgParser(defaultValues);
    final parsed = parser.parse(args);
    print('parsed sort: ${parsed['sort']}');
    print('parsed verbose: ${parsed['verbose']}');
    final options = Options(
      sources: parsed['sources'],
      destination: parsed['destination'],
      sort: parsed['sort'],
      pattern: parsed['pattern'],
      verbose: parsed['verbose'],
    );

    Logger.root.level = options.verbose ? Level.ALL : Level.WARNING;
    // ignore: avoid_print
    Logger.root.onRecord.listen((record) => print(record.message));
    Logger.root
        .info(parsed.options.map((key) => '$key: ${parsed[key]}').join('\n'));
    return options;
  }

  void validate() {
    if (sources == null || sources!.isEmpty) {
      throw ArgumentError(
          'Source folders are required. Please specify source folders using --sources or -s.\n'
          'Example: --sources lib/l10n_cache,lib/l10n_output');
    }

    if (destination == null || destination!.isEmpty) {
      throw ArgumentError(
          'Destination folder is required. Please specify a destination folder using --destination or -d.\n'
          'Example: --destination lib/l10n');
    }

    // Validate that source folders exist
    for (final source in sources!) {
      final sourceDir = Directory(source);
      if (!sourceDir.existsSync()) {
        throw ArgumentError(
            'Source folder "$source" does not exist. Please check the path and try again.');
      }
    }

    // Create destination directory if it doesn't exist
    _ensureDestinationExists(destination!);
  }

  void _ensureDestinationExists(String folder) {
    if (folder.isEmpty) {
      throw ArgumentError(
          'Destination folder path cannot be empty. Please provide a valid folder path.');
    }

    final directory = Directory(folder);
    if (!directory.existsSync()) {
      try {
        directory.createSync(recursive: true);
        Logger.root.info('Created destination directory: $folder');
      } catch (e) {
        throw ArgumentError('Failed to create destination directory "$folder". '
            'Please check that you have write permissions and the path is valid.\n'
            'Error details: $e');
      }
    }
  }
}

/* static ArgParser getArgParser(Map<String, dynamic> map) {
    final sourceArg = map['sources'].split(',');
    final src = sourceArg is Iterable ? sourceArg.cast<String>() : <String>[];
    final sort = map['sort'] is bool ? map['sort'] : false;
    final dst = map['destination'] is String ? map['destination'] : null;
    final pattern =
        map['pattern'] is String ? map['pattern'] : 'intl_{lang}.arb';
    final verbose = map['verbose'] is bool ? map['verbose'] : false;

    final parser = ArgParser()
      ..addMultiOption('sources', abbr: 's', defaultsTo: src)
      ..addOption('destination', abbr: 'd', defaultsTo: dst)
      ..addFlag('sort', abbr: 'o', defaultsTo: sort)
      ..addOption('pattern', abbr: 'p', defaultsTo: pattern)
      ..addFlag('verbose', abbr: 'v', defaultsTo: verbose);

    return parser;
  } */
