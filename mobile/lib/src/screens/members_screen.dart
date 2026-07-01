import 'package:flutter/material.dart';

import '../api/api_client.dart';
import 'member_detail_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  static const routeName = '/members';

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  late final Future<List<dynamic>> _members =
      ApiClient().getList('/app/members/');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membres du club')),
      body: FutureBuilder<List<dynamic>>(
        future: _members,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Membres indisponibles: ${snapshot.error}'));
          }
          final members = snapshot.data ?? [];
          if (members.isEmpty) {
            return const Center(child: Text('Aucun membre dans Supabase.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final member = members[index] as Map<String, dynamic>;
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFE2E8F0))),
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(member['display_name']?.toString() ??
                    member['username']?.toString() ??
                    'Membre'),
                subtitle:
                    Text('${member['rank_name']} | ${member['points']} pts'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(
                    context, MemberDetailScreen.routeName,
                    arguments: member),
              );
            },
          );
        },
      ),
    );
  }
}
