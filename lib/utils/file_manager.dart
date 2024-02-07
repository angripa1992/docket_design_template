import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class FileManager {
  static final _instance = FileManager.internal();

  factory FileManager() => _instance;

  FileManager.internal();

  Future<File> createFile() async {
    var epoch = DateTime.now().millisecondsSinceEpoch;
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/pos_$epoch.pdf');
    return file;
  }

  Future<void> writeToFile({
    required File file,
    required Uint8List bytesData,
  }) async {
    await file.writeAsBytes(bytesData);
  }

  Future<void> deleteFile(File file) async {
    try {
      await file.delete();
    } catch (e) {
      //ignored
    }
  }
}
