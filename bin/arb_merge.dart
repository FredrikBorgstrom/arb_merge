import 'dart:io';

import 'package:arb_merge/arb_merge.dart';
import 'package:arb_merge/src/yaml.dart';

const version = '1.2.1';

Future<void> main(List<String> inlineArgs) async {
  if (inlineArgs.contains('--help') || inlineArgs.contains('-h')) {
    final argParser =
        Options.createArgParser(Options.createDefaultValues(_loadPubSpec()));
    // ignore: avoid_print
    print([
      'arb_glue: Generate arb files from the source folder.',
      '',
      'Usage: arb_glue [options]',
      '',
      'Options:',
      argParser.usage,
    ].join('\n'));
    return;
  }

  if (inlineArgs.contains('--version')) {
    // ignore: avoid_print
    print('arb_glue: $version');
    return;
  }
  final argsFromPubspec = _loadPubSpec();
  final options = Options.fromArgsAndPubSpec(inlineArgs, argsFromPubspec);

  ArbMerge(options).run();
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
