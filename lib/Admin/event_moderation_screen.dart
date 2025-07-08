import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Firebase/admin_service.dart';

class EventOrganizerModerationScreen extends StatefulWidget {
  const EventOrganizerModerationScreen({super.key});

  @override
  State<EventOrganizerModerationScreen> createState() => _EventOrganizerModerationScreenState();
}

class _EventOrganizerModerationScreenState extends State<EventOrganizerModerationScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, pending, active, inactive, verified, unverified

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleOrganizerStatus(String organizerId, String currentStatus, bool isActive) async {
    try {
      await _adminService.toggleUserStatus(organizerId, 'organizer', isActive);
      _showSnackBar(
        isActive ? 'Organizer activated successfully' : 'Organizer deactivated successfully',
        isActive ? Colors.green : Colors.orange,
        isActive ? Icons.check_circle : Icons.pause_circle,
      );
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red, Icons.error);
    }
  }

  Future<void> _toggleOrganizerVerification(String organizerId, bool isVerified) async {
    try {
      if (isVerified) {
        await _adminService.verifyOrganizer(organizerId);
        _showSnackBar('Organizer verified successfully', Colors.green, Icons.verified);
      } else {
        // Unverify organizer
        await FirebaseFirestore.instance
            .collection('event_organizers')
            .doc(organizerId)
            .update({
          'isVerified': false,
          'unverifiedAt': FieldValue.serverTimestamp(),
          'unverifiedBy': 'admin', // You might want to get the current admin ID
        });
        _showSnackBar('Organizer verification removed', Colors.orange, Icons.warning);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red, Icons.error);
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  List<Map<String, dynamic>> _filterOrganizers(List<Map<String, dynamic>> organizers) {
    List<Map<String, dynamic>> filtered = organizers;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((organizer) {
        final name = '${organizer['firstName'] ?? ''} ${organizer['lastName'] ?? ''}'.toLowerCase();
        final email = (organizer['email'] ?? '').toLowerCase();
        final company = (organizer['companyName'] ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return name.contains(query) || email.contains(query) || company.contains(query);
      }).toList();
    }

    // Apply status filter
    switch (_selectedFilter) {
      case 'pending':
        filtered = filtered.where((o) => !(o['isActive'] ?? false) && !(o['isVerified'] ?? false)).toList();
        break;
      case 'active':
        filtered = filtered.where((o) => o['isActive'] ?? false).toList();
        break;
      case 'inactive':
        filtered = filtered.where((o) => !(o['isActive'] ?? false)).toList();
        break;
      case 'verified':
        filtered = filtered.where((o) => o['isVerified'] ?? false).toList();
        break;
      case 'unverified':
        filtered = filtered.where((o) => !(o['isVerified'] ?? false)).toList();
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Organizer Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or company...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      _buildFilterChip('Pending', 'pending'),
                      _buildFilterChip('Active', 'active'),
                      _buildFilterChip('Inactive', 'inactive'),
                      _buildFilterChip('Verified', 'verified'),
                      _buildFilterChip('Unverified', 'unverified'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Organizers List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _adminService.getAllOrganizers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading organizers...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading organizers',
                          style: TextStyle(fontSize: 18, color: Colors.red[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Trigger rebuild
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final allOrganizers = snapshot.data ?? [];
                final filteredOrganizers = _filterOrganizers(allOrganizers);

                if (filteredOrganizers.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrganizers.length,
                  itemBuilder: (context, index) {
                    final organizer = filteredOrganizers[index];
                    return _buildOrganizerCard(organizer);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue[700],
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue[700] : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No organizers found' : 'No organizers yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty 
                ? 'Try adjusting your search or filters'
                : 'Organizers will appear here when they register',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizerCard(Map<String, dynamic> organizer) {
    final name = '${organizer['firstName'] ?? ''} ${organizer['lastName'] ?? ''}'.trim();
    final email = organizer['email'] ?? '';
    final company = organizer['companyName'] ?? '';
    final phone = organizer['phone'] ?? '';
    final isActive = organizer['isActive'] ?? false;
    final isVerified = organizer['isVerified'] ?? false;
    final createdAt = organizer['createdAt'] as Timestamp?;
    final experience = organizer['yearsOfExperience'] ?? 0;

    String formatDate(Timestamp? timestamp) {
      if (timestamp == null) return 'Unknown';
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }

    Color getStatusColor() {
      if (isVerified && isActive) return Colors.green;
      if (isActive && !isVerified) return Colors.orange;
      return Colors.red;
    }

    String getStatusText() {
      if (isVerified && isActive) return 'Verified & Active';
      if (isActive && !isVerified) return 'Active (Unverified)';
      if (!isActive && isVerified) return 'Verified (Inactive)';
      return 'Pending Approval';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : 'Unknown Name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        company.isNotEmpty ? company : 'No company specified',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: getStatusColor().withOpacity(0.3)),
                  ),
                  child: Text(
                    getStatusText(),
                    style: TextStyle(
                      color: getStatusColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Contact Information
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.email, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              email,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            phone.isNotEmpty ? phone : 'No phone provided',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Experience',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$experience years',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Registration Date and Business License
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registered',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              formatDate(createdAt),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Business License',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              organizer['businessLicense'] ?? 'Not provided',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (organizer['website'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.language, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            organizer['website'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[600],
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                // Active/Inactive Toggle
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      isActive ? Icons.pause : Icons.play_arrow,
                      size: 18,
                    ),
                    label: Text(isActive ? 'Deactivate' : 'Activate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive ? Colors.orange[50] : Colors.green[50],
                      foregroundColor: isActive ? Colors.orange[700] : Colors.green[700],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isActive ? Colors.orange[200]! : Colors.green[200]!,
                        ),
                      ),
                    ),
                    onPressed: () => _toggleOrganizerStatus(
                      organizer['id'],
                      getStatusText(),
                      !isActive,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Verify/Unverify Toggle
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      isVerified ? Icons.verified : Icons.verified_user,
                      size: 18,
                    ),
                    label: Text(isVerified ? 'Unverify' : 'Verify'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isVerified ? Colors.red[50] : Colors.blue[50],
                      foregroundColor: isVerified ? Colors.red[700] : Colors.blue[700],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isVerified ? Colors.red[200]! : Colors.blue[200]!,
                        ),
                      ),
                    ),
                    onPressed: () => _toggleOrganizerVerification(
                      organizer['id'],
                      !isVerified,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // More Options
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onPressed: () => _showOrganizerOptions(context, organizer),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrganizerOptions(BuildContext context, Map<String, dynamic> organizer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Organizer Options',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('View Details'),
                    onTap: () {
                      Navigator.pop(context);
                      _showOrganizerDetails(organizer);
                    },
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Send Message'),
                    onTap: () {
                      Navigator.pop(context);
                      _sendMessageToOrganizer(organizer);
                    },
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: const Text('View Events'),
                    onTap: () {
                      Navigator.pop(context);
                      _viewOrganizerEvents(organizer['id']);
                    },
                  ),
                  
                  const Divider(),
                  
                  ListTile(
                    leading: Icon(Icons.delete_outline, color: Colors.red[600]),
                    title: Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red[600]),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDeleteOrganizer(organizer);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrganizerDetails(Map<String, dynamic> organizer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${organizer['firstName']} ${organizer['lastName']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', organizer['email']),
              _buildDetailRow('Phone', organizer['phone']),
              _buildDetailRow('Company', organizer['companyName']),
              _buildDetailRow('Business License', organizer['businessLicense']),
              _buildDetailRow('Website', organizer['website']),
              _buildDetailRow('Experience', '${organizer['yearsOfExperience']} years'),
              _buildDetailRow('Status', organizer['isActive'] ? 'Active' : 'Inactive'),
              _buildDetailRow('Verification', organizer['isVerified'] ? 'Verified' : 'Unverified'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'Not provided',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessageToOrganizer(Map<String, dynamic> organizer) {
    // TODO: Implement messaging functionality
    _showSnackBar('Messaging feature coming soon', Colors.blue, Icons.info);
  }

  void _viewOrganizerEvents(String organizerId) {
    // TODO: Navigate to organizer's events
    _showSnackBar('Event viewing feature coming soon', Colors.blue, Icons.info);
  }

  void _confirmDeleteOrganizer(Map<String, dynamic> organizer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Organizer Account'),
        content: Text(
          'Are you sure you want to delete ${organizer['firstName']} ${organizer['lastName']}\'s account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _adminService.deleteUser(organizer['id'], 'organizer');
                _showSnackBar('Organizer account deleted', Colors.green, Icons.check);
              } catch (e) {
                _showSnackBar('Error: ${e.toString()}', Colors.red, Icons.error);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
