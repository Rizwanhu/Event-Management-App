import 'package:flutter/material.dart';
import 'analytics_dashboard.dart';
import 'event_moderation_screen.dart'; // This is now the organizer management screen
import 'event_approval_screen.dart';
import 'boost_management_screen.dart';
import 'report_block_screen.dart';
import 'user_management_screen.dart';
import 'notifications_screen.dart';
import '../User/Event/comments_page.dart';
import '/../Event_Organizer/EventAnalytics.dart';
import '../Firebase/auth_service.dart';
import '../Login.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      // Show confirmation dialog
      bool? shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Logout'),
              ),
            ],
          );
        },
      );

      if (shouldLogout == true) {
        // Show loading indicator
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        }

        // Perform logout
        final authService = FirebaseAuthService();
        await authService.signOut();

        // Navigate to login screen and clear navigation stack
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      // Hide loading dialog if it's showing
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _DashboardItem(
          "Analytics Dashboard", Icons.bar_chart, const AnalyticsDashboard()),
      _DashboardItem("Organizer Management", Icons.business,
          const EventOrganizerModerationScreen()),
      _DashboardItem("Event Approval", Icons.event_available,
          const EventModerationScreen()),
      _DashboardItem("Notifications", Icons.notifications,
          const AdminNotificationsScreen()),
      _DashboardItem("Boost Revenue", Icons.monetization_on,
          const BoostManagementScreen()),
      _DashboardItem("Report/Block", Icons.report, const ReportBlockScreen()),
      _DashboardItem("User Management", Icons.supervisor_account,
          const UserManagementScreen()),
      //_DashboardItem("Comments", Icons.comment, const CommentsPage()),
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
      appBar: AppBar(
        title: const Text("Admin Panel"),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
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
