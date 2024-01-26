import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fast_menu/common/index.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';

void main() async {
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(400, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  Get.put(ConfigService());
  await Get.find<ConfigService>().init();
  runApp(const MyApp());
}
