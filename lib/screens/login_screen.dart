import 'package:flutter/material.dart';

import '../components/custom_button.dart';
import '../components/custom_input.dart';
import '../services/mock_api_service.dart';
import 'dashboard_screen.dart';
import 'forgot_password.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _api = const MockApiService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await _api.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş başarısız. Bilgileri kontrol edin.')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3D31B4);

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Giriş', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 36),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Hoş geldiniz',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primary),
                      ),
                      const SizedBox(height: 6),
                      const Text('Devam etmek için giriş yapın', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 34),
                      _buildIllustration(Icons.lock_person_rounded),
                      const SizedBox(height: 34),
                      CustomInput(
                        controller: _emailController,
                        label: 'E-posta',
                        hint: 'ornek@mail.com',
                        prefixIcon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => _api.validateLogin(
                          email: value?.trim() ?? '',
                          password: _passwordController.text,
                        )['email'],
                      ),
                      const SizedBox(height: 18),
                      CustomInput(
                        controller: _passwordController,
                        label: 'Şifre',
                        hint: '******',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) => _api.validateLogin(
                          email: _emailController.text.trim(),
                          password: value ?? '',
                        )['password'],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text('Şifremi unuttum?'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomButton(label: 'Giriş Yap', isLoading: _isLoading, onPressed: _isLoading ? null : _submit),
                      const SizedBox(height: 26),
                      const Icon(Icons.fingerprint_rounded, size: 58, color: primary),
                      const SizedBox(height: 6),
                      const Text('Hızlı Giriş', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Hesabınız yok mu? '),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              );
                            },
                            child: const Text('Kayıt Olun', style: TextStyle(color: primary, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0FF),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFEBEBFF), width: 2),
      ),
      child: Icon(icon, size: 52, color: const Color(0xFF3D31B4)),
    );
  }
}
