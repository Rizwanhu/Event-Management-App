// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class EventManagementScreen extends StatefulWidget {
//   final String eventId;

//   const EventManagementScreen({
//     Key? key,
//     required this.eventId,
//   }) : super(key: key);

//   @override
//   State<EventManagementScreen> createState() => _EventManagementScreenState();
// }

// class _EventManagementScreenState extends State<EventManagementScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final ImagePicker _imagePicker = ImagePicker();
//   bool isLoading = false;

//   // Sample event data
//   Map<String, dynamic> eventData = {
//     'id': '1',
//     'title': 'Tech Conference 2024',
//     'description': 'Annual technology conference featuring latest innovations',
//     'date': '2024-03-15',
//     'time': '09:00',
//     'location': 'Convention Center, Downtown',
//     'capacity': 300,
//     'ticketPrice': 99.99,
//     'category': 'Technology',
//     'imageUrl': 'https://example.com/event-image.jpg',
//   };

//   // Sample attendees data
//   List<Map<String, dynamic>> attendees = [
//     {
//       'id': '1',
//       'name': 'John Smith',
//       'email': 'john.smith@email.com',
//       'ticketType': 'VIP',
//       'checkedIn': true,
//       'checkInTime': '2024-03-15 09:15',
//       'phone': '+1234567890',
//     },
//     {
//       'id': '2',
//       'name': 'Sarah Johnson',
//       'email': 'sarah.j@email.com',
//       'ticketType': 'Regular',
//       'checkedIn': false,
//       'checkInTime': null,
//       'phone': '+1234567891',
//     },
//     {
//       'id': '3',
//       'name': 'Mike Wilson',
//       'email': 'mike.wilson@email.com',
//       'ticketType': 'Early Bird',
//       'checkedIn': true,
//       'checkInTime': '2024-03-15 08:45',
//       'phone': '+1234567892',
//     },
//     {
//       'id': '4',
//       'name': 'Emily Davis',
//       'email': 'emily.davis@email.com',
//       'ticketType': 'Regular',
//       'checkedIn': false,
//       'checkInTime': null,
//       'phone': '+1234567893',
//     },
//   ];

//   // Sample media data
//   List<Map<String, dynamic>> eventMedia = [
//     {
//       'id': '1',
//       'type': 'image',
//       'url': 'https://example.com/photo1.jpg',
//       'caption': 'Opening ceremony',
//       'uploadTime': '2024-03-15 10:30',
//     },
//     {
//       'id': '2',
//       'type': 'video',
//       'url': 'https://example.com/video1.mp4',
//       'caption': 'Keynote presentation',
//       'uploadTime': '2024-03-15 11:45',
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
//         title: Text('Manage: ${eventData['title']}'),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           indicatorColor: Colors.white,
//           tabs: const [
//             Tab(icon: Icon(Icons.edit), text: 'Edit Event'),
//             Tab(icon: Icon(Icons.people), text: 'Attendees'),
//             Tab(icon: Icon(Icons.photo_library), text: 'Media'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildEditEventTab(),
//           _buildAttendeesTab(),
//           _buildMediaTab(),
//         ],
//       ),
//     );
//   }

//   Widget _buildEditEventTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildEventEditForm(),
//         ],
//       ),
//     );
//   }

//   Widget _buildEventEditForm() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Event Details',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               initialValue: eventData['title'],
//               decoration: const InputDecoration(
//                 labelText: 'Event Title',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               initialValue: eventData['description'],
//               maxLines: 4,
//               decoration: const InputDecoration(
//                 labelText: 'Description',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     initialValue: eventData['date'],
//                     decoration: const InputDecoration(
//                       labelText: 'Date',
//                       border: OutlineInputBorder(),
//                       suffixIcon: Icon(Icons.calendar_today),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: TextFormField(
//                     initialValue: eventData['time'],
//                     decoration: const InputDecoration(
//                       labelText: 'Time',
//                       border: OutlineInputBorder(),
//                       suffixIcon: Icon(Icons.access_time),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               initialValue: eventData['location'],
//               decoration: const InputDecoration(
//                 labelText: 'Location',
//                 border: OutlineInputBorder(),
//                 suffixIcon: Icon(Icons.location_on),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     initialValue: eventData['capacity'].toString(),
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       labelText: 'Capacity',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: TextFormField(
//                     initialValue: eventData['ticketPrice'].toString(),
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       labelText: 'Ticket Price (\$)',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: eventData['category'],
//               decoration: const InputDecoration(
//                 labelText: 'Category',
//                 border: OutlineInputBorder(),
//               ),
//               items: ['Technology', 'Business', 'Arts', 'Sports', 'Music']
//                   .map((category) => DropdownMenuItem(
//                         value: category,
//                         child: Text(category),
//                       ))
//                   .toList(),
//               onChanged: (value) {
//                 setState(() {
//                   eventData['category'] = value;
//                 });
//               },
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _saveEventChanges,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: const Text('Save Changes'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAttendeesTab() {
//     final checkedInCount = attendees.where((a) => a['checkedIn']).length;
    
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16.0),
//           color: Colors.grey[100],
//           child: Row(
//             children: [
//               Expanded(
//                 child: _buildAttendeeStats('Total', attendees.length.toString()),
//               ),
//               Expanded(
//                 child: _buildAttendeeStats('Checked In', checkedInCount.toString()),
//               ),
//               Expanded(
//                 child: _buildAttendeeStats('Not Checked In', 
//                     (attendees.length - checkedInCount).toString()),
//               ),
//             ],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: TextField(
//             decoration: const InputDecoration(
//               hintText: 'Search attendees...',
//               prefixIcon: Icon(Icons.search),
//               border: OutlineInputBorder(),
//             ),
//             onChanged: (value) {
//               // TODO: Implement search functionality
//             },
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             itemCount: attendees.length,
//             itemBuilder: (context, index) {
//               final attendee = attendees[index];
//               return _buildAttendeeCard(attendee, index);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAttendeeStats(String label, String value) {
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

//   Widget _buildAttendeeCard(Map<String, dynamic> attendee, int index) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: attendee['checkedIn'] ? Colors.green : Colors.grey,
//           child: Icon(
//             attendee['checkedIn'] ? Icons.check : Icons.person,
//             color: Colors.white,
//           ),
//         ),
//         title: Text(
//           attendee['name'],
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(attendee['email']),
//             Text('Ticket: ${attendee['ticketType']}'),
//             if (attendee['checkedIn'])
//               Text(
//                 'Checked in: ${attendee['checkInTime']}',
//                 style: const TextStyle(color: Colors.green),
//               ),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: Icon(
//                 attendee['checkedIn'] ? Icons.check_circle : Icons.check_circle_outline,
//                 color: attendee['checkedIn'] ? Colors.green : Colors.grey,
//               ),
//               onPressed: () => _toggleCheckIn(index),
//             ),
//             PopupMenuButton<String>(
//               onSelected: (value) => _handleAttendeeAction(value, attendee),
//               itemBuilder: (context) => [
//                 const PopupMenuItem(
//                   value: 'view',
//                   child: Row(
//                     children: [
//                       Icon(Icons.visibility),
//                       SizedBox(width: 8),
//                       Text('View Details'),
//                     ],
//                   ),
//                 ),
//                 const PopupMenuItem(
//                   value: 'contact',
//                   child: Row(
//                     children: [
//                       Icon(Icons.message),
//                       SizedBox(width: 8),
//                       Text('Contact'),
//                     ],
//                   ),
//                 ),
//                 const PopupMenuItem(
//                   value: 'remove',
//                   child: Row(
//                     children: [
//                       Icon(Icons.delete, color: Colors.red),
//                       SizedBox(width: 8),
//                       Text('Remove'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         isThreeLine: true,
//       ),
//     );
//   }

//   Widget _buildMediaTab() {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () => _addMedia('image'),
//                   icon: const Icon(Icons.photo_camera),
//                   label: const Text('Add Photo'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepPurple,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () => _addMedia('video'),
//                   icon: const Icon(Icons.videocam),
//                   label: const Text('Add Video'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepPurple,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: eventMedia.isEmpty
//               ? const Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.photo_library_outlined,
//                         size: 64,
//                         color: Colors.grey,
//                       ),
//                       SizedBox(height: 16),
//                       Text(
//                         'No media uploaded yet',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         'Add photos and videos from your event',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 )
//               : GridView.builder(
//                   padding: const EdgeInsets.all(16.0),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 16,
//                     mainAxisSpacing: 16,
//                   ),
//                   itemCount: eventMedia.length,
//                   itemBuilder: (context, index) {
//                     final media = eventMedia[index];
//                     return _buildMediaCard(media, index);
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMediaCard(Map<String, dynamic> media, int index) {
//     return Card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   topRight: Radius.circular(12),
//                 ),
//               ),
//               child: Icon(
//                 media['type'] == 'image' ? Icons.image : Icons.play_circle_filled,
//                 size: 48,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   media['caption'],
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Text(
//                   media['uploadTime'],
//                   style: Theme.of(context).textTheme.bodySmall,
//                 ),
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.edit, size: 16),
//                       onPressed: () => _editMediaCaption(index),
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete, size: 16, color: Colors.red),
//                       onPressed: () => _deleteMedia(index),
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _saveEventChanges() {
//     // TODO: Implement save functionality
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Event details updated successfully!'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   void _toggleCheckIn(int index) {
//     setState(() {
//       attendees[index]['checkedIn'] = !attendees[index]['checkedIn'];
//       if (attendees[index]['checkedIn']) {
//         attendees[index]['checkInTime'] = DateTime.now().toString().substring(0, 16);
//       } else {
//         attendees[index]['checkInTime'] = null;
//       }
//     });
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           attendees[index]['checkedIn']
//               ? '${attendees[index]['name']} checked in'
//               : '${attendees[index]['name']} check-in removed',
//         ),
//         backgroundColor: attendees[index]['checkedIn'] ? Colors.green : Colors.orange,
//       ),
//     );
//   }

//   void _handleAttendeeAction(String action, Map<String, dynamic> attendee) {
//     switch (action) {
//       case 'view':
//         _showAttendeeDetails(attendee);
//         break;
//       case 'contact':
//         _contactAttendee(attendee);
//         break;
//       case 'remove':
//         _removeAttendee(attendee);
//         break;
//     }
//   }

//   void _showAttendeeDetails(Map<String, dynamic> attendee) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(attendee['name']),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Email: ${attendee['email']}'),
//             Text('Phone: ${attendee['phone']}'),
//             Text('Ticket Type: ${attendee['ticketType']}'),
//             Text('Status: ${attendee['checkedIn'] ? 'Checked In' : 'Not Checked In'}'),
//             if (attendee['checkedIn'])
//               Text('Check-in Time: ${attendee['checkInTime']}'),
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

//   void _contactAttendee(Map<String, dynamic> attendee) {
//     // TODO: Implement contact functionality
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Contacting ${attendee['name']}')),
//     );
//   }

//   void _removeAttendee(Map<String, dynamic> attendee) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Remove Attendee'),
//         content: Text('Are you sure you want to remove ${attendee['name']} from this event?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 attendees.removeWhere((a) => a['id'] == attendee['id']);
//               });
//               Navigator.of(context).pop();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('${attendee['name']} removed')),
//               );
//             },
//             child: const Text('Remove', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _addMedia(String type) async {
//     try {
//       XFile? file;
//       if (type == 'image') {
//         file = await _imagePicker.pickImage(source: ImageSource.gallery);
//       } else {
//         file = await _imagePicker.pickVideo(source: ImageSource.gallery);
//       }

//       if (file != null) {
//         _showAddMediaDialog(type, file);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error selecting $type: $e')),
//       );
//     }
//   }

//   void _showAddMediaDialog(String type, XFile file) {
//     final captionController = TextEditingController();
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Add ${type == 'image' ? 'Photo' : 'Video'}'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               height: 100,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 type == 'image' ? Icons.image : Icons.play_circle_filled,
//                 size: 48,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: captionController,
//               decoration: const InputDecoration(
//                 labelText: 'Caption',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 2,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 eventMedia.add({
//                   'id': DateTime.now().millisecondsSinceEpoch.toString(),
//                   'type': type,
//                   'url': file.path,
//                   'caption': captionController.text.isEmpty 
//                       ? 'Event ${type}' 
//                       : captionController.text,
//                   'uploadTime': DateTime.now().toString().substring(0, 16),
//                 });
//               });
//               Navigator.of(context).pop();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('${type == 'image' ? 'Photo' : 'Video'} added successfully')),
//               );
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _editMediaCaption(int index) {
//     final captionController = TextEditingController(text: eventMedia[index]['caption']);
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Caption'),
//         content: TextField(
//           controller: captionController,
//           decoration: const InputDecoration(
//             labelText: 'Caption',
//             border: OutlineInputBorder(),
//           ),
//           maxLines: 2,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 eventMedia[index]['caption'] = captionController.text;
//               });
//               Navigator.of(context).pop();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Caption updated')),
//               );
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _deleteMedia(int index) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Media'),
//         content: const Text('Are you sure you want to delete this media?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 eventMedia.removeAt(index);
//               });
//               Navigator.of(context).pop();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Media deleted')),
//               );
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }
