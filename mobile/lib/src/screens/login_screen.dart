import 'package:flutter/material.dart';

import '../api/api_client.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiClient = ApiClient();
  var _pending = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (const bool.fromEnvironment('USE_FAKE_AUTH')) {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      return;
    }
    setState(() {
      _pending = true;
      _message = null;
    });
    try {
      await _apiClient.appLogin(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } on ApiException catch (error) {
      setState(
        () => _message =
            error.body['detail']?.toString() ?? 'Connexion impossible',
      );
    } catch (_) {
      setState(
        () => _message =
            'Connexion au serveur impossible. Verifiez internet puis reessayez.',
      );
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Mot de passe'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _pending ? null : _login,
            child: Text(_pending ? 'Connexion...' : 'Se connecter'),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_message!, style: const TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, ForgotPasswordScreen.routeName),
            child: const Text('Mot de passe oublie'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, RegisterScreen.routeName),
            child: const Text('Creer un compte'),
          ),
        ],
      ),
    );
  }
}
