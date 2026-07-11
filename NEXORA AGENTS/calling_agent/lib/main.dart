import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setSize(const Size(1280, 800));
    await windowManager.setMinimumSize(const Size(900, 600));
    await windowManager.center();
    await windowManager.show();
    await windowManager.setPreventClose(true);
  });
  runApp(const CallingAgentApp());
}
