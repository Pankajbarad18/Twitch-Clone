import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:twitch_clone/screens/feed_screen.dart';
import 'package:twitch_clone/screens/go_live_screen.dart';

const buttonColor = Color.fromRGBO(145, 71, 255, 1);
const backgroundColor = Colors.white;
const secondaryBackgroundColor = Color.fromRGBO(239, 239, 241, 1);
const primaryColor = Colors.black;

List<Widget> pages = [
  const FeedScreen(),
  const GoLiveScreen(),
  const Center(
    child: Text('Browse'),
  )
];

Future<Uint8List?> pickImage() async {
  FilePickerResult? pickedImage =
      await FilePicker.platform.pickFiles(type: FileType.image);
  if (pickedImage != null) {
    if (kIsWeb) {
      return pickedImage.files.single.bytes;
    }
    return await File(pickedImage.files.single.path!).readAsBytes();
  }
  return null;
}

const String appId = '52dc4e0ba1cc4900860eaa7019738675';
