import 'package:flutter/material.dart';
import 'package:tts_sarvam_test_app/core/di/injection_container.dart' as di;
import 'package:tts_sarvam_test_app/presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
