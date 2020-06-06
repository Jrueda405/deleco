import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<Directory> getPath()async {
  return await getExternalStorageDirectory();
}