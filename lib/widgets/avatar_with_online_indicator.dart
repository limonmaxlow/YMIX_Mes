import 'package:flutter/material.dart';

class AvatarWithOnlineIndicator extends StatelessWidget {
  final String imageUrl;
  final bool isOnline;
  final double radius;

  const AvatarWithOnlineIndicator({
    super.key,
    required this.imageUrl,
    required this.isOnline,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: NetworkImage(imageUrl),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius / 2,
              height: radius / 2,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}