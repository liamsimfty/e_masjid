import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final directory = Directory('lib');
  final folderLineCounts = <String, int>{};
  int totalLines = 0;

  final files = directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));

  print('File-wise Dart LOC:\n');

  for (var file in files) {
    final lines = file.readAsLinesSync().length;
    totalLines += lines;

    final relativePath = p.relative(file.path, from: 'lib');
    final firstFolder = relativePath.contains(p.separator)
        ? relativePath.split(p.separator).first
        : '(root)';

    folderLineCounts[firstFolder] = (folderLineCounts[firstFolder] ?? 0) + lines;

    print('  $relativePath: $lines');
  }

  print('\nLine count per folder:');
  folderLineCounts.forEach((folder, lines) {
    print('  $folder: $lines');
  });

  print('\nTotal Dart LOC: $totalLines');
}
