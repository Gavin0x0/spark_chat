import 'package:flutter/material.dart';
import 'package:spark_chat/common/index.dart';
import 'package:get/get.dart';
import 'app.dart';

void main() async {
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  Get.put(ConfigService());
  await Get.find<ConfigService>().init();
  runApp(const MyApp());
}
