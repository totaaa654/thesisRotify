import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // LOGO: left -> center -> up
  late final Animation<Offset> _logoMove;

  // TEXT
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textReveal;
  late final Animation<double> _textOpacity;
  late final Animation<double> _textBlur;

  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();

    // Total animation duration
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );

    // LOGO path: center -> left -> center -> up
    _logoMove = TweenSequence<Offset>([
      // Phase 1: go LEFT
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.75, 0),
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 45,
      ),

      // Phase 2: go BACK to center
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-0.75, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 25,
      ),

      // Phase 3: go UP
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -1.20),
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 30,
      ),
    ]).animate(_controller);

    // TEXT slide (subtle)
    _textSlide = Tween<Offset>(
      begin: const Offset(0.00, 0),
      end: const Offset(0.10, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.45, curve: Curves.easeInOutCubic),
      ),
    );

    // TEXT reveal (mask)
    _textReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    // TEXT opacity: fade IN, fade OUT, stay 0
    _textOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 10),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 30),
    ]).animate(_controller);

    // TEXT blur
    _textBlur = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 16.0, end: 0.0).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 10.0).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 25,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(10.0), weight: 30),
    ]).animate(_controller);

    // Trigger the animation sequence
    _holdTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _controller.forward();
    });
    
    // NOTE: Navigation is now handled by StreamBuilder in main.dart
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF004C22), Color(0xFF00B250)],
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SlideTransition(
                position: _logoMove,
                child: Image.asset('assets/images/logo.png', width: 140),
              ),
              SlideTransition(
                position: _textSlide,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final op = _textOpacity.value.clamp(0.0, 1.0);
                    if (op <= 0.001) return const SizedBox.shrink();

                    return Opacity(
                      opacity: op,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: _textBlur.value,
                          sigmaY: _textBlur.value,
                        ),
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: _textReveal.value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'ROTIFY',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}