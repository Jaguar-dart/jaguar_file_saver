// Copyright (c) 2016, Ravi Teja Gudapati. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:jaguar_file_saver/jaguar_file_saver.dart';
import 'package:test/test.dart';
import 'package:path/path.dart';

void main() {
  group('A group of tests', () {
    File file;
    Directory baseDir;

    setUp(() async {
      baseDir = await Directory.systemTemp.createTemp('jaguar_file_saver');
      Context ctx = new Context(style: Style.platform);
      String tmpPath = ctx.join(baseDir.path, 'tmp.txt');
      file = new File(tmpPath);
      await file.writeAsString('hello buddy!');
    });

    tearDown(() async {
      await baseDir.delete(recursive: true);
    });

    test('SaveFile with no parts', () async {
      FileSaver saver = new FileSaver(baseDir.path);
      String dst = await saver.saveFile([], 'teja.txt', file);

      File dstFile = new File(dst);

      expect(file.existsSync(), isFalse);
      expect(dstFile.existsSync(), isTrue);
    });

    test('Save file with parts', () async {
      FileSaver saver = new FileSaver(baseDir.path);
      String dst = await saver.saveFile(['teja', 'profile'], 'teja.txt', file);

      File dstFile = new File(dst);

      expect(file.existsSync(), isFalse);
      expect(dstFile.existsSync(), isTrue);
    });

    test('No overwrite exception', () async {
      FileSaver saver = new FileSaver(baseDir.path);

      {
        await saver.copyFile(['teja', 'profile'], 'teja.txt', file);
      }

      dynamic exception;
      try {
        await saver
            .saveFile(['teja', 'profile'], 'teja.txt', file, overwrite: false);
      } catch (e) {
        exception = e;
      }

      expect(exception, new isInstanceOf<FileAlreadyExistsException>());
    });
  });
}
