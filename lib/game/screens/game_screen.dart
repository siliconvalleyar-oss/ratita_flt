import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart' show GameWidget;
import 'package:ratita_runner/game/ratita_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final RatitaGame _game;

  @override
  void initState() {
    super.initState();
    _game = RatitaGame();
    _game.onStateChanged = () {
      if (mounted) setState(() {});
    };
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _game.onRemove();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _game.pauseEngine();
    } else if (state == AppLifecycleState.resumed) {
      _game.resumeEngine();
    }
  }

  void _startGame() {
    setState(() => _game.startGame());
  }

  void _goToMenu() {
    setState(() => _game.goToMenu());
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      if (_game.isPlaying) {
        _game.handleTap();
        return KeyEventResult.handled;
      } else if (_game.isMenu) {
        _startGame();
        return KeyEventResult.handled;
      } else if (_game.isGameOver) {
        _startGame();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final gameWidget = GameWidget(
      game: _game,
      loadingBuilder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final gameWithTap = Listener(
      onPointerDown: (_) {
        if (_game.isPlaying) _game.handleTap();
      },
      child: gameWidget,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      body: SafeArea(
        child: KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: _handleKeyEvent,
          child: Stack(
            children: [
              gameWithTap,
              if (_game.isMenu) _buildMenuOverlay(),
              if (_game.isGameOver) _buildGameOverOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOverlay() {
    return Container(
      color: const Color(0xCC87CEEB),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ratita/ratita_brazo_abierto.png',
              height: 130,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(height: 130),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ratita Runner',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B4226),
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Campo La Juanita',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2E7D32),
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '¡Salta con ESPACIO o TAP!',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8B7355),
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4226),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              child: const Text('JUGAR'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: const Color(0xCC87CEEB),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFFCC0000),
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Image.asset(
              'assets/images/ratita/ratita_brazo_cruzado.png',
              height: 110,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(height: 110),
            ),
            const SizedBox(height: 16),
            Text(
              'Puntaje: ${_game.scoreSystem.score}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B4226),
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Record: ${_game.scoreSystem.highScore}',
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF8B7355),
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4226),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              child: const Text('REINICIAR'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _goToMenu,
              child: const Text(
                'MENU PRINCIPAL',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8B7355),
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
