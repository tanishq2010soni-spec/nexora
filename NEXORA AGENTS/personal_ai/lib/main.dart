import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      title: 'Personal AI',
      size: Size(1280, 800),
      minimumSize: Size(900, 600),
      center: true,
      backgroundColor: Color(0xFF0f0f1a),
      skipTaskbar: false,
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );

  runApp(PersonalAIApp());
}
