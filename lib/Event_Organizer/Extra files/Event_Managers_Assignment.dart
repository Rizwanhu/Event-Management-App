// import 'package:flutter/material.dart';

// class EventManagersAssignmentScreen extends StatefulWidget {
//   final String eventId;
//   final String eventTitle;

//   const EventManagersAssignmentScreen({
//     Key? key,
//     required this.eventId,
//     required this.eventTitle,
//   }) : super(key: key);

//   @override
//   State<EventManagersAssignmentScreen> createState() => _EventManagersAssignmentScreenState();
// }

// class _EventManagersAssignmentScreenState extends State<EventManagersAssignmentScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool isLoading = false;

//   // Role definitions with permissions
//   final Map<String, Map<String, dynamic>> roleDefinitions = {
//     'Host': {
//       'icon': Icons.person_pin,
//       'color': Colors.purple,
//       'description': 'Full event management and presentation duties',
//       'permissions': [
//         'Event presentation',
//         'Attendee interaction',
//         'Schedule management',
//         'Live announcements',
//         'Q&A moderation',
//       ],
//       'dashboardAccess': [
//         'Event overview',
//         'Attendee list (view only)',
//         'Schedule management',
//         'Announcements',
//       ]
//     },
//     'Ticket Checker': {
//       'icon': Icons.qr_code_scanner,
//       'color': Colors.blue,
//       'description': 'Check-in management and ticket validation',
//       'permissions': [
//         'Scan QR codes',
//         'Check-in attendees',
//         'Validate tickets',
//         'View attendee details',
//         'Manual check-in',
//       ],
//       'dashboardAccess': [
//         'Check-in scanner',
//         'Attendee search',
//         'Check-in statistics',
//         'Problem resolution',
//       ]
//     },
//     'Media Manager': {
//       'icon': Icons.photo_camera,
//       'color': Colors.green,
//       'description': 'Content creation and social media management',
//       'permissions': [
//         'Upload photos/videos',
//         'Manage event gallery',
//         'Social media posting',
//         'Live streaming setup',
//         'Content moderation',
//       ],
//       'dashboardAccess': [
//         'Media upload',
//         'Gallery management',
//         'Social media tools',
//         'Live stream controls',
//       ]
//     },
//   };

//   // Sample assigned managers data
//   List<Map<String, dynamic>> assignedManagers = [
//     {
//       'id': '1',
//       'name': 'Sarah Johnson',
//       'email': 'sarah.johnson@email.com',
//       'role': 'Host',
//       'phone': '+1234567890',
//       'status': 'active',
//       'assignedDate': '2024-03-10',
//       'lastAccess': '2024-03-15 14:30',
//     },
//     {
//       'id': '2',
//       'name': 'Mike Wilson',
//       'email': 'mike.wilson@email.com',
//       'role': 'Ticket Checker',
//       'phone': '+1234567891',
//       'status': 'active',
//       'assignedDate': '2024-03-12',
//       'lastAccess': '2024-03-15 09:15',
//     },
//     {
//       'id': '3',
//       'name': 'Emily Davis',
//       'email': 'emily.davis@email.com',
//       'role': 'Media Manager',
//       'phone': '+1234567892',
//       'status': 'pending',
//       'assignedDate': '2024-03-14',
//       'lastAccess': null,
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Managers - ${widget.eventTitle}'),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_add),
//             onPressed: _showAddManagerDialog,
//           ),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           indicatorColor: Colors.white,
//           tabs: const [
//             Tab(icon: Icon(Icons.people), text: 'Assigned'),
//             Tab(icon: Icon(Icons.admin_panel_settings), text: 'Roles'),
//             Tab(icon: Icon(Icons.dashboard), text: 'Dashboards'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildAssignedManagersTab(),
//           _buildRolesTab(),
//           _buildDashboardsTab(),
//         ],
//       ),
//     );
//   }

//   Widget _buildAssignedManagersTab() {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16.0),
//           color: Colors.grey[100],
//           child: Row(
//             children: [
//               Expanded(
//                 child: _buildManagerStats('Total', assignedManagers.length.toString()),
//               ),
//               Expanded(
//                 child: _buildManagerStats('Active', 
//                     assignedManagers.where((m) => m['status'] == 'active').length.toString()),
//               ),
//               Expanded(
//                 child: _buildManagerStats('Pending', 
//                     assignedManagers.where((m) => m['status'] == 'pending').length.toString()),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.all(16.0),
//             itemCount: assignedManagers.length,
//             itemBuilder: (context, index) {
//               final manager = assignedManagers[index];
//               return _buildManagerCard(manager, index);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildManagerStats(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: Colors.deepPurple,
//           ),
//         ),
//         Text(
//           label,
//           style: Theme.of(context).textTheme.bodySmall,
//         ),
//       ],
//     );
//   }

//   Widget _buildManagerCard(Map<String, dynamic> manager, int index) {
//     final roleData = roleDefinitions[manager['role']]!;
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: roleData['color'],
//           child: Icon(
//             roleData['icon'],
//             color: Colors.white,
//           ),
//         ),
//         title: Text(
//           manager['name'],
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(manager['email']),
//             Text('Role: ${manager['role']}'),
//             Row(
//               children: [
//                 Icon(
//                   manager['status'] == 'active' ? Icons.circle : Icons.pending,
//                   size: 12,
//                   color: manager['status'] == 'active' ? Colors.green : Colors.orange,
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   manager['status'].toString().toUpperCase(),
//                   style: TextStyle(
//                     color: manager['status'] == 'active' ? Colors.green : Colors.orange,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         trailing: PopupMenuButton<String>(
//           onSelected: (value) => _handleManagerAction(value, manager, index),
//           itemBuilder: (context) => [
//             const PopupMenuItem(
//               value: 'view',
//               child: Row(
//                 children: [
//                   Icon(Icons.visibility),
//                   SizedBox(width: 8),
//                   Text('View Details'),
//                 ],
//               ),
//             ),
//             const PopupMenuItem(
//               value: 'dashboard',
//               child: Row(
//                 children: [
//                   Icon(Icons.dashboard),
//                   SizedBox(width: 8),
//                   Text('View Dashboard'),
//                 ],
//               ),
//             ),
//             const PopupMenuItem(
//               value: 'edit',
//               child: Row(
//                 children: [
//                   Icon(Icons.edit),
//                   SizedBox(width: 8),
//                   Text('Edit Role'),
//                 ],
//               ),
//             ),
//             const PopupMenuItem(
//               value: 'remove',
//               child: Row(
//                 children: [
//                   Icon(Icons.delete, color: Colors.red),
//                   SizedBox(width: 8),
//                   Text('Remove'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         isThreeLine: true,
//       ),
//     );
//   }

//   Widget _buildRolesTab() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16.0),
//       itemCount: roleDefinitions.length,
//       itemBuilder: (context, index) {
//         final entry = roleDefinitions.entries.elementAt(index);
//         return _buildRoleCard(entry.key, entry.value);
//       },
//     );
//   }

//   Widget _buildRoleCard(String roleName, Map<String, dynamic> roleData) {
//     final assignedCount = assignedManagers.where((m) => m['role'] == roleName).length;
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   roleData['icon'],
//                   color: roleData['color'],
//                   size: 32,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         roleName,
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: roleData['color'],
//                         ),
//                       ),
//                       Text(
//                         roleData['description'],
//                         style: Theme.of(context).textTheme.bodyMedium,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: roleData['color'].withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: roleData['color']),
//                   ),
//                   child: Text(
//                     '$assignedCount assigned',
//                     style: TextStyle(
//                       color: roleData['color'],
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Permissions:',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               runSpacing: 4,
//               children: roleData['permissions'].map<Widget>((permission) => Chip(
//                 label: Text(
//                   permission,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 backgroundColor: roleData['color'].withOpacity(0.1),
//                 side: BorderSide(color: roleData['color'].withOpacity(0.3)),
//               )).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDashboardsTab() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16.0),
//       itemCount: roleDefinitions.length,
//       itemBuilder: (context, index) {
//         final entry = roleDefinitions.entries.elementAt(index);
//         return _buildDashboardPreviewCard(entry.key, entry.value);
//       },
//     );
//   }

//   Widget _buildDashboardPreviewCard(String roleName, Map<String, dynamic> roleData) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   roleData['icon'],
//                   color: roleData['color'],
//                   size: 24,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   '$roleName Dashboard',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const Spacer(),
//                 ElevatedButton(
//                   onPressed: () => _previewDashboard(roleName),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: roleData['color'],
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   ),
//                   child: const Text('Preview'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Dashboard Features:',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             ...roleData['dashboardAccess'].map<Widget>((feature) => Padding(
//               padding: const EdgeInsets.only(bottom: 4),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.dashboard,
//                     size: 16,
//                     color: roleData['color'],
//                   ),
//                   const SizedBox(width: 8),
//                   Text(feature),
//                 ],
//               ),
//             )).toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showAddManagerDialog() {
//     final nameController = TextEditingController();
//     final emailController = TextEditingController();
//     final phoneController = TextEditingController();
//     String selectedRole = 'Host';

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Add Manager'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Full Name',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: phoneController,
//                 decoration: const InputDecoration(
//                   labelText: 'Phone',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: selectedRole,
//                 decoration: const InputDecoration(
//                   labelText: 'Role',
//                   border: OutlineInputBorder(),
//                 ),
//                 items: roleDefinitions.keys.map((role) => DropdownMenuItem(
//                   value: role,
//                   child: Row(
//                     children: [
//                       Icon(
//                         roleDefinitions[role]!['icon'],
//                         color: roleDefinitions[role]!['color'],
//                         size: 20,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(role),
//                     ],
//                   ),
//                 )).toList(),
//                 onChanged: (value) {
//                   selectedRole = value!;
//                 },
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
//                 setState(() {
//                   assignedManagers.add({
//                     'id': DateTime.now().millisecondsSinceEpoch.toString(),
//                     'name': nameController.text,
//                     'email': emailController.text,
//                     'phone': phoneController.text,
//                     'role': selectedRole,
//                     'status': 'pending',
//                     'assignedDate': DateTime.now().toString().substring(0, 10),
//                     'lastAccess': null,
//                   });
//                 });
//                 Navigator.of(context).pop();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('${nameController.text} added as $selectedRole')),
//                 );
//               }
//             },
//             child: const Text('Add Manager'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleManagerAction(String action, Map<String, dynamic> manager, int index) {
//     switch (action) {
//       case 'view':
//         _showManagerDetails(manager);
//         break;
//       case 'dashboard':
//         _previewDashboard(manager['role']);
//         break;
//       case 'edit':
//         _editManagerRole(manager, index);
//         break;
//       case 'remove':
//         _removeManager(manager, index);
//         break;
//     }
//   }

//   void _showManagerDetails(Map<String, dynamic> manager) {
//     final roleData = roleDefinitions[manager['role']]!;
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(manager['name']),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Email: ${manager['email']}'),
//             Text('Phone: ${manager['phone']}'),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Icon(roleData['icon'], color: roleData['color'], size: 20),
//                 const SizedBox(width: 8),
//                 Text('Role: ${manager['role']}'),
//               ],
//             ),
//             Text('Status: ${manager['status']}'),
//             Text('Assigned: ${manager['assignedDate']}'),
//             if (manager['lastAccess'] != null)
//               Text('Last Access: ${manager['lastAccess']}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _editManagerRole(Map<String, dynamic> manager, int index) {
//     String selectedRole = manager['role'];
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Edit ${manager['name']}\'s Role'),
//         content: DropdownButtonFormField<String>(
//           value: selectedRole,
//           decoration: const InputDecoration(
//             labelText: 'New Role',
//             border: OutlineInputBorder(),
//           ),
//           items: roleDefinitions.keys.map((role) => DropdownMenuItem(
//             value: role,
//             child: Row(
//               children: [
//                 Icon(
//                   roleDefinitions[role]!['icon'],
//                   color: roleDefinitions[role]!['color'],
//                   size: 20,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(role),
//               ],
//             ),
//           )).toList(),
//           onChanged: (value) {
//             selectedRole = value!;
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 assignedManagers[index]['role'] = selectedRole;
//               });
//               Navigator.of(context).pop();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('${manager['name']}\'s role updated to $selectedRole')),
//               );
//             },
//             child: const Text('Update'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _removeManager(Map<String, dynamic> manager, int index) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Remove Manager'),
//         content: Text('Are you sure you want to remove ${manager['name']} from this event?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 assignedManagers.removeAt(index);
//               });
//               Navigator.of(context).pop();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('${manager['name']} removed')),
//               );
//             },
//             child: const Text('Remove', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _previewDashboard(String role) {
//     final roleData = roleDefinitions[role]!;
    
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => _RoleDashboardPreview(
//           role: role,
//           roleData: roleData,
//           eventTitle: widget.eventTitle,
//         ),
//       ),
//     );
//   }
// }

// class _RoleDashboardPreview extends StatelessWidget {
//   final String role;
//   final Map<String, dynamic> roleData;
//   final String eventTitle;

//   const _RoleDashboardPreview({
//     required this.role,
//     required this.roleData,
//     required this.eventTitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$role Dashboard - $eventTitle'),
//         backgroundColor: roleData['color'],
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: roleData['color'].withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: roleData['color'].withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     roleData['icon'],
//                     color: roleData['color'],
//                     size: 32,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Welcome, $role!',
//                           style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           'This is your limited access dashboard for $eventTitle',
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'Available Features:',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 children: roleData['dashboardAccess'].map<Widget>((feature) => 
//                   _buildFeatureCard(feature, roleData['color'])
//                 ).toList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFeatureCard(String feature, Color color) {
//     IconData icon;
//     switch (feature.toLowerCase()) {
//       case 'event overview':
//         icon = Icons.event;
//         break;
//       case 'attendee list (view only)':
//       case 'attendee search':
//         icon = Icons.people;
//         break;
//       case 'schedule management':
//         icon = Icons.schedule;
//         break;
//       case 'announcements':
//         icon = Icons.campaign;
//         break;
//       case 'check-in scanner':
//         icon = Icons.qr_code_scanner;
//         break;
//       case 'check-in statistics':
//         icon = Icons.analytics;
//         break;
//       case 'problem resolution':
//         icon = Icons.support;
//         break;
//       case 'media upload':
//         icon = Icons.upload;
//         break;
//       case 'gallery management':
//         icon = Icons.photo_library;
//         break;
//       case 'social media tools':
//         icon = Icons.share;
//         break;
//       case 'live stream controls':
//         icon = Icons.live_tv;
//         break;
//       default:
//         icon = Icons.dashboard;
//     }

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 48,
//               color: color,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               feature,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
