import 'package:flutter/material.dart';

class ReportBlockScreen extends StatelessWidget {
  const ReportBlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockReports = [
      {'reportedBy': 'User123', 'target': 'Event: Music Fest', 'reason': 'Inappropriate content'},
      {'reportedBy': 'User456', 'target': 'User: spammer12', 'reason': 'Spamming chat'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Report & Block Management")),
      body: ListView.builder(
        itemCount: mockReports.length,
        itemBuilder: (context, index) {
          final report = mockReports[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ListTile(
              leading: const Icon(Icons.report_gmailerrorred, color: Colors.orange),
              title: Text(report['target']!),
              subtitle: Text("By: ${report['reportedBy']}\nReason: ${report['reason']}"),
              isThreeLine: true,
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(Icons.block, color: Colors.red),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
