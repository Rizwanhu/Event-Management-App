import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';

  final users = [
    {
      'id': '1',
      'username': 'john_doe',
      'email': 'john@example.com',
      'fullName': 'John Doe',
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      'status': 'active',
      'joinDate': 'Jan 15, 2024',
      'eventsCreated': 12,
      'lastActive': '2 hours ago',
      'verified': true,
      'role': 'User'
    },
    {
      'id': '2',
      'username': 'sarah_admin',
      'email': 'sarah@example.com',
      'fullName': 'Sarah Wilson',
      'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b932c1b3?w=100&h=100&fit=crop&crop=face',
      'status': 'active',
      'joinDate': 'Nov 20, 2023',
      'eventsCreated': 45,
      'lastActive': '1 hour ago',
      'verified': true,
      'role': 'Admin'
    },
    {
      'id': '3',
      'username': 'spammer99',
      'email': 'spam@fake.com',
      'fullName': 'Spam User',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      'status': 'blocked',
      'joinDate': 'Dec 10, 2024',
      'eventsCreated': 0,
      'lastActive': '2 days ago',
      'verified': false,
      'role': 'User'
    },
    {
      'id': '4',
      'username': 'event_organizer',
      'email': 'organizer@events.com',
      'fullName': 'Mike Johnson',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face',
      'status': 'suspended',
      'joinDate': 'Sep 5, 2023',
      'eventsCreated': 28,
      'lastActive': '1 week ago',
      'verified': true,
      'role': 'Organizer'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((user) {
  final matchesFilter = selectedFilter == 'All' || user['status'] == selectedFilter.toLowerCase();
  final matchesSearch = (user['username'] as String).toLowerCase().contains(searchQuery.toLowerCase()) ||
                        (user['fullName'] as String).toLowerCase().contains(searchQuery.toLowerCase());
  return matchesFilter && matchesSearch;
}).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("User Management", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Header Stats
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn("Total Users", "${users.length}", Icons.people),
                _buildStatColumn("Active", "${users.where((u) => u['status'] == 'active').length}", Icons.check_circle),
                _buildStatColumn("Blocked", "${users.where((u) => u['status'] == 'blocked').length}", Icons.block),
              ],
            ),
          ),

          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'Active', 'Blocked', 'Suspended'].map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: selectedFilter == filter,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    selectedColor: Colors.blue.withOpacity(0.2),
                  ),
                );
              }).toList(),
            ),
          ),

          // Users List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Avatar with Status Indicator
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(user['avatar'] as String),
                              onBackgroundImageError: (_, __) {},
                              child: const Icon(Icons.person, size: 30),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(user['status'] as String),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user['fullName'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (user['verified'] as bool) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                                  ],
                                  const SizedBox(width: 8),
                                  _buildRoleBadge(user['role'] as String),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@${user['username']}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                              Text(
                                user['email'] as String,
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.event, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${user['eventsCreated']} events",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    user['lastActive'] as String,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Action Buttons
                        Column(
                          children: [
                            _buildStatusChip(user['status'] as String),
                            const SizedBox(height: 8),
                            PopupMenuButton<String>(
                              onSelected: (action) => _handleUserAction(context, user, action),
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'view', child: Text('View Profile')),
                                const PopupMenuItem(value: 'edit', child: Text('Edit User')),
                                PopupMenuItem(
                                  value: user['status'] == 'blocked' ? 'unblock' : 'block',
                                  child: Text(user['status'] == 'blocked' ? 'Unblock' : 'Block'),
                                ),
                                if (user['status'] != 'suspended')
                                  const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.more_vert, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color;
    switch (role.toLowerCase()) {
      case 'admin':
        color = Colors.purple;
        break;
      case 'organizer':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'blocked':
        return Colors.red;
      case 'suspended':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _handleUserAction(BuildContext context, Map<String, dynamic> user, String action) {
    switch (action) {
      case 'view':
        _showUserProfile(context, user);
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Edit ${user['username']}")),
        );
        break;
      case 'block':
      case 'unblock':
        _showConfirmDialog(context, action, user);
        break;
      case 'suspend':
        _showConfirmDialog(context, action, user);
        break;
      case 'delete':
        _showConfirmDialog(context, action, user);
        break;
    }
  }

  void _showUserProfile(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${user['fullName']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Username: @${user['username']}"),
            Text("Email: ${user['email']}"),
            Text("Role: ${user['role']}"),
            Text("Joined: ${user['joinDate']}"),
            Text("Events Created: ${user['eventsCreated']}"),
            Text("Last Active: ${user['lastActive']}"),
            Text("Status: ${user['status']}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, String action, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action User"),
        content: Text("Are you sure you want to $action ${user['username']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${user['username']} has been ${action}ed")),
              );
            },
            child: Text(action.toUpperCase(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}