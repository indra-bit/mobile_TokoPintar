import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      final success = await auth.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!success && mounted) {
        final errorMsg = auth.lastErrorMessage ?? 'Periksa kembali email dan password Anda.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal: $errorMsg')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFC3CFE2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF4A90E2), Color(0xFF87CEEB)],
                            ),
                          ),
                          child: const Icon(
                            Icons.storefront,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Smart Mart',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A90E2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Silakan login ke akun Anda',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 48),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.email, color: Color(0xFF4A90E2)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty || !value.contains('@')) {
                              return 'Masukkan email yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.lock, color: Color(0xFF4A90E2)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('LOGIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
