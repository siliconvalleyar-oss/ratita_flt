import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ratita_runner/game/screens/game_screen.dart';
import 'package:ratita_runner/game/systems/audio_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await AudioSystem.init();

  runApp(const RatitaApp());
}

class RatitaApp extends StatelessWidget {
  const RatitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ratita Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFF87CEEB),
      ),
      home: const GameScreen(),
    );
  }
}
