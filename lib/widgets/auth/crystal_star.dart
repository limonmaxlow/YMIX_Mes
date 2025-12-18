import 'package:flutter/material.dart';

class CrystalStar extends StatefulWidget {
  final double size;
  final double left;
  final double top;
  final Duration delay;
  final bool isSquare;

  const CrystalStar({
    super.key,
    required this.size,
    required this.left,
    required this.top,
    required this.delay,
    this.isSquare = false,
  });

  @override
  State<CrystalStar> createState() => _CrystalStarState();
}

class _CrystalStarState extends State<CrystalStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.8), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 0.2), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.2, end: 0.8), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.4), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 0.6), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.6, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
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
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.isSquare ? widget.size * 3 : widget.size * 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.white,
                      Color(0xFFB3E5FC),
                      Color(0xFF4FC3F7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: widget.isSquare 
                      ? BorderRadius.circular(6) 
                      : BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                // Для квадратных звезд делаем поворот и делаем их более вытянутыми
                child: widget.isSquare
                    ? Transform.rotate(
                        angle: 0.785, // 45 градусов
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.white,
                                Color(0xFFB3E5FC),
                                Color(0xFF4FC3F7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}