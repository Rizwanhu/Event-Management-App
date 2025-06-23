import 'package:flutter/material.dart';
import 'analytics_dashboard.dart';
import 'event_moderation_screen.dart';
import 'boost_management_screen.dart';
import 'report_block_screen.dart';
import 'user_management_screen.dart';
import '../User/Event/comments_page.dart';
import '/../Event_Organizer/EventAnalytics.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _DashboardItem(
          "Analytics Dashboard", Icons.bar_chart, const AnalyticsDashboard()),
      _DashboardItem("Event Moderation", Icons.event_available,
          const EventModerationScreen()),
      _DashboardItem("Boost Revenue", Icons.monetization_on,
          const BoostManagementScreen()),
      _DashboardItem("Report/Block", Icons.report, const ReportBlockScreen()),
      _DashboardItem("User Management", Icons.supervisor_account,
          const UserManagementScreen()),
      _DashboardItem("Comments", Icons.comment, const CommentsPage()),
      _DashboardItem(
  "Analytics",
  Icons.analytics,
  EventAnalyticsScreen(
    eventId: 'demoEvent123',
    eventTitle: 'Demo Event',
  ),
),


    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: tiles.length,
        itemBuilder: (_, index) {
          final item = tiles[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item.screen),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 7,
              color: const Color.fromARGB(255, 115, 224, 224),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 40),
                    const SizedBox(height: 10),
                    Text(item.title, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Widget screen;
  _DashboardItem(this.title, this.icon, this.screen);
}
