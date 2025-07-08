import 'package:flutter/material.dart';
import '../Firebase/firebase_test_service.dart';
import '../Firebase/test_data_seeder.dart';
import '../Firebase/event_moderation_service.dart';

class AdminTestScreen extends StatefulWidget {
  const AdminTestScreen({super.key});

  @override
  State<AdminTestScreen> createState() => _AdminTestScreenState();
}

class _AdminTestScreenState extends State<AdminTestScreen> {
  final FirebaseTestService _testService = FirebaseTestService();
  final TestDataSeeder _seeder = TestDataSeeder();
  final EventModerationService _moderationService = EventModerationService();
  
  bool _isLoading = false;
  String _lastResult = '';

  void _runTest(String testName, Future<void> Function() testFunction) async {
    setState(() {
      _isLoading = true;
      _lastResult = 'Running $testName...';
    });

    try {
      await testFunction();
      setState(() {
        _lastResult = '$testName completed successfully';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _lastResult = '$testName failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Test Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Result display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _lastResult.isEmpty ? 'No tests run yet' : _lastResult,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Test buttons
            Text(
              'Firebase Connection Tests',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _runTest(
                'Connection Test',
                () async {
                  final result = await _testService.testConnection();
                  if (!result) throw Exception('Connection test failed');
                },
              ),
              icon: const Icon(Icons.wifi),
              label: const Text('Test Firebase Connection'),
            ),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _runTest(
                'Admin Permissions Test',
                () async {
                  final result = await _testService.checkAdminPermissions();
                  if (!result) throw Exception('Admin permissions test failed');
                },
              ),
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Test Admin Permissions'),
            ),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _runTest(
                'All Events Query',
                () async {
                  await _testService.getAllEventsDebug();
                },
              ),
              icon: const Icon(Icons.list),
              label: const Text('Get All Events (Debug)'),
            ),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _runTest(
                'Moderation Queries Test',
                () async {
                  await _testService.testModerationQueries();
                },
              ),
              icon: const Icon(Icons.query_stats),
              label: const Text('Test Moderation Queries'),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'Data Management',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _runTest(
                'Create Sample Events',
                () async {
                  await _seeder.createSamplePendingEvents();
                  await _seeder.createSampleVarietyEvents();
                },
              ),
              icon: const Icon(Icons.add),
              label: const Text('Create Sample Events'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _runTest(
                'Clean Up Test Events',
                () async {
                  await _seeder.cleanUpTestEvents();
                },
              ),
              icon: const Icon(Icons.delete),
              label: const Text('Clean Up Test Events'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'Event Statistics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _runTest(
                'Get Event Statistics',
                () async {
                  final stats = await _moderationService.getEventStatistics();
                  setState(() {
                    _lastResult = 'Event Statistics:\n'
                        'Total: ${stats['total']}\n'
                        'Pending: ${stats['pending']}\n'
                        'Approved: ${stats['approved']}\n'
                        'Rejected: ${stats['rejected']}';
                  });
                },
              ),
              icon: const Icon(Icons.analytics),
              label: const Text('Get Event Statistics'),
            ),
            
            const Spacer(),
            
            if (_isLoading) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 10),
              const Center(child: Text('Running test...')),
            ],
          ],
        ),
      ),
    );
  }
}
