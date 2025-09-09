import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/upload_file_model.dart';

extension UploadFileUtils on UploadFile{
  Future<bool> isFileDownloadedLocally() async{
    final dir = await getApplicationDocumentsDirectory();
    // final path = '${dir.path}/$name';
    final path = '/storage/emulated/0/Download/$name'; // Same as above
    return File(path).exists();
  }
}
