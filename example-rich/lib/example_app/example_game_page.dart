import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'example_app_controller.dart';
import 'example_app_widgets.dart';

enum _ExampleMiniGame { pulseSprint, beatBridge, laneDash }

extension on _ExampleMiniGame {
  String get title {
    switch (this) {
      case _ExampleMiniGame.pulseSprint:
        return 'Pulse Sprint';
      case _ExampleMiniGame.beatBridge:
        return 'Beat Bridge';
      case _ExampleMiniGame.laneDash:
        return 'Lane Dash';
    }
  }

  String get gameId {
    switch (this) {
      case _ExampleMiniGame.pulseSprint:
        return 'pulse_sprint';
      case _ExampleMiniGame.beatBridge:
        return 'beat_bridge';
      case _ExampleMiniGame.laneDash:
        return 'lane_dash';
    }
  }

  String get subtitle {
    switch (this) {
      case _ExampleMiniGame.pulseSprint:
        return 'Tap the shrinking target before it disappears.';
      case _ExampleMiniGame.beatBridge:
        return 'Hit the beat when the moving note crosses the center window.';
      case _ExampleMiniGame.laneDash:
        return 'Catch falling pulses in the correct lane before they slip past the catch bar.';
    }
  }

  IconData get icon {
    switch (this) {
      case _ExampleMiniGame.pulseSprint:
        return Icons.bubble_chart_outlined;
      case _ExampleMiniGame.beatBridge:
        return Icons.music_note_outlined;
      case _ExampleMiniGame.laneDash:
        return Icons.view_week_outlined;
    }
  }

  String get routeName {
    switch (this) {
      case _ExampleMiniGame.pulseSprint:
        return ExamplePulseSprintPage.routeName;
      case _ExampleMiniGame.beatBridge:
        return ExampleBeatBridgePage.routeName;
      case _ExampleMiniGame.laneDash:
        return ExampleLaneDashPage.routeName;
    }
  }
}

class ExampleGamePage extends StatefulWidget {
  const ExampleGamePage({super.key, required this.controller});

  static const String routeName = '/game';

  final ExampleAppController controller;

  @override
  State<ExampleGamePage> createState() => _ExampleGamePageState();
}

class _ExampleGamePageState extends State<ExampleGamePage> {
  late final TextEditingController _playerNameController =
      TextEditingController(text: widget.controller.gamePlayerName);

  Future<void> _openGame(String routeName) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamed(routeName);
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return ExamplePageScaffold(
          title: 'Mini Games',
          subtitle:
              'Three tiny no-dependencies Flutter games. The hub stays lightweight, and each game now opens on its own full-screen route so phones keep the board visible.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExampleSectionCard(
                title: 'Player profile',
                subtitle:
                    'The current player name is attached to each gameplay event and scopes the best-score readout below.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      key: const ValueKey<String>('game_player_name_field'),
                      controller: _playerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Player name',
                        hintText: 'Taylor',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: widget.controller.setGamePlayerName,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        ExampleMetricChip(
                          label: 'Current player',
                          value: widget.controller.activeGamePlayerName,
                        ),
                        for (final game in _ExampleMiniGame.values)
                          ExampleMetricChip(
                            label: '${game.title} best',
                            value:
                                '${widget.controller.bestScoreForGame(game.gameId)}',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ExampleSectionCard(
                title: 'Open a game',
                subtitle:
                    'Each game now launches into a dedicated full-screen route. That keeps the board clear on smaller phones while still logging gameplay through the same Attriax instance.',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _ExampleMiniGame.values
                      .map(
                        (game) => ExampleNavigationTile(
                          title: game.title,
                          subtitle:
                              '${game.subtitle} Player best: ${widget.controller.bestScoreForGame(game.gameId)}.',
                          icon: game.icon,
                          onTap: () => _openGame(game.routeName),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ExamplePulseSprintPage extends StatelessWidget {
  const ExamplePulseSprintPage({super.key, required this.controller});

  static const String routeName = '${ExampleGamePage.routeName}/pulse-sprint';

  final ExampleAppController controller;

  @override
  Widget build(BuildContext context) {
    return _ExampleGameStagePage(
      controller: controller,
      title: 'Pulse Sprint',
      subtitle:
          'Tap the shrinking target before it disappears. This route keeps the board full-height on smaller phones.',
      gameId: _ExampleMiniGame.pulseSprint.gameId,
      child: _PulseSprintGame(controller: controller),
    );
  }
}

class ExampleBeatBridgePage extends StatelessWidget {
  const ExampleBeatBridgePage({super.key, required this.controller});

  static const String routeName = '${ExampleGamePage.routeName}/beat-bridge';

  final ExampleAppController controller;

  @override
  Widget build(BuildContext context) {
    return _ExampleGameStagePage(
      controller: controller,
      title: 'Beat Bridge',
      subtitle:
          'Hit the beat while the moving note crosses the center window. Full-screen mode keeps timing visible instead of collapsing into a thin strip.',
      gameId: _ExampleMiniGame.beatBridge.gameId,
      child: _BeatBridgeGame(controller: controller),
    );
  }
}

class ExampleLaneDashPage extends StatelessWidget {
  const ExampleLaneDashPage({super.key, required this.controller});

  static const String routeName = '${ExampleGamePage.routeName}/lane-dash';

  final ExampleAppController controller;

  @override
  Widget build(BuildContext context) {
    return _ExampleGameStagePage(
      controller: controller,
      title: 'Lane Dash',
      subtitle:
          'Catch falling pulses in the correct lane before they pass the catch bar. The dedicated route gives the lanes the vertical space they need.',
      gameId: _ExampleMiniGame.laneDash.gameId,
      child: _LaneDashGame(controller: controller),
    );
  }
}

class _ExampleGameStagePage extends StatelessWidget {
  const _ExampleGameStagePage({
    required this.controller,
    required this.title,
    required this.subtitle,
    required this.gameId,
    required this.child,
  });

  final ExampleAppController controller;
  final String title;
  final String subtitle;
  final String gameId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(title: Text(title)),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFFF4F8F7), Color(0xFFE8F2EF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: <Color>[
                              Color(0xFF0D6E5E),
                              Color(0xFF1A8A74),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x220D6E5E),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                title,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.92,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  _GameHeaderChip(
                                    label: 'Player',
                                    value: controller.activeGamePlayerName,
                                  ),
                                  _GameHeaderChip(
                                    label: 'Best score',
                                    value:
                                        '${controller.bestScoreForGame(gameId)}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GameHeaderChip extends StatelessWidget {
  const _GameHeaderChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          children: <TextSpan>[
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _GameMetricChip extends StatelessWidget {
  const _GameMetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: const Color(0xFF3A5C55)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _PulseSprintGame extends StatefulWidget {
  const _PulseSprintGame({required this.controller});

  final ExampleAppController controller;

  @override
  State<_PulseSprintGame> createState() => _PulseSprintGameState();
}

class _PulseSprintGameState extends State<_PulseSprintGame> {
  static const String _gameId = 'pulse_sprint';
  static const double _baseRadius = 56;
  static const double _boardPadding = 18;

  final math.Random _random = math.Random();
  Timer? _timer;

  Size _boardSize = Size.zero;
  Offset _targetCenter = const Offset(120, 120);
  double _radius = _baseRadius;
  bool _running = false;
  int _score = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _lives = 3;
  int _hits = 0;
  int _misses = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startGame() async {
    _timer?.cancel();
    setState(() {
      _running = true;
      _score = 0;
      _combo = 0;
      _bestCombo = 0;
      _lives = 3;
      _hits = 0;
      _misses = 0;
      _radius = _baseRadius;
      _spawnTarget();
    });
    await widget.controller.noteMiniGameStarted(gameId: _gameId);
    _timer = Timer.periodic(const Duration(milliseconds: 32), (_) {
      setState(() {
        _radius -= 1.35;
        if (_radius <= 14) {
          _handleMiss();
        }
      });
    });
  }

  void _spawnTarget() {
    final spawnRadius = _spawnRadius();
    final safeWidth = _boardSize.width;
    final safeHeight = _boardSize.height;

    if (safeWidth <= (spawnRadius * 2) + (_boardPadding * 2) ||
        safeHeight <= (spawnRadius * 2) + (_boardPadding * 2)) {
      _targetCenter = Offset(safeWidth / 2, safeHeight / 2);
      _radius = spawnRadius;
      return;
    }

    final minX = spawnRadius + _boardPadding;
    final maxX = safeWidth - spawnRadius - _boardPadding;
    final minY = spawnRadius + _boardPadding;
    final maxY = safeHeight - spawnRadius - _boardPadding;

    _targetCenter = Offset(
      minX + _random.nextDouble() * (maxX - minX),
      minY + _random.nextDouble() * (maxY - minY),
    );
    _radius = spawnRadius;
  }

  double _spawnRadius() => _baseRadius - math.min(_combo.toDouble() * 1.5, 24);

  void _handleTapDown(TapDownDetails details) {
    if (!_running) {
      return;
    }

    final distance = (details.localPosition - _targetCenter).distance;
    if (distance <= _radius) {
      _score += 10 + _combo;
      _combo += 1;
      _hits += 1;
      _bestCombo = math.max(_bestCombo, _combo);
      _spawnTarget();
      if (_combo % 5 == 0) {
        unawaited(
          widget.controller.noteMiniGameMilestone(
            gameId: _gameId,
            score: _score,
            label: 'combo',
            metrics: <String, Object?>{'combo': _combo},
          ),
        );
      }
      setState(() {});
    } else {
      setState(_handleMiss);
    }
  }

  void _handleMiss() {
    _misses += 1;
    _combo = 0;
    _lives -= 1;
    if (_lives <= 0) {
      _finishGame();
      return;
    }
    _spawnTarget();
  }

  void _finishGame() {
    _timer?.cancel();
    _running = false;
    unawaited(
      widget.controller.noteMiniGameFinished(
        gameId: _gameId,
        score: _score,
        metrics: <String, Object?>{
          'bestCombo': _bestCombo,
          'hits': _hits,
          'misses': _misses,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        _boardSize = constraints.biggest;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _GameMetricChip(label: 'Score', value: '$_score'),
                _GameMetricChip(label: 'Combo', value: '$_combo'),
                _GameMetricChip(label: 'Best', value: '$_bestCombo'),
                _GameMetricChip(label: 'Lives', value: '$_lives'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GestureDetector(
                onTapDown: _handleTapDown,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0xFF0B2F2A), Color(0xFF145347)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Positioned(
                          left: _targetCenter.dx - _radius,
                          top: _targetCenter.dy - _radius,
                          child: Container(
                            width: _radius * 2,
                            height: _radius * 2,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFFFFE082),
                                  Color(0xFFFF7043),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                        if (!_running)
                          Center(
                            child: IgnorePointer(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.28),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Pulse Sprint',
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap Start, then hit every pulse before it shrinks away. The center hint disappears while the round is live so the targets stay visible.',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(color: Colors.white70),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _startGame,
              icon: Icon(_running ? Icons.restart_alt : Icons.play_arrow),
              label: Text(_running ? 'Restart run' : 'Start run'),
            ),
          ],
        );
      },
    );
  }
}

class _BeatBridgeGame extends StatefulWidget {
  const _BeatBridgeGame({required this.controller});

  final ExampleAppController controller;

  @override
  State<_BeatBridgeGame> createState() => _BeatBridgeGameState();
}

class _BeatBridgeGameState extends State<_BeatBridgeGame> {
  static const String _gameId = 'beat_bridge';

  Timer? _timer;
  bool _running = false;
  double _position = 0.08;
  double _direction = 1;
  double _speed = 0.03;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _lives = 4;
  int _hits = 0;
  int _misses = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startGame() async {
    _timer?.cancel();
    setState(() {
      _running = true;
      _position = 0.08;
      _direction = 1;
      _speed = 0.03;
      _score = 0;
      _streak = 0;
      _bestStreak = 0;
      _lives = 4;
      _hits = 0;
      _misses = 0;
    });
    await widget.controller.noteMiniGameStarted(gameId: _gameId);
    _timer = Timer.periodic(const Duration(milliseconds: 32), (_) {
      setState(() {
        _position += _direction * _speed;
        if (_position >= 0.92) {
          _position = 0.92;
          _direction = -1;
        } else if (_position <= 0.08) {
          _position = 0.08;
          _direction = 1;
        }
      });
    });
  }

  void _hitBeat() {
    if (!_running) {
      return;
    }

    final distanceFromCenter = (_position - 0.5).abs();
    if (distanceFromCenter <= 0.1) {
      _hits += 1;
      _streak += 1;
      _bestStreak = math.max(_bestStreak, _streak);
      _score += 18 + (_streak * 2);
      _speed = math.min(_speed + 0.002, 0.055);
      if (_hits % 4 == 0) {
        unawaited(
          widget.controller.noteMiniGameMilestone(
            gameId: _gameId,
            score: _score,
            label: 'streak',
            metrics: <String, Object?>{'streak': _streak},
          ),
        );
      }
      if (_hits >= 15) {
        _finishGame();
      }
      setState(() {});
      return;
    }

    setState(() {
      _misses += 1;
      _streak = 0;
      _lives -= 1;
      if (_lives <= 0) {
        _finishGame();
      }
    });
  }

  void _finishGame() {
    _timer?.cancel();
    _running = false;
    unawaited(
      widget.controller.noteMiniGameFinished(
        gameId: _gameId,
        score: _score,
        metrics: <String, Object?>{
          'bestStreak': _bestStreak,
          'hits': _hits,
          'misses': _misses,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _GameMetricChip(label: 'Score', value: '$_score'),
            _GameMetricChip(label: 'Streak', value: '$_streak'),
            _GameMetricChip(label: 'Best', value: '$_bestStreak'),
            _GameMetricChip(label: 'Lives', value: '$_lives'),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF1C2442), Color(0xFF294B8F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 0.22,
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFFFFD166),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment(_position * 2 - 1, 0),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFF5A5F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _running
                        ? 'Tap when the red note enters the gold window.'
                        : 'Start a run, then hit the beat 15 times before you run out of lives.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _hitBeat,
                    icon: const Icon(Icons.music_note),
                    label: const Text('Hit beat'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _startGame,
          icon: Icon(_running ? Icons.restart_alt : Icons.play_arrow),
          label: Text(_running ? 'Restart run' : 'Start run'),
        ),
      ],
    );
  }
}

class _LaneDashGame extends StatefulWidget {
  const _LaneDashGame({required this.controller});

  final ExampleAppController controller;

  @override
  State<_LaneDashGame> createState() => _LaneDashGameState();
}

class _LaneDashGameState extends State<_LaneDashGame> {
  static const String _gameId = 'lane_dash';
  static const double _pulseSize = 52;
  static const double _catcherHeight = 44;
  static const double _catcherBottomPadding = 14;
  static const double _travelTopPadding = 16;
  static const double _laneGap = 8;

  final math.Random _random = math.Random();
  Timer? _timer;

  bool _running = false;
  int _pulseLane = 1;
  int _selectedLane = 1;
  double _progress = 0.0;
  double _speed = 0.022;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _lives = 3;
  int _hits = 0;
  int _misses = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startGame() async {
    _timer?.cancel();
    setState(() {
      _running = true;
      _score = 0;
      _streak = 0;
      _bestStreak = 0;
      _lives = 3;
      _hits = 0;
      _misses = 0;
      _speed = 0.022;
      _progress = 0.0;
      _selectedLane = 1;
      _pulseLane = _random.nextInt(3);
    });
    await widget.controller.noteMiniGameStarted(gameId: _gameId);
    _timer = Timer.periodic(const Duration(milliseconds: 48), (_) {
      setState(() {
        _progress += _speed;
        if (_progress >= 1) {
          _resolveCatch();
        }
      });
    });
  }

  void _tapLane(int lane) {
    setState(() {
      _selectedLane = lane;
    });
  }

  void _resolveCatch() {
    if (_selectedLane == _pulseLane) {
      _hits += 1;
      _streak += 1;
      _bestStreak = math.max(_bestStreak, _streak);
      _score += 20 + (_streak * 3);
      _speed = math.min(_speed + 0.0015, 0.045);
      if (_hits % 4 == 0) {
        unawaited(
          widget.controller.noteMiniGameMilestone(
            gameId: _gameId,
            score: _score,
            label: 'lane streak',
            metrics: <String, Object?>{'streak': _streak},
          ),
        );
      }
      if (_hits >= 12) {
        _finishGame();
      } else {
        _spawnPulse();
      }
      return;
    }

    _registerMiss();
  }

  void _registerMiss() {
    _misses += 1;
    _streak = 0;
    _lives -= 1;
    if (_lives <= 0) {
      _finishGame();
      return;
    }
    _spawnPulse();
  }

  void _spawnPulse() {
    _pulseLane = _random.nextInt(3);
    _progress = 0.0;
  }

  void _finishGame() {
    _timer?.cancel();
    _running = false;
    unawaited(
      widget.controller.noteMiniGameFinished(
        gameId: _gameId,
        score: _score,
        metrics: <String, Object?>{
          'hits': _hits,
          'misses': _misses,
          'bestStreak': _bestStreak,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _GameMetricChip(label: 'Score', value: '$_score'),
            _GameMetricChip(label: 'Streak', value: '$_streak'),
            _GameMetricChip(label: 'Best', value: '$_bestStreak'),
            _GameMetricChip(label: 'Lives', value: '$_lives'),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF35154D), Color(0xFF6F2DBD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final laneWidth = (constraints.maxWidth - (_laneGap * 2)) / 3;
                  final catcherTop =
                      constraints.maxHeight -
                      _catcherBottomPadding -
                      _catcherHeight;
                  final pulseTargetTop =
                      catcherTop + ((_catcherHeight - _pulseSize) / 2);
                  final topOffset =
                      _travelTopPadding +
                      (_progress *
                          math.max(0, pulseTargetTop - _travelTopPadding));
                  final pulseLeft =
                      (_pulseLane * (laneWidth + _laneGap)) +
                      ((laneWidth - _pulseSize) / 2);

                  return Stack(
                    children: <Widget>[
                      Row(
                        children: List<Widget>.generate(
                          3,
                          (index) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: pulseLeft,
                        top: topOffset,
                        child: Container(
                          width: _pulseSize,
                          height: _pulseSize,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: <Color>[
                                Color(0xFFB8F2E6),
                                Color(0xFF5E60CE),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: IgnorePointer(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              _running
                                  ? 'Tap a lane to move the catcher before the pulse reaches the bottom.'
                                  : 'Start a run, then choose the lane that should catch the next pulse.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: _catcherBottomPadding,
                        child: Row(
                          children: List<Widget>.generate(
                            3,
                            (index) => Expanded(
                              child: Container(
                                height: _catcherHeight,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: index == _selectedLane
                                      ? const Color(0xFFFFD166)
                                      : Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: index == _selectedLane
                                        ? const Color(0xFFFFF1C1)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: FilledButton(
                onPressed: () => _tapLane(0),
                style: FilledButton.styleFrom(
                  backgroundColor: _selectedLane == 0
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  foregroundColor: _selectedLane == 0
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
                child: const Text('Left'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () => _tapLane(1),
                style: FilledButton.styleFrom(
                  backgroundColor: _selectedLane == 1
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  foregroundColor: _selectedLane == 1
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
                child: const Text('Center'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () => _tapLane(2),
                style: FilledButton.styleFrom(
                  backgroundColor: _selectedLane == 2
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  foregroundColor: _selectedLane == 2
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
                child: const Text('Right'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _startGame,
          icon: Icon(_running ? Icons.restart_alt : Icons.play_arrow),
          label: Text(_running ? 'Restart run' : 'Start run'),
        ),
      ],
    );
  }
}
