// Copyright (c) 2016, Ravi Teja Gudapati. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:jaguar_file_saver/jaguar_file_saver.dart';
import 'dart:io';
import 'package:path/path.dart';

main() async {
  Directory baseDir = await Directory.systemTemp.createTemp('jaguar_file_saver');

  Context ctx = new Context(style: Style.platform);
  String tmpPath = ctx.join(baseDir.path, 'tmp.txt');
  File file = new File(tmpPath);
  await file.writeAsString('hello buddy!');

  FileSaver saver = new FileSaver(baseDir.path);
  String dst = await saver.saveFile(['teja', 'profile'], 'teja.txt', file);

  print(dst);
}
