import 'package:flutter/material.dart';

class ReportBlockScreen extends StatefulWidget {
  const ReportBlockScreen({super.key});

  @override
  State<ReportBlockScreen> createState() => _ReportBlockScreenState();
}

class _ReportBlockScreenState extends State<ReportBlockScreen> {
  String selectedFilter = 'All';

  final mockReports = [
    {
      'id': '1',
      'reportedBy': 'User123',
      'reportedByAvatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      'target': 'Event: Summer Music Festival',
      'targetType': 'Event',
      'reason': 'Inappropriate content',
      'status': 'Pending',
      'date': '2 hours ago',
      'severity': 'High',
      'description': 'Event contains inappropriate images and misleading information about venue location.'
    },
    {
      'id': '2',
      'reportedBy': 'User456',
      'reportedByAvatar': 'https://images.unsplash.com/photo-1494790108755-2616b932c1b3?w=100&h=100&fit=crop&crop=face',
      'target': 'User: spammer12',
      'targetType': 'User',
      'reason': 'Spamming chat',
      'status': 'Resolved',
      'date': '1 day ago',
      'severity': 'Medium',
      'description': 'User has been sending repetitive promotional messages in event chats.'
    },
    {
      'id': '3',
      'reportedBy': 'User789',
      'reportedByAvatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      'target': 'Event: Tech Conference 2025',
      'targetType': 'Event',
      'reason': 'Fraud/Scam',
      'status': 'Under Review',
      'date': '3 days ago',
      'severity': 'Critical',
      'description': 'Suspected fake event with requests for advance payments without proper verification.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Reports & Moderation", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Stats Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn("Total Reports", "${mockReports.length}", Icons.report),
                _buildStatColumn("Pending", "${mockReports.where((r) => r['status'] == 'Pending').length}", Icons.pending),
                _buildStatColumn("Resolved", "${mockReports.where((r) => r['status'] == 'Resolved').length}", Icons.check_circle),
              ],
            ),
          ),

          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'Pending', 'Under Review', 'Resolved'].map((filter) {
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

          // Reports List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mockReports.length,
              itemBuilder: (context, index) {
                final report = mockReports[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(report['reportedByAvatar'] as String),
                              onBackgroundImageError: (_, __) {},
                              child: const Icon(Icons.person, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report['reportedBy'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    report['date'] as String,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            _buildSeverityBadge(report['severity'] as String),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Target and Reason
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    report['targetType'] == 'Event' ? Icons.event : Icons.person,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    report['target'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Reason: ${report['reason']}",
                                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                report['description'] as String,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Status and Actions
                        Row(
                          children: [
                            _buildStatusChip(report['status'] as String),
                            const Spacer(),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.visibility, size: 16),
                              label: const Text("Review"),
                              onPressed: () {
                                _showReportDetails(context, report);
                              },
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.gavel, size: 16),
                              label: const Text("Action"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                _showActionDialog(context, report);
                              },
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

  Widget _buildSeverityBadge(String severity) {
    Color color;
    switch (severity.toLowerCase()) {
      case 'critical':
        color = Colors.red;
        break;
      case 'high':
        color = Colors.orange;
        break;
      case 'medium':
        color = Colors.yellow[700]!;
        break;
      default:
        color = Colors.green;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        severity,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'resolved':
        color = Colors.green;
        break;
      case 'under review':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Report Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Target: ${report['target']}"),
            Text("Reported by: ${report['reportedBy']}"),
            Text("Reason: ${report['reason']}"),
            const SizedBox(height: 8),
            Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(report['description'] as String),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  void _showActionDialog(BuildContext context, Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Take Action"),
        content: const Text("Choose an action for this report:"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Dismiss")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Content blocked: ${report['target']}")),
              );
            },
            child: const Text("Block Content", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}