import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


enum ExplodeParticleShape { circle, rectangle, triangle }

class Explode extends StatefulWidget {
  /// The widget that will be visually exploded.
  final Widget child;

  /// The controller used to trigger and reset the explode animation.
  final ExplodeController? controller;

  /// The duration of the explosion animation.
  ///
  /// If not specified, defaults to 1500 milliseconds.
  final Duration? duration;

  /// The size of each individual particle.
  ///
  /// If not specified, the size defaults to the sampling step.
  final double? particleSize;

  /// The shape of the explosion particles.
  ///
  /// Defaults to [ExplodeParticleShape.circle].
  final ExplodeParticleShape shape;

  /// The target number of particles to generate for the explosion.
  ///
  /// If specified, the sampling density is adjusted to try and match this count.
  final int? particleCount;

  /// The bounding area in which the particles can spread.
  ///
  /// If specified, the particle physics/movement scale is adjusted based on this size.
  final Size? explodeArea;

  const Explode({
    super.key,
    required this.child,
    this.controller,
    this.duration,
    this.particleSize,
    this.particleCount,
    this.explodeArea,
    this.shape = ExplodeParticleShape.circle,
  });

  @override
  State<Explode> createState() => _ExplodeState();
}

class _ExplodeState extends State<Explode> with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late AnimationController _animationController;
  List<Particle> _particles = [];
  bool _isExploded = false;
  ui.Image? _snapshot;
  bool _isExploding = false;
  ExplodeParticleShape _shape = ExplodeParticleShape.circle; // Store shape in state

  @override
  void initState() {
    super.initState();
    _shape = widget.shape; // Init shape
    _animationController = AnimationController(
        vsync: this, 
        duration: widget.duration ?? const Duration(milliseconds: 1500)
    );
    
    _animationController.addListener(() {
      // Scale physics based on duration. 
      // 1500ms is the reference duration where scalar = 1.0.
      // If duration is longer (e.g. 3000ms), scalar should be smaller (0.5), to move slower.
      // If duration is shorter (e.g. 750ms), scalar should be larger (2.0), to move faster.
      
      double currentDuration = _animationController.duration?.inMilliseconds.toDouble() ?? 1500.0;
      double scalar = 1500.0 / currentDuration;
      
      setState(() {
        for (var particle in _particles) {
          particle.update(scalar);
        }
      });
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
           _particles.clear();
           _isExploded = true;
           _isExploding = false;
        });
      }
    });
    
    widget.controller?._attach(this);
  }
  
  @override
  void didUpdateWidget(Explode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _animationController.duration = widget.duration ?? const Duration(milliseconds: 1500);
    }
    
    if (widget.shape != oldWidget.shape) {
      _shape = widget.shape;
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    widget.controller?._detach();
    super.dispose();
  }

  Future<void> explode() async {
    if (_isExploded || _isExploding) return;

    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // Capture the image slightly larger to avoid boundary cutoffs if we want effects, 
      // but for now, exact size is fine.
      _snapshot = await boundary.toImage(pixelRatio: 1.0); // Keep pixel ratio 1 for performance
      
      await _createParticles(_snapshot!);

      setState(() {
        _isExploding = true;
      });
      _animationController.forward();
    } catch (e) {
      debugPrint("Error exploding widget: $e");
    }
  }

  Future<void> _createParticles(ui.Image image) async {
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return;
    
    final int width = image.width;
    final int height = image.height;
    final Uint8List pixels = byteData.buffer.asUint8List();
    
    final List<Particle> newParticles = [];
    
    // Determine movement scale based on explodeArea
    // If explodeArea is small, we want particles to move less (scale down physics).
    // Assuming a 'normal' spread covers about 300px radius.
    double movementScale = 1.0;
    if (widget.explodeArea != null) {
       double limit = min(widget.explodeArea!.width, widget.explodeArea!.height);
       movementScale = limit / 300.0; // Heuristic scaling
    }

    // Determine sampling step (density)
    int step;
    if (widget.particleCount != null) {
      final int totalArea = width * height;
      step = sqrt(totalArea / widget.particleCount!).ceil().clamp(1, 100);
    } else {
      step = (widget.particleSize?.toInt() ?? 3).clamp(1, 100);
    }
    
    // Determine visual size of particles
    // Default to 'step' size if not explicit so they stick together (or close to it)
    final double visualSize = widget.particleSize ?? step.toDouble();

    final Random random = Random();

    for (int y = 0; y < height; y += step) {
      for (int x = 0; x < width; x += step) {
        // Ensure we don't go out of bounds if step > 1
        if (x >= width || y >= height) continue;
        
        final int offset = (y * width + x) * 4;
        final int r = pixels[offset];
        final int g = pixels[offset + 1];
        final int b = pixels[offset + 2];
        final int a = pixels[offset + 3];

        if (a == 0) continue;

        final Color color = Color.fromARGB(a, r, g, b);

        // Particles explode outwards but strongly upwards.
        // Some randomness to looks natural.
        
        double speed = (random.nextDouble() * 3 + 2) * movementScale; 
        double angle = random.nextDouble() * 2 * pi;
        
        // Bias angle towards -PI/2 (up)
        // Simple way: Add continuous upward force (gravity is down, initial velocity up)
        
        double vx = cos(angle) * speed;
        double vy = sin(angle) * speed - (8 * movementScale); // Strong initial upward force
        
        // Randomize life for sparkling fade out
        double life = 0.8 + random.nextDouble() * 0.4; // 0.8 to 1.2
        
        newParticles.add(Particle(
          x: x.toDouble(),
          y: y.toDouble(),
          vx: vx,
          vy: vy,
          color: color,
          size: visualSize,
          life: life, 
          gravity: 0.4 * movementScale,
        ));
      }
    }
    _particles = newParticles;
  }
  
  void reset() {
    setState(() {
      _isExploded = false;
      _isExploding = false;
      _particles.clear();
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isExploded) {
      return const SizedBox.shrink();
    }
    
    if (_isExploding) {
       // Allow painting outside bounds
       return SizedBox(
         width: _snapshot!.width.toDouble(),
         height: _snapshot!.height.toDouble(),
         child: OverflowBox(
           maxWidth: double.infinity,
           maxHeight: double.infinity,
           alignment: Alignment.topLeft, // Anchor to top-left of original widget
           child: CustomPaint(
             size: Size(_snapshot!.width.toDouble(), _snapshot!.height.toDouble()),
             painter: ParticlePainter(_particles, _shape),
           ),
         ),
       );
    }
    
    return RepaintBoundary(
      key: _globalKey,
      child: widget.child,
    );
  }
}

class ExplodeController {
  _ExplodeState? _state;

  void _attach(_ExplodeState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  Future<void> explode() async {
    await _state?.explode();
  }
  
  void reset() {
    _state?.reset();
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double life; 
  double maxLife; 
  double gravity; 

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.life,
    this.gravity = 0.4,
  }) : maxLife = life;

  void update(double scalar) {
     x += vx * scalar;
     y += vy * scalar;
     
     // Gravity is an acceleration, so delta v = a * dt
     vy += gravity * scalar; 
     
     // Air resistance: v = v * (1 - drag)^scalar approx
     // Using simple linear damping equivalent for small scalar:
     // 0.98 is 1 - 0.02 drag.
     double drag = 0.02 * scalar;
     vx *= (1.0 - drag);
     vy *= (1.0 - drag);
     
     life -= 0.015 * scalar; 
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final ExplodeParticleShape shape;

  ParticlePainter(this.particles, this.shape);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    for (var particle in particles) {
      if (particle.life <= 0) continue;
      
      double opacity = (particle.life / particle.maxLife).clamp(0.0, 1.0);
      paint.color = particle.color.withOpacity((opacity * particle.color.opacity).clamp(0.0, 1.0));
      
      if (shape == ExplodeParticleShape.circle) {
         canvas.drawCircle(
           Offset(particle.x + particle.size / 2, particle.y + particle.size / 2),
           particle.size / 2, 
           paint
         );
      } else if (shape == ExplodeParticleShape.triangle) {
        final double s = particle.size;
        final Path path = Path()
          ..moveTo(particle.x + s / 2, particle.y) // Top center
          ..lineTo(particle.x + s, particle.y + s) // Bottom right
          ..lineTo(particle.x, particle.y + s) // Bottom left
          ..close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawRect(
          Rect.fromLTWH(particle.x, particle.y, particle.size, particle.size),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
