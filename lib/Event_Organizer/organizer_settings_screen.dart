import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Firebase/organizer_settings_service.dart';
import '../Models/organizer_model.dart';

class OrganizerSettingsScreen extends StatefulWidget {
  const OrganizerSettingsScreen({super.key});

  @override
  State<OrganizerSettingsScreen> createState() => _OrganizerSettingsScreenState();
}

class _OrganizerSettingsScreenState extends State<OrganizerSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _organizerService = OrganizerSettingsService();
  
  // Controllers for form fields
  final _displayNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _locationController = TextEditingController();
  
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _publicProfile = true;
  
  OrganizerModel? _currentOrganizer;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadOrganizerProfile();
  }

  Future<void> _loadOrganizerProfile() async {
    try {
      setState(() => _isLoading = true);
      
      final organizer = await _organizerService.getOrganizerProfile();
      if (organizer != null) {
        _currentOrganizer = organizer;
        _populateFields(organizer);
      } else {
        // Create default profile if none exists
        await _createDefaultProfile();
      }
    } catch (e) {
      print('Error loading organizer profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createDefaultProfile() async {
    if (_currentUser != null) {
      final defaultOrganizer = OrganizerModel(
        uid: _currentUser.uid,
        email: _currentUser.email ?? '',
        displayName: _currentUser.displayName ?? 'Event Organizer',
        companyName: '',
        bio: '',
        phone: '',
        website: '',
        location: '',
        profileImageUrl: _currentUser.photoURL ?? '',
        emailNotifications: true,
        smsNotifications: false,
        publicProfile: true,
        verificationStatus: VerificationStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _organizerService.updateOrganizerProfile(defaultOrganizer);
      _currentOrganizer = defaultOrganizer;
      _populateFields(defaultOrganizer);
    }
  }

  void _populateFields(OrganizerModel organizer) {
    _displayNameController.text = organizer.displayName;
    _companyNameController.text = organizer.companyName;
    _bioController.text = organizer.bio;
    _phoneController.text = organizer.phone;
    _websiteController.text = organizer.website;
    _locationController.text = organizer.location;
    _emailNotifications = organizer.emailNotifications;
    _smsNotifications = organizer.smsNotifications;
    _publicProfile = organizer.publicProfile;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isUpdating = true);

      final updatedOrganizer = _currentOrganizer!.copyWith(
        displayName: _displayNameController.text.trim(),
        companyName: _companyNameController.text.trim(),
        bio: _bioController.text.trim(),
        phone: _phoneController.text.trim(),
        website: _websiteController.text.trim(),
        location: _locationController.text.trim(),
        emailNotifications: _emailNotifications,
        smsNotifications: _smsNotifications,
        publicProfile: _publicProfile,
        updatedAt: DateTime.now(),
      );

      await _organizerService.updateOrganizerProfile(updatedOrganizer);
      setState(() => _currentOrganizer = updatedOrganizer);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _requestVerification() async {
    try {
      await _organizerService.requestVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification request submitted!'),
          backgroundColor: Colors.blue,
        ),
      );
      _loadOrganizerProfile(); // Reload to update status
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting verification: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Settings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (!_isUpdating)
            TextButton(
              onPressed: _saveProfile,
              child: const Text('SAVE', style: TextStyle(color: Colors.white)),
            ),
          if (_isUpdating)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildProfileSection(),
                  const SizedBox(height: 20),
                  _buildAccountDetailsSection(),
                  const SizedBox(height: 20),
                  _buildNotificationSettings(),
                  const SizedBox(height: 20),
                  _buildPrivacySettings(),
                  const SizedBox(height: 20),
                  _buildVerificationSection(),
                  const SizedBox(height: 20),
                  _buildDangerZone(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _currentUser?.photoURL != null
                        ? NetworkImage(_currentUser!.photoURL!)
                        : null,
                    child: _currentUser?.photoURL == null
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: 'Company/Organization Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio/Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: 'Tell people about yourself and your events...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: TextEditingController(text: _currentUser?.email ?? ''),
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.web),
                hintText: 'https://your-website.com',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
                hintText: 'City, Country',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive event updates and alerts via email'),
              value: _emailNotifications,
              onChanged: (value) => setState(() => _emailNotifications = value),
            ),
            SwitchListTile(
              title: const Text('SMS Notifications'),
              subtitle: const Text('Receive urgent alerts via SMS'),
              value: _smsNotifications,
              onChanged: (value) => setState(() => _smsNotifications = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Public Profile'),
              subtitle: const Text('Make your profile visible to event attendees'),
              value: _publicProfile,
              onChanged: (value) => setState(() => _publicProfile = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationSection() {
    final status = _currentOrganizer?.verificationStatus ?? VerificationStatus.pending;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Verification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _getVerificationIcon(status),
                  color: _getVerificationColor(status),
                ),
                const SizedBox(width: 8),
                Text(
                  _getVerificationText(status),
                  style: TextStyle(
                    color: _getVerificationColor(status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getVerificationDescription(status),
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (status == VerificationStatus.pending || status == VerificationStatus.rejected) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _requestVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  status == VerificationStatus.rejected
                      ? 'Request Re-verification'
                      : 'Request Verification',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danger Zone',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade700),
              title: Text(
                'Sign Out',
                style: TextStyle(color: Colors.red.shade700),
              ),
              subtitle: const Text('Sign out of your account'),
              onTap: _signOut,
            ),
            ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
              title: Text(
                'Delete Account',
                style: TextStyle(color: Colors.red.shade700),
              ),
              subtitle: const Text('Permanently delete your account and all data'),
              onTap: _showDeleteAccountDialog,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getVerificationIcon(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return Icons.verified;
      case VerificationStatus.pending:
        return Icons.hourglass_empty;
      case VerificationStatus.rejected:
        return Icons.error;
    }
  }

  Color _getVerificationColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return Colors.green;
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.rejected:
        return Colors.red;
    }
  }

  String _getVerificationText(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return 'Verified Organizer';
      case VerificationStatus.pending:
        return 'Verification Pending';
      case VerificationStatus.rejected:
        return 'Verification Rejected';
    }
  }

  String _getVerificationDescription(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return 'Your account has been verified. You can create unlimited events.';
      case VerificationStatus.pending:
        return 'Your verification request is being reviewed by our team.';
      case VerificationStatus.rejected:
        return 'Your verification was rejected. Please contact support or try again.';
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and will permanently delete all your events and data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _organizerService.deleteAccount();
        await FirebaseAuth.instance.currentUser?.delete();
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _companyNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
