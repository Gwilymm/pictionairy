import 'package:flutter/material.dart';

class AnimatedBubble extends StatefulWidget {
  final double size;
  final double initialTop;
  final double left;
  final double opacity;
  final VoidCallback onPopped;
  final VoidCallback onAnimationEnd;
  final bool isPoppable; // Indique si la bulle peut être éclatée

  const AnimatedBubble({
    Key? key,
    required this.size,
    required this.initialTop,
    required this.left,
    required this.opacity,
    required this.onPopped,
    required this.onAnimationEnd,
    this.isPoppable = false, // Par défaut, non éclatable
  }) : super(key: key);

  @override
  _AnimatedBubbleState createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<AnimatedBubble> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPopped = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _positionAnimation = Tween<double>(
      begin: widget.initialTop,
      end: -100,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _opacityAnimation = Tween<double>(
      begin: widget.opacity,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isPopped) {
        widget.onAnimationEnd();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!_isPopped && widget.isPoppable) {
      setState(() {
        _isPopped = true;
      });

      widget.onPopped();
      widget.onAnimationEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isPopped) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _positionAnimation.value,
          left: widget.left,
          child: GestureDetector(
            onTap: _onTap,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
