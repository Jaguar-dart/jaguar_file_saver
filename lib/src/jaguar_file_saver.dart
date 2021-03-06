// Copyright (c) 2016, Ravi Teja Gudapati. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library jaguar_file_saver;

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;

part 'interceptor.dart';

/// File saver
class FileSaver {
  /// Base path where all the files are stored
  final String basePath;

  /// Prefixes to the base path
  final List<String> _prefixParts = [];

  /// Prefixes to the base path
  List<String> get prefixParts => _prefixParts;

  FileSaver(this.basePath, {List<String> prefixParts: const <String>[]}) {
    if (prefixParts is List<String>) {
      _prefixParts.addAll(prefixParts);
    }
  }

  /// Makes path from parts and filename
  Future<String> _makePath(List<String> parts, String fileName) async {
    p.Context context = new p.Context(style: p.Style.platform);

    String middlePre = context.joinAll(_prefixParts);
    String middlePost = context.joinAll(parts);

    String withoutFileName =
        context.join(basePath ?? '', middlePre, middlePost);

    Directory dir = new Directory(withoutFileName);
    await dir.create(recursive: true);

    return context.join(withoutFileName, fileName);
  }

  /// Prelog to saving files
  ///
  /// It checks if the destination file exists
  Future<String> _prelog(List<String> parts, String fileName,
      {bool overwrite: true}) async {
    final String path = await _makePath(parts, fileName);

    final File dst = new File(path);
    if (await dst.exists()) {
      if (overwrite) {
        await dst.delete(recursive: true);
      } else {
        throw new FileAlreadyExistsException(path);
      }
    }

    return path;
  }

  /// Moves file
  Future<String> saveFile(List<String> parts, String fileName, File file,
      {bool overwrite: true}) async {
    final String path = await _prelog(parts, fileName, overwrite: overwrite);
    await file.rename(path);
    return path;
  }

  /// Copies file
  Future<String> copyFile(List<String> parts, String fileName, File file,
      {bool overwrite: true}) async {
    final String path = await _prelog(parts, fileName, overwrite: overwrite);
    await file.copy(path);
    return path;
  }

  /// Saves streams
  Future<String> saveStream(
      List<String> parts, String fileName, Stream<List<int>> stream,
      {bool overwrite: true}) async {
    final String path = await _prelog(parts, fileName, overwrite: overwrite);

    File dst = new File(path);
    await dst.openWrite(mode: FileMode.WRITE_ONLY);
    await for (List<int> data in stream) {
      await dst.writeAsBytes(data);
    }
    return path;
  }
}

/// Exception thrown when the file already exists
class FileAlreadyExistsException {
  /// Path of the file
  final String path;

  FileAlreadyExistsException(this.path);

  String toString() {
    return "Such file already exists: $path!";
  }
}
