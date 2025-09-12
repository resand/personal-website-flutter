import 'package:flutter/material.dart';
import 'dart:math';

class ThemeTransitionOverlay extends StatefulWidget {
  final Widget child;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final ThemeMode themeMode;
  final VoidCallback? onTransitionComplete;

  const ThemeTransitionOverlay({
    super.key,
    required this.child,
    required this.lightTheme,
    required this.darkTheme,
    required this.themeMode,
    this.onTransitionComplete,
  });

  @override
  State<ThemeTransitionOverlay> createState() => _ThemeTransitionOverlayState();
}

class _ThemeTransitionOverlayState extends State<ThemeTransitionOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Offset? _tapPosition;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));


    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isTransitioning = false;
        });
        widget.onTransitionComplete?.call();
        _animationController.reset();
      }
    });
  }

  @override
  void didUpdateWidget(ThemeTransitionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeMode != widget.themeMode && !_isTransitioning) {
      _startTransition();
    }
  }

  void _startTransition() {
    setState(() {
      _isTransitioning = true;
      });
    _animationController.forward();
  }

  void startTransitionFromPosition(Offset position) {
    _tapPosition = position;
    _startTransition();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            widget.child,
            if (_isTransitioning && _tapPosition != null)
              Positioned.fill(
                child: ClipPath(
                  clipper: CircleRevealClipper(
                    center: _tapPosition!,
                    progress: _animation.value,
                  ),
                  child: Container(
                    color: _getTransitionColor(),
                    child: widget.child,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Color _getTransitionColor() {
    switch (widget.themeMode) {
      case ThemeMode.light:
        return widget.lightTheme.scaffoldBackgroundColor;
      case ThemeMode.dark:
        return widget.darkTheme.scaffoldBackgroundColor;
      case ThemeMode.system:
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark
            ? widget.darkTheme.scaffoldBackgroundColor
            : widget.lightTheme.scaffoldBackgroundColor;
    }
  }
}

class CircleRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double progress;

  CircleRevealClipper({
    required this.center,
    required this.progress,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final maxRadius = _getMaxRadius(size, center);
    final currentRadius = maxRadius * progress;

    path.addOval(Rect.fromCircle(
      center: center,
      radius: currentRadius,
    ));

    return path;
  }

  double _getMaxRadius(Size size, Offset center) {
    final double dx = center.dx > size.width / 2 
        ? center.dx 
        : size.width - center.dx;
    final double dy = center.dy > size.height / 2 
        ? center.dy 
        : size.height - center.dy;
    
    return sqrt(dx * dx + dy * dy);
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) {
    return oldClipper.center != center || oldClipper.progress != progress;
  }
}