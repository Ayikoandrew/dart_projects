import 'dart:io';
import 'dart:convert';

import 'package:args/args.dart';

const countLine = 'line-count';

void main(List<String> arguments) {
  exitCode = 0;

  final parser = ArgParser()..addFlag(countLine, negatable: false, abbr: 'n');

  ArgResults argResults = parser.parse(arguments);

  final paths = argResults.rest;

  dcat(paths, showNumberLine: argResults[countLine] as bool);
}

Future<void> dcat(List<String> paths, {bool showNumberLine = true}) async{
  if (paths.isEmpty) {
    await stdin.pipe(stdout);
  } else {
    for (var path in paths) {
      var lineNumber = 1;
      var lines = utf8.decoder.bind(File(path).openRead()).transform(const LineSplitter());

      try {
        await for (var line in lines) {
          if (showNumberLine) {
            stdout.write('${lineNumber++ }');
          }
          stdout.writeln(line);
        }
      } catch (_) {
        return _handleError(path);
      }
    }
  }
}

Future<void> _handleError(String path) async{
  if (await FileSystemEntity.isDirectory(path)) {
    stderr.write('error: $path is a directory');
  } else {
    exitCode = 2;
  }
}
