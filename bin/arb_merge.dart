import 'dart:io';

import 'package:arb_merge/arb_merge.dart';
import 'package:arb_merge/src/yaml.dart';

const version = '1.2.1';

Future<void> main(List<String> inlineArgs) async {
  if (inlineArgs.contains('--help') ||
      inlineArgs.contains('-h') ||
      inlineArgs.isEmpty) {
    _printUsage();
    return;
  }

  if (inlineArgs.contains('--version')) {
    // ignore: avoid_print
    print('arb_merge: $version');
    return;
  }

  try {
    final argsFromPubspec = _loadPubSpec();
    final options = Options.fromArgsAndPubSpec(inlineArgs, argsFromPubspec);

    await ArbMerge(options).run();
  } catch (e) {
    if (e is ArgumentError) {
      // ignore: avoid_print
      print('Error: ${e.message}');
      // ignore: avoid_print
      print('');
      _printUsage();
      exit(1);
    } else {
      // ignore: avoid_print
      print('Unexpected error: $e');
      exit(1);
    }
  }
}

void _printUsage() {
  final argParser =
      Options.createArgParser(Options.createDefaultValues(_loadPubSpec()));
  // ignore: avoid_print
  print([
    'arb_merge: Merge ARB files from multiple source folders.',
    '',
    'Usage: dart run arb_merge [options]',
    '',
    'Required options:',
    '  --sources, -s     Comma-separated list of source folders to merge from',
    '  --destination, -d Destination folder where merged files will be written',
    '',
    'Optional options:',
    '  --pattern, -p     File naming pattern (default: intl_{lang}.arb)',
    '  --sort, -o        Sort keys alphabetically (default: false)',
    '  --verbose, -v     Enable verbose output (default: false)',
    '',
    'Examples:',
    '  dart run arb_merge --sources lib/l10n_cache,lib/l10n_output --destination lib/l10n',
    '  dart run arb_merge -s source1,source2 -d output --pattern {lang}.arb --sort',
    '',
    'All options:',
    argParser.usage,
  ].join('\n'));
}

Map<String, dynamic> _loadPubSpec() {
  const loader = YamlLoader();
  final content = File('pubspec.yaml').readAsStringSync();
  final val = loader.loadContent(content)['arb_merge'];

  if (val is Map<String, dynamic>) {
    return val;
  }

  return const <String, dynamic>{};
}
