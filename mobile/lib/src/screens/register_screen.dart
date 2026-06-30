import 'package:flutter/material.dart';

import '../api/api_client.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiClient = ApiClient();
  var _pending = false;
  String? _message;

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (const bool.fromEnvironment('USE_FAKE_AUTH')) {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      return;
    }
    setState(() {
      _pending = true;
      _message = null;
    });
    try {
      await _apiClient.appRegister(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _displayNameController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } on ApiException catch (error) {
      setState(() => _message = error.body['detail']?.toString() ?? 'Inscription impossible');
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Nom utilisateur')),
          const SizedBox(height: 12),
          TextField(controller: _displayNameController, decoration: const InputDecoration(labelText: 'Nom affiche')),
          const SizedBox(height: 12),
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe')),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _pending ? null : _register,
            child: Text(_pending ? 'Creation...' : 'Creer mon compte'),
          ),
          if (_message != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_message!, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}

