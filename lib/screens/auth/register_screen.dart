import 'package:flutter/material.dart';
import 'package:ymix_messenger/routes/app_routes.dart';
import 'package:ymix_messenger/theme/app_theme.dart';
import 'package:ymix_messenger/widgets/auth/background_circles.dart';
import 'package:ymix_messenger/widgets/auth/animated_button.dart';
import 'package:ymix_messenger/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  void _register() async {
    if (_isLoading) return;
    
    final nickname = _nicknameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    
    // Валидация
    if (nickname.isEmpty || phone.isEmpty || email.isEmpty || 
        password.isEmpty || confirmPassword.isEmpty) {
      _showError('Заполните все поля');
      return;
    }

    if (password != confirmPassword) {
      _showError('Пароли не совпадают');
      return;
    }

    if (phone.length != 10) {
      _showError('Номер телефона должен содержать 10 цифр');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.register(
        username: nickname,
        email: email,
        phoneNumber: phone,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (result['success'] == true) {
        // Успешная регистрация - переходим к списку чатов
        Navigator.pushReplacementNamed(context, AppRoutes.chatList);
      } else {
        _showError(result['message'] ?? 'Ошибка регистрации');
      }
    } catch (e) {
      _showError('Ошибка соединения: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: AppTheme.darkBlue),
          const BackgroundCircles(),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    SlideTransition(
                      position: _slideAnimation,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _isLoading ? () {} : _goToLogin,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Регистрация',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0x14FFFFFF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0x26FFFFFF)),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0x0DFFFFFF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0x1AFFFFFF)),
                                  ),
                                  child: TextField(
                                    controller: _nicknameController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: 'Введите никнейм',
                                      hintStyle: TextStyle(color: Colors.white54),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0x0DFFFFFF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0x1AFFFFFF)),
                                  ),
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: 'Введите телефон (10 цифр)',
                                      hintStyle: TextStyle(color: Colors.white54),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0x0DFFFFFF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0x1AFFFFFF)),
                                  ),
                                  child: TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: 'Введите почту',
                                      hintStyle: TextStyle(color: Colors.white54),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0x0DFFFFFF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0x1AFFFFFF)),
                                  ),
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: 'Введите пароль',
                                      hintStyle: TextStyle(color: Colors.white54),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0x0DFFFFFF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0x1AFFFFFF)),
                                  ),
                                  child: TextField(
                                    controller: _confirmPasswordController,
                                    obscureText: true,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: 'Подтвердите пароль',
                                      hintStyle: TextStyle(color: Colors.white54),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    onSubmitted: (_) => _register(),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                AnimatedButton(
                                  text: _isLoading ? 'Регистрация...' : 'Зарегистрироваться',
                                  onPressed: _isLoading ? () {} : _register,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}