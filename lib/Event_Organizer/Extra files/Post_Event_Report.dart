// import 'package:flutter/material.dart';

// class PostEventReportScreen extends StatefulWidget {
//   final String eventId;
//   final String eventTitle;

//   const PostEventReportScreen({
//     Key? key,
//     required this.eventId,
//     required this.eventTitle,
//   }) : super(key: key);

//   @override
//   State<PostEventReportScreen> createState() => _PostEventReportScreenState();
// }

// class _PostEventReportScreenState extends State<PostEventReportScreen> {
//   bool isLoadingReport = false;
//   bool isGeneratingPDF = false;

//   // Sample report data - replace with actual API calls
//   final Map<String, dynamic> reportData = {
//     'eventInfo': {
//       'title': 'Tech Conference 2024',
//       'date': '2024-03-15',
//       'duration': '8 hours',
//       'venue': 'Convention Center, Downtown',
//       'status': 'Completed',
//     },
//     'ticketSales': {
//       'totalTicketsSold': 245,
//       'totalCapacity': 300,
//       'salesRate': 81.7,
//       'ticketTypes': {
//         'Early Bird': {'sold': 100, 'price': 35.00, 'revenue': 3500.00},
//         'Regular': {'sold': 120, 'price': 50.00, 'revenue': 6000.00},
//         'VIP': {'sold': 25, 'price': 100.00, 'revenue': 2500.00},
//       },
//       'totalRevenue': 12000.00,
//       'refunds': 250.00,
//       'netRevenue': 11750.00,
//     },
//     'attendance': {
//       'checkedIn': 198,
//       'noShows': 47,
//       'attendanceRate': 80.8,
//       'checkInTrend': [
//         {'time': '08:00', 'count': 15},
//         {'time': '08:30', 'count': 45},
//         {'time': '09:00', 'count': 85},
//         {'time': '09:30', 'count': 30},
//         {'time': '10:00', 'count': 23},
//       ]
//     },
//     'ratings': {
//       'overallRating': 4.3,
//       'totalReviews': 156,
//       'ratingBreakdown': {
//         5: 78,
//         4: 45,
//         3: 22,
//         2: 8,
//         1: 3,
//       },
//       'categoryRatings': {
//         'Content Quality': 4.5,
//         'Organization': 4.3,
//         'Venue': 3.8,
//         'Networking': 4.1,
//         'Value for Money': 4.0,
//       },
//       'nps': 67, // Net Promoter Score
//     },
//     'demographics': {
//       'ageGroups': {
//         '18-25': 25,
//         '26-35': 45,
//         '36-45': 23,
//         '46+': 7,
//       },
//       'industries': {
//         'Technology': 40,
//         'Finance': 20,
//         'Healthcare': 15,
//         'Education': 12,
//         'Other': 13,
//       },
//       'locations': {
//         'Local (0-50 miles)': 65,
//         'Regional (50-200 miles)': 25,
//         'National (200+ miles)': 8,
//         'International': 2,
//       }
//     },
//     'engagement': {
//       'socialMediaMentions': 89,
//       'photoShares': 234,
//       'networkingConnections': 167,
//       'feedbackSubmissions': 156,
//     }
//   };

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Report - ${widget.eventTitle}'),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.download),
//             onPressed: _generatePDFReport,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildEventSummaryCard(),
//             const SizedBox(height: 16),
//             _buildQuickStatsGrid(),
//             const SizedBox(height: 16),
//             _buildTicketSalesSection(),
//             const SizedBox(height: 16),
//             _buildAttendanceSection(),
//             const SizedBox(height: 16),
//             _buildRatingsSection(),
//             const SizedBox(height: 16),
//             _buildDemographicsSection(),
//             const SizedBox(height: 16),
//             _buildEngagementSection(),
//             const SizedBox(height: 16),
//             _buildActionsSection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEventSummaryCard() {
//     final eventInfo = reportData['eventInfo'];
    
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.event, color: Colors.deepPurple, size: 28),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Event Summary',
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         'Generated on ${DateTime.now().toString().substring(0, 10)}',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: Colors.green),
//                   ),
//                   child: Text(
//                     eventInfo['status'],
//                     style: const TextStyle(
//                       color: Colors.green,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildInfoItem('Date', eventInfo['date']),
//                 ),
//                 Expanded(
//                   child: _buildInfoItem('Duration', eventInfo['duration']),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             _buildInfoItem('Venue', eventInfo['venue']),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoItem(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//             color: Colors.grey[600],
//           ),
//         ),
//         Text(
//           value,
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQuickStatsGrid() {
//     final ticketSales = reportData['ticketSales'];
//     final attendance = reportData['attendance'];
//     final ratings = reportData['ratings'];
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Key Metrics',
//           style: Theme.of(context).textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _buildStatCard(
//                 'Tickets Sold',
//                 '${ticketSales['totalTicketsSold']}',
//                 '${ticketSales['salesRate'].toStringAsFixed(1)}% capacity',
//                 Icons.confirmation_number,
//                 Colors.blue,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildStatCard(
//                 'Revenue',
//                 '\$${(ticketSales['netRevenue'] as double).toStringAsFixed(0)}',
//                 'Net revenue',
//                 Icons.attach_money,
//                 Colors.green,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _buildStatCard(
//                 'Attendance',
//                 '${attendance['checkedIn']}',
//                 '${attendance['attendanceRate'].toStringAsFixed(1)}% showed up',
//                 Icons.people,
//                 Colors.orange,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildStatCard(
//                 'Rating',
//                 '${ratings['overallRating']}',
//                 '${ratings['totalReviews']} reviews',
//                 Icons.star,
//                 Colors.amber,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: color, size: 24),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             Text(
//               subtitle,
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTicketSalesSection() {
//     final ticketSales = reportData['ticketSales'];
//     final ticketTypes = ticketSales['ticketTypes'] as Map<String, dynamic>;
    
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Ticket Sales Breakdown',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ...ticketTypes.entries.map((entry) {
//               final data = entry.value;
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       flex: 2,
//                       child: Text(
//                         entry.key,
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     Expanded(
//                       child: Text('${data['sold']} sold'),
//                     ),
//                     Expanded(
//                       child: Text('\$${data['price'].toStringAsFixed(2)}'),
//                     ),
//                     Expanded(
//                       child: Text(
//                         '\$${data['revenue'].toStringAsFixed(2)}',
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//             const Divider(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Total Revenue:', style: TextStyle(fontWeight: FontWeight.bold)),
//                 Text(
//                   '\$${ticketSales['totalRevenue'].toStringAsFixed(2)}',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             if (ticketSales['refunds'] > 0) ...[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('Refunds:', style: TextStyle(color: Colors.red)),
//                   Text(
//                     '-\$${ticketSales['refunds'].toStringAsFixed(2)}',
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('Net Revenue:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                   Text(
//                     '\$${ticketSales['netRevenue'].toStringAsFixed(2)}',
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAttendanceSection() {
//     final attendance = reportData['attendance'];
//     final checkInTrend = attendance['checkInTrend'] as List<dynamic>;
    
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Attendance Analysis',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildAttendanceMetric(
//                     'Checked In',
//                     '${attendance['checkedIn']}',
//                     Colors.green,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildAttendanceMetric(
//                     'No Shows',
//                     '${attendance['noShows']}',
//                     Colors.red,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildAttendanceMetric(
//                     'Rate',
//                     '${attendance['attendanceRate'].toStringAsFixed(1)}%',
//                     Colors.blue,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Check-in Timeline',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             ...checkInTrend.map((trend) => Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: Row(
//                 children: [
//                   Text(
//                     trend['time'],
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: LinearProgressIndicator(
//                       value: trend['count'] / 85, // Max count for scaling
//                       backgroundColor: Colors.grey[300],
//                       valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text('${trend['count']}'),
//                 ],
//               ),
//             )).toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAttendanceMetric(String label, String value, Color color) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: Theme.of(context).textTheme.bodySmall,
//         ),
//       ],
//     );
//   }

//   Widget _buildRatingsSection() {
//     final ratings = reportData['ratings'];
//     final ratingBreakdown = ratings['ratingBreakdown'] as Map<dynamic, dynamic>;
//     final categoryRatings = ratings['categoryRatings'] as Map<String, dynamic>;
    
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'User Ratings & Feedback',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     children: [
//                       Text(
//                         '${ratings['overallRating']}',
//                         style: Theme.of(context).textTheme.headlineLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.amber,
//                         ),
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: List.generate(5, (index) => Icon(
//                           index < ratings['overallRating'].floor()
//                               ? Icons.star
//                               : Icons.star_border,
//                           color: Colors.amber,
//                           size: 20,
//                         )),
//                       ),
//                       Text('Overall Rating'),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Column(
//                     children: [
//                       Text(
//                         '${ratings['totalReviews']}',
//                         style: Theme.of(context).textTheme.headlineLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text('Reviews'),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Column(
//                     children: [
//                       Text(
//                         '${ratings['nps']}',
//                         style: Theme.of(context).textTheme.headlineLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                         ),
//                       ),
//                       Text('NPS Score'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Category Breakdown',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             ...categoryRatings.entries.map((entry) => Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: Text(entry.key),
//                   ),
//                   Expanded(
//                     flex: 3,
//                     child: LinearProgressIndicator(
//                       value: entry.value / 5,
//                       backgroundColor: Colors.grey[300],
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         entry.value >= 4 ? Colors.green : 
//                         entry.value >= 3 ? Colors.orange : Colors.red,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text('${entry.value}/5'),
//                 ],
//               ),
//             )).toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDemographicsSection() {
//     final demographics = reportData['demographics'];
    
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Attendee Demographics',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildDemographicChart('Age Groups', demographics['ageGroups']),
//             const SizedBox(height: 16),
//             _buildDemographicChart('Industries', demographics['industries']),
//             const SizedBox(height: 16),
//             _buildDemographicChart('Geographic Distribution', demographics['locations']),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDemographicChart(String title, Map<String, int> data) {
//     final total = data.values.reduce((a, b) => a + b);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 8),
//         ...data.entries.map((entry) {
//           final percentage = (entry.value / total * 100);
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 6),
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: Text(entry.key, style: const TextStyle(fontSize: 12)),
//                 ),
//                 Expanded(
//                   flex: 3,
//                   child: LinearProgressIndicator(
//                     value: entry.value / total,
//                     backgroundColor: Colors.grey[300],
//                     valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12)),
//               ],
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }

//   Widget _buildEngagementSection() {
//     final engagement = reportData['engagement'];
    
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Engagement Metrics',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildEngagementMetric(
//                     'Social Mentions',
//                     '${engagement['socialMediaMentions']}',
//                     Icons.share,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildEngagementMetric(
//                     'Photo Shares',
//                     '${engagement['photoShares']}',
//                     Icons.photo_camera,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildEngagementMetric(
//                     'Connections',
//                     '${engagement['networkingConnections']}',
//                     Icons.people_outline,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildEngagementMetric(
//                     'Feedback',
//                     '${engagement['feedbackSubmissions']}',
//                     Icons.feedback,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEngagementMetric(String label, String value, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: Colors.deepPurple),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: Colors.deepPurple,
//             ),
//           ),
//           Text(
//             label,
//             style: Theme.of(context).textTheme.bodySmall,
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionsSection() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Report Actions',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: isGeneratingPDF ? null : _generatePDFReport,
//                     icon: isGeneratingPDF 
//                         ? const SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Icon(Icons.picture_as_pdf),
//                     label: Text(isGeneratingPDF ? 'Generating...' : 'Download PDF'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _shareReport,
//                     icon: const Icon(Icons.share),
//                     label: const Text('Share Report'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton.icon(
//                 onPressed: _emailReport,
//                 icon: const Icon(Icons.email),
//                 label: const Text('Email to Stakeholders'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _generatePDFReport() async {
//     setState(() => isGeneratingPDF = true);
    
//     try {
//       // TODO: Implement PDF generation
//       await Future.delayed(const Duration(seconds: 2)); // Simulate PDF generation
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Row(
//             children: [
//               Icon(Icons.check_circle, color: Colors.white),
//               SizedBox(width: 8),
//               Text('PDF report generated successfully!'),
//             ],
//           ),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error generating PDF: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => isGeneratingPDF = false);
//     }
//   }

//   void _shareReport() {
//     // TODO: Implement share functionality
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Share functionality coming soon!')),
//     );
//   }

//   void _emailReport() {
//     // TODO: Implement email functionality
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Email functionality coming soon!')),
//     );
//   }
// }
