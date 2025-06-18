import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Organizer Profile"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Boosted Events"),
              Tab(text: "Comments"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBoostedEventsTab(),
            _buildCommentsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildBoostedEventsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (_, index) => const Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: Text("Boosted Event Name"),
          subtitle: Text("Some description of event"),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }

  Widget _buildCommentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (_, index) => const Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: Text("User Comment"),
          subtitle: Text("Very well organized and fun!"),
          leading: Icon(Icons.comment),
        ),
      ),
    );
  }
}
