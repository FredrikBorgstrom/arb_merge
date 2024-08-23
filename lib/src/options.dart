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
    final sourceArg = map['sources'].split(',');
    final src = sourceArg is Iterable ? sourceArg.cast<String>() : <String>[];
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
    if (sources == null) {
      throw ArgumentError('The source folders cannot be null.');
    }
    if (destination == null) {
      throw ArgumentError('The destination folder cannot be null.');
    }
    /* String? error = _verifyFolder(sources!);
    if (error != null) {
      throw ArgumentError('The source $error');
    } */

    String? error = _verifyFolder(destination!);
    if (error != null) {
      throw ArgumentError('The destination $error');
    }
  }

  String? _verifyFolder(String folder) {
    if (folder.isEmpty) {
      return 'folder cannot be empty.';
    }

    if (!Directory(folder).existsSync()) {
      return 'folder does not exist.';
    }
    return null;
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
