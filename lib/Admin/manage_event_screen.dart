import 'package:flutter/material.dart';

class ManageEventScreen extends StatelessWidget {
  final String? eventTitle;
  const ManageEventScreen({super.key, this.eventTitle});

  void _showConfirmationDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm $action"),
        content: Text("Are you sure you want to $action this event?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(action),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage: $eventTitle")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text("Edit Event"),
            onPressed: () {},
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.people),
            label: const Text("View Bookings"),
            onPressed: () {},
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: const Text("Delete Event"),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => _showConfirmationDialog(context, "delete"),
          ),
        ],
      ),
    );
  }
}
