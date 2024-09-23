// lib/utils/animated_bubble.dart
import 'package:flutter/material.dart';

class AnimatedBubble extends StatefulWidget {
  final double size;
  final double initialTop;
  final double left;
  final double opacity;

  const AnimatedBubble({
    Key? key,
    required this.size,
    required this.initialTop,
    required this.left,
    required this.opacity,
  }) : super(key: key);

  @override
  _AnimatedBubbleState createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<AnimatedBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: false);

    _positionAnimation = Tween<double>(
      begin: widget.initialTop,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: widget.opacity, end: widget.opacity * 0.5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: widget.opacity * 0.5, end: widget.opacity), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _sizeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: widget.size, end: widget.size * 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: widget.size * 1.2, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addListener(() {
      if (_controller.isCompleted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.left,
          top: _positionAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: _sizeAnimation.value,
              height: _sizeAnimation.value,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}