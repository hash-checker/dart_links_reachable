import 'dart:io';

import 'package:http/http.dart';

Future<void> check(String path) async {
  final links = <String>{};
  await _findLinks(path, links);
  bool canExitWithNormalStatus = true;
  for (final link in links) {
    final res = await get(Uri.parse(link));
    if (res.statusCode == HttpStatus.ok) {
      print('DONE: $link');
      await Future.delayed(const Duration(microseconds: 500));
    } else {
      print('ERROR: $link (${res.statusCode})');
      canExitWithNormalStatus = false;
    }
  }
  if (!canExitWithNormalStatus) {
    exit(-1);
  }
}

Future<void> _findLinks(String path, Set<String> links) async {
  final dir = Directory(path);
  for (final el in dir.listSync(recursive: true)) {
    if (el is File) {
      final lines = el.readAsLinesSync();
      for (final line in lines) {
        RegExp exp = RegExp(r'https://?[\w/\-?=%.]+\.[\w/\-?=%.]+');
        final matches = exp.allMatches(line);
        for (final match in matches) {
          links.add(line.substring(match.start, match.end));
        }
      }
    } else if (el is Directory) {
      await _findLinks(el.path, links);
    }
  }
}
