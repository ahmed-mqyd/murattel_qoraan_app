// Enhanced FadeIn widget with slide, scale and fade animations
import 'package:flutter/material.dart';

class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double slideOffset;
  final double horizontalOffset;
  final double startScale;

  const FadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.slideOffset = 20.0,
    this.horizontalOffset = 0.0,
    this.startScale = 0.96,
  });

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> {
  bool _isVisible = false;
  late Future<void> delayFuture;

  @override
  void initState() {
    super.initState();
    delayFuture = Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return Opacity(
        opacity: 0.0,
        child: widget.child,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: widget.duration,
      curve: widget.curve,
      builder: (context, value, child) {
        final double opacity = value;
        final double currentSlide = (1.0 - value) * widget.slideOffset;
        final double currentHoriz = (1.0 - value) * widget.horizontalOffset;
        final double currentScale = widget.startScale + (value * (1.0 - widget.startScale));

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(currentHoriz, currentSlide),
            child: Transform.scale(
              scale: currentScale,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
