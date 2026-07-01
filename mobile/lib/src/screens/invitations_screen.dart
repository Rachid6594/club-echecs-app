import 'package:flutter/material.dart';

import '../api/api_client.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  static const routeName = '/invitations';

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  final _apiClient = ApiClient();
  late Future<List<dynamic>> _received = _apiClient.getList(
    '/app/invitations/received/',
  );
  late Future<List<dynamic>> _sent = _apiClient.getList(
    '/app/invitations/sent/',
  );

  void _reload() {
    setState(() {
      _received = _apiClient.getList('/app/invitations/received/');
      _sent = _apiClient.getList('/app/invitations/sent/');
    });
  }

  Future<void> _act(String id, String action) async {
    await _apiClient.post('/app/invitations/$id/$action/', {});
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Invitations'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Recues'),
              Tab(text: 'Envoyees'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _InvitationList(
              future: _received,
              emptyText: 'Aucune invitation recue.',
              onAction: _act,
              received: true,
            ),
            _InvitationList(
              future: _sent,
              emptyText: 'Aucune invitation envoyee.',
              onAction: _act,
              received: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitationList extends StatelessWidget {
  const _InvitationList({
    required this.future,
    required this.emptyText,
    required this.onAction,
    required this.received,
  });

  final Future<List<dynamic>> future;
  final String emptyText;
  final Future<void> Function(String id, String action) onAction;
  final bool received;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Invitations indisponibles: ${snapshot.error}'),
          );
        }
        final invitations = snapshot.data ?? [];
        if (invitations.isEmpty) return Center(child: Text(emptyText));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: invitations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final invitation = invitations[index] as Map<String, dynamic>;
            final status = invitation['status']?.toString() ?? 'pending';
            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              title: Text(
                invitation['other_display_name']?.toString() ??
                    invitation['other_username']?.toString() ??
                    'Membre',
              ),
              subtitle: Text('$status | ${invitation['message'] ?? ''}'),
              trailing: status == 'pending'
                  ? Wrap(
                      spacing: 4,
                      children: [
                        if (received)
                          IconButton(
                            tooltip: 'Accepter',
                            onPressed: () =>
                                onAction(invitation['id'].toString(), 'accept'),
                            icon: const Icon(Icons.check),
                          ),
                        if (received)
                          IconButton(
                            tooltip: 'Refuser',
                            onPressed: () =>
                                onAction(invitation['id'].toString(), 'reject'),
                            icon: const Icon(Icons.close),
                          ),
                        if (!received)
                          IconButton(
                            tooltip: 'Annuler',
                            onPressed: () =>
                                onAction(invitation['id'].toString(), 'cancel'),
                            icon: const Icon(Icons.cancel),
                          ),
                      ],
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
