import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      {'username': 'john_doe', 'status': 'active'},
      {'username': 'spammer99', 'status': 'blocked'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("User Management")),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(user['username']!),
              subtitle: Text("Status: ${user['status']}"),
              trailing: user['status'] == 'blocked'
                  ? IconButton(
                      icon: const Icon(Icons.lock_open, color: Colors.green),
                      onPressed: () {},
                    )
                  : IconButton(
                      icon: const Icon(Icons.block, color: Colors.red),
                      onPressed: () {},
                    ),
            ),
          );
        },
      ),
    );
  }
}
