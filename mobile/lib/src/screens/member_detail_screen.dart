import 'package:flutter/material.dart';

import '../api/api_client.dart';
import 'invitations_screen.dart';

class MemberDetailScreen extends StatefulWidget {
  const MemberDetailScreen({super.key});

  static const routeName = '/member-detail';

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  final _apiClient = ApiClient();
  String? _message;
  var _pending = false;

  Future<void> _invite(Map<String, dynamic> member) async {
    setState(() {
      _pending = true;
      _message = null;
    });
    try {
      await _apiClient.post('/app/invitations/', {
        'receiver_id': member['user_id'],
        'message': 'Invitation a jouer une partie.',
      });
      setState(() => _message = 'Invitation envoyee.');
    } on ApiException catch (error) {
      setState(() => _message =
          error.body['detail']?.toString() ?? 'Invitation impossible.');
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final member =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};
    final name = member['display_name']?.toString() ??
        member['username']?.toString() ??
        'Membre';
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 42)),
          const SizedBox(height: 16),
          Center(
              child: Text(name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700))),
          const SizedBox(height: 24),
          ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Rang'),
              subtitle: Text(member['rank_name']?.toString() ?? 'Novice I')),
          ListTile(
              leading: const Icon(Icons.scoreboard),
              title: const Text('Points'),
              subtitle: Text('${member['points'] ?? 0}')),
          ListTile(
              leading: const Icon(Icons.mail),
              title: const Text('Email'),
              subtitle: Text(member['email']?.toString() ?? '-')),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _pending || member['user_id'] == null
                ? null
                : () => _invite(member),
            icon: const Icon(Icons.mail),
            label: Text(_pending ? 'Envoi...' : 'Envoyer invitation'),
          ),
          TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, InvitationsScreen.routeName),
              child: const Text('Voir mes invitations')),
          if (_message != null)
            Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_message!)),
        ],
      ),
    );
  }
}
