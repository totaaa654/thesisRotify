import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'home_page.dart';

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
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    // Total animation after hold (slower but clean)
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

    // TEXT slide (subtle) mostly during phase 1
    _textSlide =
        Tween<Offset>(
          begin: const Offset(0.00, 0),
          end: const Offset(0.10, 0),
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.00, 0.45, curve: Curves.easeInOutCubic),
          ),
        );

    // TEXT reveal (mask) ONLY in phase 1
    _textReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    // TEXT opacity: fade IN in phase 1, fade OUT in phase 2, stay 0 in phase 3
    _textOpacity = TweenSequence<double>([
      // fade in
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),

      // stay visible a bit
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 10),

      // fade out while logo returns center
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),

      // remain hidden
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 30),
    ]).animate(_controller);

    // TEXT blur: blur->clear in phase 1, then blur again as it disappears
    _textBlur = TweenSequence<double>([
      // blur to clear
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 16.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),

      // subtle blur while fading out
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 10.0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 25,
      ),

      // keep blurred (opacity is 0 anyway)
      TweenSequenceItem(tween: ConstantTween<double>(10.0), weight: 30),
    ]).animate(_controller);

    // HOLD logo first
    _holdTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      _controller.forward();
    });

    // Navigate after: 3s hold + 4.2s anim + buffer
    _navTimer = Timer(const Duration(milliseconds: 7600), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _navTimer?.cancel();
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
              // LOGO: left -> center -> up
              SlideTransition(
                position: _logoMove,
                child: Image.asset('assets/images/logo.png', width: 140),
              ),

              // TEXT: reveal + blur + fade, then disappears
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
