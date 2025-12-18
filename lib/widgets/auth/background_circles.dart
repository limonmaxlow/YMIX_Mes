import 'package:flutter/material.dart';

class BackgroundCircles extends StatelessWidget {
  const BackgroundCircles({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1C2840).withOpacity(0.3),
            ),
          ),
        ),
        Positioned(
          top: 100,
          right: -30,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4F74B9).withOpacity(0.2),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: 100,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF9747FF).withOpacity(0.15),
            ),
          ),
        ),
      ],
    );
  }
}