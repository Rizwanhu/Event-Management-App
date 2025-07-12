// import 'package:flutter/material.dart';
// //import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

// class BoostEventScreen extends StatefulWidget {
//   final String eventId;
//   final String eventTitle;

//   const BoostEventScreen({
//     Key? key,
//     required this.eventId,
//     required this.eventTitle,
//   }) : super(key: key);

//   @override
//   State<BoostEventScreen> createState() => _BoostEventScreenState();
// }

// class _BoostEventScreenState extends State<BoostEventScreen> {
//   String selectedTier = '';
//   bool isLoading = false;

//   final Map<String, Map<String, dynamic>> promotionTiers = {
//     'Bronze': {
//       'price': 29.99,
//       'color': Colors.orange,
//       'reach': '500+ users',
//       'placement': 'Standard listing',
//       'duration': '3 days',
//       'features': [
//         'Basic promotion',
//         'Standard search visibility',
//         'Email notification to subscribers'
//       ]
//     },
//     'Silver': {
//       'price': 59.99,
//       'color': Colors.grey,
//       'reach': '2,000+ users',
//       'placement': 'Featured section',
//       'duration': '7 days',
//       'features': [
//         'Enhanced promotion',
//         'Featured in category',
//         'Push notifications',
//         'Social media sharing'
//       ]
//     },
//     'Gold': {
//       'price': 99.99,
//       'color': Colors.amber,
//       'reach': '5,000+ users',
//       'placement': 'Top banner placement',
//       'duration': '14 days',
//       'features': [
//         'Premium promotion',
//         'Homepage banner',
//         'Priority search results',
//         'Email campaigns',
//         'Social media ads'
//       ]
//     },
//   };

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Boost Your Event'),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildEventHeader(),
//             const SizedBox(height: 24),
//             _buildPromotionTiers(),
//             const SizedBox(height: 24),
//             if (selectedTier.isNotEmpty) _buildImpactPreview(),
//             const SizedBox(height: 24),
//             if (selectedTier.isNotEmpty) _buildPaymentSection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEventHeader() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Boosting Event:',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               widget.eventTitle,
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Choose a promotion tier to increase your event visibility and reach more potential attendees.',
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPromotionTiers() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Choose Promotion Tier',
//           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
//         ...promotionTiers.entries.map((entry) => _buildTierCard(entry.key, entry.value)),
//       ],
//     );
//   }

//   Widget _buildTierCard(String tierName, Map<String, dynamic> tierData) {
//     final isSelected = selectedTier == tierName;
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       color: isSelected ? tierData['color'].withOpacity(0.1) : null,
//       child: InkWell(
//         onTap: () => setState(() => selectedTier = tierName),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     Icons.star,
//                     color: tierData['color'],
//                     size: 28,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     tierName,
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: tierData['color'],
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     '\$${tierData['price']}',
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildTierStat('Reach', tierData['reach']),
//                   ),
//                   Expanded(
//                     child: _buildTierStat('Duration', tierData['duration']),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Features:',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               ...tierData['features'].map<Widget>((feature) => Padding(
//                 padding: const EdgeInsets.only(bottom: 4),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.check_circle,
//                       color: tierData['color'],
//                       size: 16,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(feature),
//                   ],
//                 ),
//               )).toList(),
//               if (isSelected) ...[
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: tierData['color'].withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.check_circle,
//                         color: tierData['color'],
//                       ),
//                       const SizedBox(width: 8),
//                       const Text('Selected'),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTierStat(String label, String value) {
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
//           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildImpactPreview() {
//     final tierData = promotionTiers[selectedTier]!;
    
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.trending_up,
//                   color: tierData['color'],
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Impact Preview',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _buildImpactStat('Expected Reach', tierData['reach'], Icons.people),
//             _buildImpactStat('Placement', tierData['placement'], Icons.place),
//             _buildImpactStat('Promotion Duration', tierData['duration'], Icons.schedule),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.info,
//                     color: Colors.green,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Your event will start appearing in the ${selectedTier.toLowerCase()} tier immediately after payment confirmation.',
//                       style: const TextStyle(color: Colors.green),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImpactStat(String label, String value, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.grey[600]),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaymentSection() {
//     final tierData = promotionTiers[selectedTier]!;
    
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Payment Summary',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '$selectedTier Tier Promotion',
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//                 Text(
//                   '\$${tierData['price']}',
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Total',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   '\$${tierData['price']}',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: tierData['color'],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: isLoading ? null : _processPayment,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: tierData['color'],
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.payment),
//                           const SizedBox(width: 8),
//                           Text(
//                             'Pay with Stripe - \$${tierData['price']}',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.security,
//                   size: 16,
//                   color: Colors.grey[600],
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   'Secure payment powered by Stripe',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Future<void> _processPayment() async {
//   //   setState(() => isLoading = true);
    
//   //   try {
//   //     final tierData = promotionTiers[selectedTier]!;
//   //       // Initialize payment sheet
//   //     await stripe.Stripe.instance.initPaymentSheet(
//   //       paymentSheetParameters: stripe.SetupPaymentSheetParameters(
//   //         paymentIntentClientSecret: await _createPaymentIntent(tierData['price']),
//   //         merchantDisplayName: 'Event Management App',
//   //         style: ThemeMode.system,
//   //       ),
//   //     );

//   //     // Present payment sheet
//   //     await stripe.Stripe.instance.presentPaymentSheet();
      
//   //     // Payment successful
//   //     _showSuccessDialog();
      
//   //   } catch (e) {
//   //     _showErrorDialog(e.toString());
//   //   } finally {
//   //     setState(() => isLoading = false);
//   //   }
//   // }

//   Future<String> _createPaymentIntent(double amount) async {
//     // TODO: Implement server-side payment intent creation
//     // This should call your backend API to create a PaymentIntent
//     // For now, returning a placeholder
//     await Future.delayed(const Duration(seconds: 1));
//     return 'pi_placeholder_client_secret';
//   }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.green),
//             SizedBox(width: 8),
//             Text('Payment Successful!'),
//           ],
//         ),
//         content: Text(
//           'Your event has been boosted with the $selectedTier tier. You should see increased visibility within the next few minutes.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               Navigator.of(context).pop();
//             },
//             child: const Text('Done'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showErrorDialog(String error) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Row(
//           children: [
//             Icon(Icons.error, color: Colors.red),
//             SizedBox(width: 8),
//             Text('Payment Failed'),
//           ],
//         ),
//         content: Text('Payment could not be processed: $error'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
// }
