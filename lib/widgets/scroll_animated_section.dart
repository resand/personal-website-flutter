import 'package:flutter/material.dart';

class ScrollAnimatedSection extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double slideDistance;

  const ScrollAnimatedSection({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.slideDistance = 30.0,
  });

  @override
  State<ScrollAnimatedSection> createState() => _ScrollAnimatedSectionState();
}

class _ScrollAnimatedSectionState extends State<ScrollAnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.slideDistance / 50),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    ));

    // Start animation with a small delay to avoid layout issues
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && !_hasAnimated) {
        _hasAnimated = true;
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class StaggeredScrollAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration animationDuration;
  final Curve curve;
  final Axis direction;

  const StaggeredScrollAnimation({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.direction = Axis.vertical,
  });

  @override
  State<StaggeredScrollAnimation> createState() => _StaggeredScrollAnimationState();
}

class _StaggeredScrollAnimationState extends State<StaggeredScrollAnimation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return ScrollAnimatedSection(
          duration: widget.animationDuration + (widget.staggerDelay * index),
          curve: widget.curve,
          slideDistance: widget.direction == Axis.vertical ? 30.0 : 0.0,
          child: child,
        );
      }).toList(),
    );
  }
}

class ParallaxScrollSection extends StatelessWidget {
  final Widget child;

  const ParallaxScrollSection({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollAnimatedSection(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      child: child,
    );
  }
}