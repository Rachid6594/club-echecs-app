import 'package:flutter/material.dart';

import '../api/api_client.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static const routeName = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final Future<List<dynamic>> _notifications = ApiClient().getList(
    '/app/notifications/',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder<List<dynamic>>(
        future: _notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Notifications indisponibles: ${snapshot.error}'),
            );
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(
              child: Text('Aucune notification dans Supabase.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notification = notifications[index] as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(
                  notification['title']?.toString() ??
                      notification['type']?.toString() ??
                      'Notification',
                ),
                subtitle: Text(notification['body']?.toString() ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
