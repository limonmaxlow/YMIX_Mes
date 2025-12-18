import 'package:flutter/material.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Внешний вид'),
      ),
      body: const Center(
        child: Text('Экран внешнего вида - в разработке'),
      ),
    );
  }
}
