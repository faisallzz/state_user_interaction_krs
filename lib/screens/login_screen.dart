import 'package:flutter/material.dart';

import 'krs_home.dart';

/// Halaman 1: Login.
/// State lokal: _sembunyikanPassword, _sedangMemuat, _pesanError.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _sembunyikanPassword = true; // state: tampil/sembunyi password
  bool _sedangMemuat = false; // state: loading saat proses login
  String? _pesanError; // state: pesan error dari "server"

  // Akun demo
  static const _nimBenar = '2495114009';
  static const _passwordBenar = 'mahasiswa123';

  @override
  void dispose() {
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _sedangMemuat = true;
      _pesanError = null;
    });

    // Simulasi menunggu respons server
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    if (_nimController.text.trim() == _nimBenar &&
        _passwordController.text == _passwordBenar) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const KrsHome(nim: _nimBenar, nama: 'Ahmad Faizal Bahri'),
        ),
      );
    } else {
      setState(() {
        _sedangMemuat = false;
        _pesanError = 'NIM atau password salah. Periksa lagi data Anda.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.school, size: 56, color: tema.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'KRS Online',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Masuk dengan akun mahasiswa untuk mengisi KRS',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _nimController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'NIM',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'NIM wajib diisi';
                        }
                        if (int.tryParse(v.trim()) == null) {
                          return 'NIM hanya boleh berisi angka';
                        }
                        if (v.trim().length < 8) {
                          return 'NIM minimal 8 digit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _sembunyikanPassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _sembunyikanPassword
                              ? 'Tampilkan password'
                              : 'Sembunyikan password',
                          icon: Icon(_sembunyikanPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(
                              () => _sembunyikanPassword = !_sembunyikanPassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password wajib diisi';
                        }
                        if (v.length < 6) return 'Password minimal 6 karakter';
                        return null;
                      },
                    ),
                    if (_pesanError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _pesanError!,
                        style: TextStyle(color: tema.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _sedangMemuat ? null : _login,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: _sedangMemuat
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Masuk'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
