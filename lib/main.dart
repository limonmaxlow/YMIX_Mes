import 'package:flutter/material.dart';
import 'package:ymix_messenger/screens/auth/forgot_password_screen.dart';
import 'package:ymix_messenger/screens/auth/login_screen.dart';
import 'package:ymix_messenger/screens/auth/register_screen.dart';
import 'package:ymix_messenger/screens/main_app/chat_list_screen.dart';
import 'package:ymix_messenger/screens/main_app/profile_screen.dart';
import 'package:ymix_messenger/screens/main_app/shop_screen.dart';
import 'package:ymix_messenger/screens/splash_screen.dart';
import 'package:ymix_messenger/models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Временный пользователь для демонстрации
    final demoUser = User(
      id: '1',
      name: 'Demo User',
      username: '@demo',
      points: 1000,
      inventory: [],
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YMIX Messenger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/chat-list': (context) => const ChatListScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/shop': (context) => ShopScreen(
              user: demoUser,
              onUserUpdate: (user) {
                // Обработка обновления пользователя
              },
            ),
      },
    );
  }
}