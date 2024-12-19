import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'dart:math' as math;

class ParticleEffect {
  Offset position;
  double opacity;
  double size;

  ParticleEffect({
    required this.position,
    this.opacity = 1.0,
    this.size = 4.0,
  });
}

class ButterflyAnimation {
  late AnimationController flightController;
  late AnimationController particleController;
  late GifController gifController;
  final List<ParticleEffect> particles = [];
  final Random random = Random();

  final double size;
  final double verticalOffset;
  final double speed;
  final int butterfly;
  Offset position = Offset.zero;
  double angle = 0;

  static const int maxParticles = 20;
  static const double particleFadeRate = 0.02;

  ButterflyAnimation({
    required this.butterfly,
    required this.size,
    required this.verticalOffset,
    required this.speed,
  });

  void initialize(TickerProviderStateMixin vsync) {
    flightController = AnimationController(
      duration: Duration(seconds: (8 / speed).round()),
      vsync: vsync,
    );

    particleController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: vsync,
    )..addListener(updateParticles);

    gifController = GifController(vsync: vsync);

    // Start the animations
    flightController.repeat();
    particleController.repeat();
    gifController.repeat(
      min: 0,
      max: gifController.upperBound,
      period: const Duration(milliseconds: 1500),
    );
  }

  void updateParticles() {
    // Add new particles at butterfly's current position
    if (particles.length < maxParticles && random.nextDouble() < 0.3) {
      particles.add(ParticleEffect(
        position: position + Offset(
          random.nextDouble() * size - size / 2,
          random.nextDouble() * size - size / 2,
        ),
        opacity: 0.8,
        size: random.nextDouble() * 4 + 2,
      ));
    }

    // Update existing particles
    for (int i = particles.length - 1; i >= 0; i--) {
      var particle = particles[i];
      particle.opacity -= particleFadeRate;
      particle.size *= 0.95;

      // Remove faded particles
      if (particle.opacity <= 0) {
        particles.removeAt(i);
      }
    }
  }

  void dispose() {
    flightController.dispose();
    particleController.dispose();
    gifController.dispose();
  }

  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flightController,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;

        // Calculate butterfly position using parametric equations
        final t = flightController.value * math.pi * 2;
        final centerX = size.width / 2;
        final centerY = size.height * verticalOffset;

        // Create a figure-8 flight pattern
        position = Offset(
          centerX + math.sin(t * 2) * (size.width / 3),
          centerY + math.sin(t) * (size.height / 4),
        );

        // Calculate rotation angle based on movement direction
        final dx = math.cos(t * 2) * math.cos(t);
        final dy = math.cos(t) * math.sin(t);
        angle = math.atan2(dy, dx);

        return Stack(
          children: [
            // Render particles
            ...particles.map((particle) => Positioned(
              left: particle.position.dx,
              top: particle.position.dy,
              child: Opacity(
                opacity: particle.opacity,
                child: Container(
                  width: particle.size,
                  height: particle.size,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
            )),

            // Render butterfly
            Positioned(
              left: position.dx - this.size / 2,
              top: position.dy - this.size / 2,
              child: Transform.rotate(
                angle: angle,
                child: Gif(
                  controller: gifController,
                  image: AssetImage("assets/${butterfly  == 1 ? "butterfly1.gif" : "butterfly2.gif"}"),
                  width: this.size,
                  height: this.size,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}