import 'package:flutter/material.dart';

import '../api/api_client.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const routeName = '/forgot-password';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _apiClient = ApiClient();
  var _pending = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _pending = true;
      _message = null;
    });
    try {
      final response = await _apiClient.post('/app/auth/forgot-password/', {
        'email': _emailController.text,
      });
      setState(
        () => _message = response['detail']?.toString() ?? 'Demande envoyee.',
      );
    } on ApiException catch (error) {
      setState(
        () => _message =
            error.body['detail']?.toString() ?? 'Demande impossible.',
      );
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublie')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Saisis ton email. Un administrateur pourra traiter la demande de reinitialisation.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _pending ? null : _submit,
            child: Text(_pending ? 'Envoi...' : 'Envoyer'),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_message!),
            ),
        ],
      ),
    );
  }
}
