import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const DiwaliApp());
}

class DiwaliApp extends StatelessWidget {
  const DiwaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diwali Cracker Celebration - ARMAN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090A0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
      ),
      home: const DiwaliHomeScreen(),
    );
  }
}

enum CrackerType { rocket, bomb, chakri, anaar, sparkler }

class ActiveParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double life;
  double maxLife;
  String? char;

  ActiveParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.life,
    required this.maxLife,
    this.char,
  });
}

class RocketItem {
  double startX;
  double startY;
  double currentX;
  double currentY;
  double targetY;
  double speed;
  bool exploded;
  String text;

  RocketItem({
    required this.startX,
    required this.startY,
    required this.currentX,
    required this.currentY,
    required this.targetY,
    required this.speed,
    this.exploded = false,
    required this.text,
  });
}

class ActiveAnaar {
  double x;
  double y;
  double duration;
  double maxDuration;

  ActiveAnaar({
    required this.x,
    required this.y,
    required this.duration,
    required this.maxDuration,
  });
}

class ActiveChakri {
  double x;
  double y;
  double rotation;
  double duration;
  double maxDuration;

  ActiveChakri({
    required this.x,
    required this.y,
    required this.rotation,
    required this.duration,
    required this.maxDuration,
  });
}

class ActiveBomb {
  double x;
  double y;
  double fuseTimer;
  bool exploded;

  ActiveBomb({
    required this.x,
    required this.y,
    this.fuseTimer = 1.0,
    this.exploded = false,
  });
}

class SparklerPoint {
  double x;
  double y;

  SparklerPoint(this.x, this.y);
}

class DiwaliHomeScreen extends StatefulWidget {
  const DiwaliHomeScreen({super.key});

  @override
  State<DiwaliHomeScreen> createState() => _DiwaliHomeScreenState();
}

class _DiwaliHomeScreenState extends State<DiwaliHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  final List<ActiveParticle> _particles = [];
  final List<RocketItem> _rockets = [];
  final List<ActiveAnaar> _anaars = [];
  final List<ActiveChakri> _chakris = [];
  final List<ActiveBomb> _bombs = [];

  bool _isSparklerActive = false;
  Offset? _sparklerTouch;
  double _screenShake = 0.0;
  double _flashOpacity = 0.0;
  String _customName = "ARMAN";
  final TextEditingController _nameController =
      TextEditingController(text: "ARMAN");

  CrackerType _selectedCracker = CrackerType.rocket;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateAnimation);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _updateAnimation() {
    setState(() {
      // Screen shake recovery
      if (_screenShake > 0) {
        _screenShake = max(0, _screenShake - 0.8);
      }
      if (_flashOpacity > 0) {
        _flashOpacity = max(0, _flashOpacity - 0.05);
      }

      // Update rockets
      for (int i = _rockets.length - 1; i >= 0; i--) {
        final r = _rockets[i];
        if (!r.exploded) {
          r.currentY -= r.speed;
          // Add trail particles
          _particles.add(
            ActiveParticle(
              x: r.currentX + (_random.nextDouble() - 0.5) * 4,
              y: r.currentY + 10,
              vx: (_random.nextDouble() - 0.5) * 1.5,
              vy: _random.nextDouble() * 2 + 1,
              color: Colors.orangeAccent,
              size: 2.5,
              life: 0.3,
              maxLife: 0.3,
            ),
          );

          if (r.currentY <= r.targetY) {
            r.exploded = true;
            _explodeRocketName(r.currentX, r.currentY, r.text);
            _rockets.removeAt(i);
          }
        }
      }

      // Update Anaars (Flowerpots)
      for (int i = _anaars.length - 1; i >= 0; i--) {
        final a = _anaars[i];
        a.duration -= 0.016;
        if (a.duration > 0) {
          // Shoot sparks upwards in cone
          for (int p = 0; p < 8; p++) {
            double angle = -pi / 2 + (_random.nextDouble() - 0.5) * 0.7;
            double speed = _random.nextDouble() * 9 + 4;
            _particles.add(
              ActiveParticle(
                x: a.x,
                y: a.y,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed,
                color: _getRandomBrightColor(),
                size: _random.nextDouble() * 3 + 2,
                life: 0.6 + _random.nextDouble() * 0.4,
                maxLife: 1.0,
              ),
            );
          }
        } else {
          _anaars.removeAt(i);
        }
      }

      // Update Chakris
      for (int i = _chakris.length - 1; i >= 0; i--) {
        final c = _chakris[i];
        c.duration -= 0.016;
        c.rotation += 0.4;
        if (c.duration > 0) {
          // Circular fire spray
          for (int p = 0; p < 6; p++) {
            double angle = c.rotation + (p * pi / 3);
            double speed = _random.nextDouble() * 6 + 3;
            _particles.add(
              ActiveParticle(
                x: c.x,
                y: c.y,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed + 0.5,
                color: Colors.amberAccent,
                size: 3.0,
                life: 0.4 + _random.nextDouble() * 0.3,
                maxLife: 0.7,
              ),
            );
          }
        } else {
          _chakris.removeAt(i);
        }
      }

      // Update Bombs
      for (int i = _bombs.length - 1; i >= 0; i--) {
        final b = _bombs[i];
        if (!b.exploded) {
          b.fuseTimer -= 0.03;
          // Fuse spark
          _particles.add(
            ActiveParticle(
              x: b.x + 5,
              y: b.y - 12,
              vx: (_random.nextDouble() - 0.5) * 2,
              vy: -_random.nextDouble() * 2,
              color: Colors.redAccent,
              size: 2.0,
              life: 0.2,
              maxLife: 0.2,
            ),
          );
          if (b.fuseTimer <= 0) {
            b.exploded = true;
            _triggerBombExplosion(b.x, b.y);
            _bombs.removeAt(i);
          }
        }
      }

      // Update Sparkler continuous emission
      if (_isSparklerActive && _sparklerTouch != null) {
        for (int p = 0; p < 10; p++) {
          double angle = _random.nextDouble() * 2 * pi;
          double speed = _random.nextDouble() * 5 + 1;
          _particles.add(
            ActiveParticle(
              x: _sparklerTouch!.dx,
              y: _sparklerTouch!.dy,
              vx: cos(angle) * speed,
              vy: sin(angle) * speed,
              color: Colors.yellowAccent,
              size: _random.nextDouble() * 3 + 1.5,
              life: 0.3 + _random.nextDouble() * 0.3,
              maxLife: 0.6,
            ),
          );
        }
      }

      // Update all particles physics
      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        p.life -= 0.016;
        if (p.life <= 0) {
          _particles.removeAt(i);
        } else {
          p.x += p.vx;
          p.y += p.vy;
          if (p.char == null) {
            p.vy += 0.08; // Gravity for normal sparks
          } else {
            p.vx *= 0.95;
            p.vy *= 0.95; // Damping for text fireworks
          }
        }
      }
    });
  }

  Color _getRandomBrightColor() {
    List<Color> colors = [
      Colors.cyanAccent,
      Colors.yellowAccent,
      Colors.pinkAccent,
      Colors.amberAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.redAccent,
      Colors.lightBlueAccent,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _explodeRocketName(double centerX, double centerY, String text) {
    _screenShake = 4.0;
    // Radial explosion background sparks
    for (int i = 0; i < 70; i++) {
      double angle = _random.nextDouble() * 2 * pi;
      double speed = _random.nextDouble() * 7 + 2;
      _particles.add(
        ActiveParticle(
          x: centerX,
          y: centerY,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          color: _getRandomBrightColor(),
          size: _random.nextDouble() * 3 + 2,
          life: 0.8 + _random.nextDouble() * 0.5,
          maxLife: 1.3,
        ),
      );
    }

    // Name Fireworks spellout generator
    List<Offset> namePoints = _generateTextPoints(text.toUpperCase());
    double scale = 2.4;
    double startX = centerX - (namePoints.isNotEmpty ? 120.0 : 0);

    for (Offset pt in namePoints) {
      double px = startX + pt.dx * scale;
      double py = centerY + pt.dy * scale;

      // Add text spark particle
      _particles.add(
        ActiveParticle(
          x: px,
          y: py,
          vx: (_random.nextDouble() - 0.5) * 0.8,
          vy: (_random.nextDouble() - 0.5) * 0.8,
          color: Colors.amberAccent,
          size: 4.0,
          life: 2.2 + _random.nextDouble() * 0.6,
          maxLife: 2.8,
          char: "*",
        ),
      );

      // Extra shimmering surround glow
      for (int k = 0; k < 2; k++) {
        _particles.add(
          ActiveParticle(
            x: px + (_random.nextDouble() - 0.5) * 4,
            y: py + (_random.nextDouble() - 0.5) * 4,
            vx: (_random.nextDouble() - 0.5) * 0.5,
            vy: (_random.nextDouble() - 0.5) * 0.5,
            color: _getRandomBrightColor(),
            size: 2.0,
            life: 1.8 + _random.nextDouble() * 0.5,
            maxLife: 2.3,
            char: ".",
          ),
        );
      }
    }
  }

  List<Offset> _generateTextPoints(String text) {
    List<Offset> points = [];
    double currentOffsetX = 0.0;

    for (int charIdx = 0; charIdx < text.length; charIdx++) {
      String c = text[charIdx];
      List<Offset> letterPoints = _getLetterShape(c);

      for (Offset p in letterPoints) {
        points.add(Offset(p.dx + currentOffsetX, p.dy));
      }
      currentOffsetX += 32.0; // Space between letters
    }

    return points;
  }

  List<Offset> _getLetterShape(String letter) {
    List<Offset> pts = [];
    // 5x7 grid point mapping for key letters
    switch (letter) {
      case 'A':
        for (double y = 0; y <= 20; y += 2) {
          pts.add(Offset(10 - y * 0.5, y));
          pts.add(Offset(10 + y * 0.5, y));
        }
        for (double x = 5; x <= 15; x += 2) {
          pts.add(Offset(x, 10));
        }
        break;
      case 'R':
        for (double y = 0; y <= 20; y += 2) {
          pts.add(Offset(0, y));
        }
        for (double a = -pi / 2; a <= pi / 2; a += 0.3) {
          pts.add(Offset(5 + cos(a) * 5, 5 + sin(a) * 5));
        }
        for (double d = 0; d <= 10; d += 2) {
          pts.add(Offset(d, 10 + d));
        }
        break;
      case 'M':
        for (double y = 0; y <= 20; y += 2) {
          pts.add(Offset(0, y));
          pts.add(Offset(20, y));
        }
        for (double d = 0; d <= 10; d += 2) {
          pts.add(Offset(d, d));
          pts.add(Offset(20 - d, d));
        }
        break;
      case 'N':
        for (double y = 0; y <= 20; y += 2) {
          pts.add(Offset(0, y));
          pts.add(Offset(18, y));
        }
        for (double d = 0; d <= 18; d += 2) {
          pts.add(Offset(d, d * (20 / 18)));
        }
        break;
      case 'I':
        for (double y = 0; y <= 20; y += 2) {
          pts.add(Offset(5, y));
        }
        for (double x = 0; x <= 10; x += 2) {
          pts.add(Offset(x, 0));
          pts.add(Offset(x, 20));
        }
        break;
      case 'D':
        for (double y = 0; y <= 20; y += 2) {
          pts.add(Offset(0, y));
        }
        for (double a = -pi / 2; a <= pi / 2; a += 0.2) {
          pts.add(Offset(cos(a) * 10, 10 + sin(a) * 10));
        }
        break;
      case 'W':
        for (double y = 0; y <= 20; y += 2) {
          pts.add(Offset(0, y));
          pts.add(Offset(20, y));
        }
        for (double d = 0; d <= 10; d += 2) {
          pts.add(Offset(d, 20 - d));
          pts.add(Offset(20 - d, 20 - d));
        }
        break;
      case 'L':
        for (double y = 0; y <= 20; y += 2) {
          pts.add(Offset(0, y));
        }
        for (double x = 0; x <= 14; x += 2) {
          pts.add(Offset(x, 20));
        }
        break;
      default:
        // Default star shape
        for (double a = 0; a < 2 * pi; a += 0.4) {
          pts.add(Offset(10 + cos(a) * 8, 10 + sin(a) * 8));
        }
        break;
    }
    return pts;
  }

  void _triggerBombExplosion(double x, double y) {
    _screenShake = 14.0;
    _flashOpacity = 0.6;
    for (int i = 0; i < 90; i++) {
      double angle = _random.nextDouble() * 2 * pi;
      double speed = _random.nextDouble() * 12 + 2;
      _particles.add(
        ActiveParticle(
          x: x,
          y: y,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          color: i % 2 == 0 ? Colors.deepOrangeAccent : Colors.yellowAccent,
          size: _random.nextDouble() * 4 + 3,
          life: 0.6 + _random.nextDouble() * 0.4,
          maxLife: 1.0,
        ),
      );
    }
  }

  void _handleTapAt(Offset details, Size screenSize) {
    double groundY = screenSize.height - 130;

    switch (_selectedCracker) {
      case CrackerType.rocket:
        _rockets.add(
          RocketItem(
            startX: details.dx,
            startY: groundY,
            currentX: details.dx,
            currentY: groundY,
            targetY: max(100.0, details.dy),
            speed: 9.0 + _random.nextDouble() * 3,
            text: _customName,
          ),
        );
        break;
      case CrackerType.bomb:
        _bombs.add(ActiveBomb(x: details.dx, y: groundY));
        break;
      case CrackerType.chakri:
        _chakris.add(
          ActiveChakri(
            x: details.dx,
            y: groundY,
            rotation: 0.0,
            duration: 3.5,
            maxDuration: 3.5,
          ),
        );
        break;
      case CrackerType.anaar:
        _anaars.add(
          ActiveAnaar(
            x: details.dx,
            y: groundY,
            duration: 4.0,
            maxDuration: 4.0,
          ),
        );
        break;
      case CrackerType.sparkler:
        _sparklerTouch = details;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Apply screen shake transform
    double shakeX = (_random.nextDouble() - 0.5) * _screenShake * 2;
    double shakeY = (_random.nextDouble() - 0.5) * _screenShake * 2;

    return Scaffold(
      body: Stack(
        children: [
          // Main Animated Canvas with Shake effect
          Transform.translate(
            offset: Offset(shakeX, shakeY),
            child: GestureDetector(
              onTapDown: (details) => _handleTapAt(details.localPosition, size),
              onPanStart: (details) {
                if (_selectedCracker == CrackerType.sparkler) {
                  setState(() {
                    _isSparklerActive = true;
                    _sparklerTouch = details.localPosition;
                  });
                }
              },
              onPanUpdate: (details) {
                if (_selectedCracker == CrackerType.sparkler) {
                  setState(() {
                    _sparklerTouch = details.localPosition;
                  });
                }
              },
              onPanEnd: (_) {
                setState(() {
                  _isSparklerActive = false;
                  _sparklerTouch = null;
                });
              },
              child: CustomPaint(
                size: size,
                painter: DiwaliCanvasPainter(
                  particles: _particles,
                  rockets: _rockets,
                  anaars: _anaars,
                  chakris: _chakris,
                  bombs: _bombs,
                  sparklerTouch: _sparklerTouch,
                  isSparklerActive: _isSparklerActive,
                  time: DateTime.now().millisecondsSinceEpoch / 1000.0,
                ),
              ),
            ),
          ),

          // Flash overlay on bomb blast
          if (_flashOpacity > 0)
            IgnorePointer(
              child: Container(
                color: Colors.white.withValues(alpha: _flashOpacity),
              ),
            ),

          // Header Title & Custom Name Input
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Colors.amber,
                            Colors.deepOrange,
                            Colors.pinkAccent
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          '✨ HAPPY DIWALI 🪔',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(blurRadius: 10, color: Colors.orangeAccent)
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Click on crackers below or tap sky to launch! 🚀',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade200,
                        ),
                      ),
                    ],
                  ),
                ),
                // Custom Name Dialog button
                ElevatedButton.icon(
                  onPressed: _showNameDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange.withValues(alpha: 0.8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text('Name: $_customName'),
                ),
              ],
            ),
          ),

          // Bottom Interactive Firecracker Selection Toolbar
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF161925).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCrackerSelector(
                    type: CrackerType.rocket,
                    icon: '🚀',
                    label: 'Rocket (Arman)',
                  ),
                  _buildCrackerSelector(
                    type: CrackerType.bomb,
                    icon: '💣',
                    label: 'Bam (Bomb)',
                  ),
                  _buildCrackerSelector(
                    type: CrackerType.chakri,
                    icon: '🌀',
                    label: 'Chakri',
                  ),
                  _buildCrackerSelector(
                    type: CrackerType.anaar,
                    icon: '🎇',
                    label: 'Aftab (10 Fira)',
                  ),
                  _buildCrackerSelector(
                    type: CrackerType.sparkler,
                    icon: '🪄',
                    label: 'Phuljhadi',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrackerSelector({
    required CrackerType type,
    required String icon,
    required String label,
  }) {
    final bool isSelected = _selectedCracker == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCracker = type;
        });
        // Also immediately launch a demo cracker near center screen
        final size = MediaQuery.of(context).size;
        _handleTapAt(Offset(size.width * 0.5, size.height * 0.4), size);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.amber.shade700
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2235),
        title: const Text('Enter Fireworks Name 🎆',
            style: TextStyle(color: Colors.amber)),
        content: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'e.g. ARMAN',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.amber)),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              setState(() {
                _customName = _nameController.text.trim().isEmpty
                    ? "ARMAN"
                    : _nameController.text.trim().toUpperCase();
              });
              Navigator.pop(context);
            },
            child:
                const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

class DiwaliCanvasPainter extends CustomPainter {
  final List<ActiveParticle> particles;
  final List<RocketItem> rockets;
  final List<ActiveAnaar> anaars;
  final List<ActiveChakri> chakris;
  final List<ActiveBomb> bombs;
  final Offset? sparklerTouch;
  final bool isSparklerActive;
  final double time;

  DiwaliCanvasPainter({
    required this.particles,
    required this.rockets,
    required this.anaars,
    required this.chakris,
    required this.bombs,
    required this.sparklerTouch,
    required this.isSparklerActive,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Night Sky Gradient
    final Rect rect = Offset.zero & size;
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF030514),
          Color(0xFF0A0E2A),
          Color(0xFF1A1438),
          Color(0xFF2C1434),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // 2. Draw Stars
    final Random starRand = Random(42);
    final Paint starPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 80; i++) {
      double sx = starRand.nextDouble() * size.width;
      double sy = starRand.nextDouble() * (size.height * 0.6);
      double radius = starRand.nextDouble() * 1.5 + 0.5;
      double blink = (sin(time * 3 + i) + 1.0) / 2.0;
      starPaint.color = Colors.white.withValues(alpha: 0.3 + blink * 0.7);
      canvas.drawCircle(Offset(sx, sy), radius, starPaint);
    }

    // 3. Draw Moon
    final Paint moonPaint = Paint()
      ..color = const Color(0xFFFFFDD0)
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 12);
    canvas.drawCircle(Offset(size.width * 0.85, 90), 30, moonPaint);
    // Crescent shadow
    final Paint moonShadow = Paint()..color = const Color(0xFF0A0E2A);
    canvas.drawCircle(Offset(size.width * 0.85 - 10, 85), 26, moonShadow);

    // 4. Draw Beautiful Lit-up House (Sundar Ghar) at ground
    _drawBeautifulHouse(canvas, size);

    // 5. Draw Ground Diyas
    _drawGroundDiyas(canvas, size);

    // 6. Draw Unlaunched / Standby Cracker Icons on Ground
    _drawGroundCrackerItems(canvas, size);

    // 7. Draw Active Rockets
    for (var r in rockets) {
      final Paint rocketStick = Paint()
        ..color = Colors.brown
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(r.currentX, r.currentY),
        Offset(r.currentX, r.currentY + 18),
        rocketStick,
      );

      final Path conePath = Path()
        ..moveTo(r.currentX, r.currentY - 10)
        ..lineTo(r.currentX - 5, r.currentY)
        ..lineTo(r.currentX + 5, r.currentY)
        ..close();
      final Paint conePaint = Paint()..color = Colors.redAccent;
      canvas.drawPath(conePath, conePaint);
    }

    // 8. Draw Active Anaars (Flowerpot body)
    for (var a in anaars) {
      Path potPath = Path()
        ..moveTo(a.x - 12, a.y)
        ..lineTo(a.x - 6, a.y - 20)
        ..lineTo(a.x + 6, a.y - 20)
        ..lineTo(a.x + 12, a.y)
        ..close();
      Paint potPaint = Paint()..color = const Color(0xFFAB47BC);
      canvas.drawPath(potPath, potPaint);
    }

    // 9. Draw Active Chakris (Ground Spinner)
    for (var c in chakris) {
      canvas.save();
      canvas.translate(c.x, c.y - 5);
      canvas.rotate(c.rotation);
      Paint ringPaint = Paint()
        ..color = Colors.amberAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawCircle(Offset.zero, 14, ringPaint);
      ringPaint.color = Colors.deepOrange;
      canvas.drawCircle(Offset.zero, 8, ringPaint);
      canvas.restore();
    }

    // 10. Draw Active Bombs
    for (var b in bombs) {
      Paint bombPaint = Paint()..color = Colors.black87;
      canvas.drawCircle(Offset(b.x, b.y - 6), 10, bombPaint);
      Paint wickPaint = Paint()
        ..color = Colors.brown
        ..strokeWidth = 2;
      canvas.drawLine(
          Offset(b.x, b.y - 12), Offset(b.x + 5, b.y - 18), wickPaint);
    }

    // 11. Draw Sparkler Wand if active
    if (isSparklerActive && sparklerTouch != null) {
      Paint wandPaint = Paint()
        ..color = Colors.grey.shade400
        ..strokeWidth = 3;
      canvas.drawLine(
        Offset(sparklerTouch!.dx + 15, sparklerTouch!.dy + 35),
        sparklerTouch!,
        wandPaint,
      );
    }

    // 12. Draw All Active Spark Particles & Firework Glows
    for (var p in particles) {
      double alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      Paint pPaint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      if (p.char != null) {
        // Glowing starburst spark for name text
        pPaint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
        canvas.drawCircle(Offset(p.x, p.y), p.size * 1.4, pPaint);
      } else {
        canvas.drawCircle(Offset(p.x, p.y), p.size, pPaint);
      }
    }
  }

  void _drawBeautifulHouse(Canvas canvas, Size size) {
    double groundY = size.height - 100;
    double houseWidth = 220;
    double houseHeight = 140;
    double houseX = size.width * 0.5 - houseWidth / 2;
    double houseY = groundY - houseHeight;

    // Ground Lawn
    Rect groundRect =
        Rect.fromLTRB(0, groundY, size.width, size.height);
    Paint groundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F2615), Color(0xFF051108)],
      ).createShader(groundRect);
    canvas.drawRect(groundRect, groundPaint);

    // Main House Wall
    Rect houseRect = Rect.fromLTWH(houseX, houseY, houseWidth, houseHeight);
    Paint wallPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3D1F2D), Color(0xFF22111A)],
      ).createShader(houseRect);
    canvas.drawRect(houseRect, wallPaint);

    // Roof Triangle
    Path roofPath = Path()
      ..moveTo(houseX - 15, houseY)
      ..lineTo(houseX + houseWidth / 2, houseY - 60)
      ..lineTo(houseX + houseWidth + 15, houseY)
      ..close();
    Paint roofPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8B263E), Color(0xFF4A1220)],
      ).createShader(roofPath.getBounds());
    canvas.drawPath(roofPath, roofPaint);

    // Door
    Rect doorRect = Rect.fromLTWH(
        houseX + houseWidth / 2 - 20, houseY + houseHeight - 55, 40, 55);
    Paint doorPaint = Paint()..color = const Color(0xFF4A2B11);
    canvas.drawRect(doorRect, doorPaint);

    // Door Warm Glow light
    Paint doorGlow = Paint()
      ..color = Colors.amber.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 10);
    canvas.drawRect(doorRect, doorGlow);

    // Windows (Glowing Yellow)
    _drawGlowingWindow(
        canvas, Rect.fromLTWH(houseX + 25, houseY + 30, 40, 40));
    _drawGlowingWindow(
        canvas, Rect.fromLTWH(houseX + houseWidth - 65, houseY + 30, 40, 40));

    // Toran / Decorative Lights String along roof edge
    final Paint lightStringPaint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(houseX - 10, houseY),
      Offset(houseX + houseWidth + 10, houseY),
      lightStringPaint,
    );

    // Blinking fairy bulbs
    List<Color> bulbColors = [
      Colors.redAccent,
      Colors.yellowAccent,
      Colors.cyanAccent,
      Colors.greenAccent,
      Colors.pinkAccent,
    ];
    for (int i = 0; i <= 10; i++) {
      double bx = houseX - 10 + (i * (houseWidth + 20) / 10);
      double by = houseY + (i % 2 == 0 ? 6 : 2);
      Color col = bulbColors[(i + (time * 4).toInt()) % bulbColors.length];
      Paint bPaint = Paint()
        ..color = col
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);
      canvas.drawCircle(Offset(bx, by), 4, bPaint);
    }
  }

  void _drawGlowingWindow(Canvas canvas, Rect winRect) {
    Paint winGlow = Paint()
      ..color = Colors.amber.shade300
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 8);
    canvas.drawRect(winRect, winGlow);

    Paint winPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawRect(winRect, winPaint);

    Paint framePaint = Paint()
      ..color = const Color(0xFF3A1C08)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRect(winRect, framePaint);
    canvas.drawLine(
      Offset(winRect.left + winRect.width / 2, winRect.top),
      Offset(winRect.left + winRect.width / 2, winRect.bottom),
      framePaint,
    );
    canvas.drawLine(
      Offset(winRect.left, winRect.top + winRect.height / 2),
      Offset(winRect.right, winRect.top + winRect.height / 2),
      framePaint,
    );
  }

  void _drawGroundDiyas(Canvas canvas, Size size) {
    double groundY = size.height - 100;

    List<double> diyaXPositions = [
      size.width * 0.1,
      size.width * 0.25,
      size.width * 0.4,
      size.width * 0.6,
      size.width * 0.75,
      size.width * 0.9,
    ];

    for (int i = 0; i < diyaXPositions.length; i++) {
      double dx = diyaXPositions[i];
      double dy = groundY - 4;

      // Clay Diya bowl
      Path diyaBowl = Path()
        ..moveTo(dx - 12, dy)
        ..quadraticBezierTo(dx, dy + 12, dx + 12, dy)
        ..close();
      Paint bowlPaint = Paint()..color = const Color(0xFFD84315);
      canvas.drawPath(diyaBowl, bowlPaint);

      // Flame Glow
      double flameFlicker = sin(time * 8 + i * 2) * 2;
      Paint flameGlow = Paint()
        ..color = Colors.orangeAccent.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 8);
      canvas.drawCircle(Offset(dx, dy - 6), 8 + flameFlicker, flameGlow);

      // Inner Flame
      Path flamePath = Path()
        ..moveTo(dx - 4, dy - 2)
        ..quadraticBezierTo(dx, dy - 14 - flameFlicker, dx + 4, dy - 2)
        ..close();
      Paint flamePaint = Paint()..color = Colors.amberAccent;
      canvas.drawPath(flamePath, flamePaint);
    }
  }

  void _drawGroundCrackerItems(Canvas canvas, Size size) {
    double groundY = size.height - 100;

    // Rocket on stand
    Paint stickPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width * 0.18, groundY),
      Offset(size.width * 0.18, groundY - 24),
      stickPaint,
    );
    Path rHead = Path()
      ..moveTo(size.width * 0.18, groundY - 36)
      ..lineTo(size.width * 0.18 - 6, groundY - 24)
      ..lineTo(size.width * 0.18 + 6, groundY - 24)
      ..close();
    canvas.drawPath(rHead, Paint()..color = Colors.redAccent);

    // Chakri on ground
    Paint chakriPaint = Paint()
      ..color = Colors.amber.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(size.width * 0.33, groundY - 6), 10, chakriPaint);

    // Anaar / Flowerpot on ground
    Path anaarBody = Path()
      ..moveTo(size.width * 0.67 - 10, groundY)
      ..lineTo(size.width * 0.67 - 5, groundY - 18)
      ..lineTo(size.width * 0.67 + 5, groundY - 18)
      ..lineTo(size.width * 0.67 + 10, groundY)
      ..close();
    canvas.drawPath(anaarBody, Paint()..color = Colors.purpleAccent);

    // Bomb on ground
    canvas.drawCircle(
        Offset(size.width * 0.82, groundY - 6), 8, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant DiwaliCanvasPainter oldDelegate) => true;
}

extension ColorExtension on Colors {
  static Color get tertiaryButtonColor => const Color(0xFFAB47BC);
}
