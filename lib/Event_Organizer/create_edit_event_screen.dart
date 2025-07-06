import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Firebase/event_management_service.dart';
import '../Models/event_model.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart' as latlong2;

class CreateEditEventScreen extends StatefulWidget {
  final EventModel? event;
  
  const CreateEditEventScreen({super.key, this.event});

  @override
  _CreateEditEventScreenState createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends State<CreateEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final EventManagementService _eventService = EventManagementService();
  
  bool _isLoading = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedCategory = 'Conference';
  List<String> _tags = [];
  List<XFile> _selectedImages = [];
  List<String> _existingImageUrls = []; // For existing images when editing
  bool _isPaidEvent = false;
  latlong2.LatLng? _selectedLocation;
  
  final List<String> _categories = [
    'Conference', 'Workshop', 'Seminar', 'Concert', 'Sports', 'Festival', 'Networking', 'Other'
  ];
  
  final List<String> _availableTags = [
    'Technology', 'Business', 'Music', 'Art', 'Sports', 'Education', 'Health', 'Food'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final event = widget.event!;
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _locationController.text = event.location;
    _selectedCategory = event.category;
    _tags = List<String>.from(event.tags);
    _selectedDate = event.eventDate;
    _selectedTime = event.eventTime;
    _isPaidEvent = event.ticketType == TicketType.paid;
    if (_isPaidEvent) {
      _priceController.text = event.ticketPrice?.toString() ?? '';
      _quantityController.text = event.maxAttendees?.toString() ?? '';
    }
    if (event.latitude != null && event.longitude != null) {
      _selectedLocation = latlong2.LatLng(event.latitude!, event.longitude!);
    }
    // Set existing image URLs
    _existingImageUrls = List<String>.from(event.imageUrls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Create Event' : 'Edit Event'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        // No AppBar actions for save button, moved to FAB.
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 20),
            _buildDateTimeSection(),
            const SizedBox(height: 20),
            _buildLocationSection(),
            const SizedBox(height: 20),
            _buildCategoryTagsSection(),
            const SizedBox(height: 20),
            _buildMediaSection(),
            const SizedBox(height: 20),
            _buildTicketingSection(),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _isLoading ? null : _saveEvent,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                widget.event == null ? 'Save' : 'Save Changes',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) => value?.isEmpty == true ? 'Description is required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Date & Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(_selectedDate == null ? 'Select Date' : 
                      '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                    leading: const Icon(Icons.calendar_today),
                    onTap: _selectDate,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    tileColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ListTile(
                    title: Text(_selectedTime == null ? 'Select Time' : _selectedTime!.format(context)),
                    leading: const Icon(Icons.access_time),
                    onTap: _selectTime,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    tileColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Search Location',
            border: const OutlineInputBorder(),
            suffixIcon: _isLoading 
              ? const CircularProgressIndicator()
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a location';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: flutter_map.FlutterMap(
            options: flutter_map.MapOptions(
              center: _selectedLocation ?? const latlong2.LatLng(31.5204, 74.3587),
              zoom: 13.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                  _updateLocationName(point);
                });
              },
            ),
            children: [
              flutter_map.TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              if (_selectedLocation != null)
                flutter_map.MarkerLayer(
                  markers: [
                    flutter_map.Marker(
                      point: _selectedLocation!,
                      builder: (ctx) => const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (_selectedLocation != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Selected: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category & Tags', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            const Text('Tags:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _tags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _tags.add(tag);
                      } else {
                        _tags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Media', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Photos'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Display existing images (URLs) and new images (Files)
            if (_existingImageUrls.isNotEmpty || _selectedImages.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Existing images from URLs
                    ..._existingImageUrls.asMap().entries.map((entry) {
                      int index = entry.key;
                      String imageUrl = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeExistingImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    
                    // New selected images from files
                    ..._selectedImages.asMap().entries.map((entry) {
                      int index = entry.key;
                      XFile imageFile = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.network(
                                      imageFile.path,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return FutureBuilder<Uint8List>(
                                          future: imageFile.readAsBytes(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Image.memory(
                                                snapshot.data!,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              );
                                            }
                                            return Container(
                                              width: 100,
                                              height: 100,
                                              color: Colors.grey,
                                              child: const Icon(Icons.image),
                                            );
                                          },
                                        );
                                      },
                                    )
                                  : Image.file(
                                      File(imageFile.path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeNewImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              
            if (_existingImageUrls.isEmpty && _selectedImages.isEmpty)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: const Center(
                  child: Text(
                    'No images selected\nTap "Add Photos" to select images',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ticketing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Free RSVP'),
                    value: false,
                    groupValue: _isPaidEvent,
                    onChanged: (value) => setState(() => _isPaidEvent = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Paid Event'),
                    value: true,
                    groupValue: _isPaidEvent,
                    onChanged: (value) => setState(() => _isPaidEvent = value!),
                  ),
                ),
              ],
            ),
            if (_isPaidEvent) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (\$)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => _isPaidEvent && (value?.isEmpty == true) 
                          ? 'Price is required for paid events' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Available Tickets',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => _isPaidEvent && (value?.isEmpty == true) 
                          ? 'Quantity is required for paid events' : null,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }
  
  void _removeExistingImage(int index) {
    setState(() => _existingImageUrls.removeAt(index));
  }
  
  void _removeNewImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    const String cloudName = 'daffsyxdy'; // TODO: Replace with your Cloudinary cloud name
    const String uploadPreset = 'Event Management'; // TODO: Replace with your unsigned upload preset
    final url = Uri.parse("https://api.cloudinary.com/v1_1/daffsyxdy/image/upload");


    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final respData = json.decode(respStr);
      return respData['secure_url'] as String?;
    } else {
      print('Cloudinary upload failed: ${response.statusCode}');
      return null;
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Upload images to Cloudinary first if any
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        try {
          print('Starting Cloudinary upload for ${_selectedImages.length} images...');
          for (final image in _selectedImages) {
            final url = await _uploadImageToCloudinary(File(image.path));
            if (url != null) {
              imageUrls.add(url);
            } else {
              throw Exception('Failed to upload image to Cloudinary');
            }
          }
          print('Cloudinary upload completed. Got ${imageUrls.length} URLs');
        } catch (e) {
          print('Cloudinary upload failed: $e');
          // Show user a choice: continue without images or retry
          final shouldContinue = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Image Upload Failed'),
              content: Text(
                'Failed to upload images: $e\n\n'
                'Would you like to save the event without images, or cancel and try again?'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Save Without Images'),
                ),
              ],
            ),
          ) ?? false;
          if (!shouldContinue) {
            return; // User chose to cancel
          }
          // Continue without images
          imageUrls = [];
        }
      }

      // Merge with existing image URLs
      final allImageUrls = [..._existingImageUrls, ...imageUrls];

      // Create event model
      final eventModel = EventModel(
        id: widget.event?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        organizerId: currentUser.uid,
        organizerName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
        eventDate: _selectedDate!,
        eventTime: _selectedTime,
        location: _locationController.text.trim(),
        latitude: _selectedLocation?.latitude,
        longitude: _selectedLocation?.longitude,
        category: _selectedCategory,
        tags: _tags,
        imageUrls: allImageUrls,
        ticketType: _isPaidEvent ? TicketType.paid : TicketType.free,
        ticketPrice: _isPaidEvent ? double.tryParse(_priceController.text) : null,
        maxAttendees: _isPaidEvent ? int.tryParse(_quantityController.text) : null,
        createdAt: widget.event?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      String eventId;
      if (widget.event == null) {
        // Create new event
        eventId = await _eventService.createEvent(eventModel);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Update existing event
        await _eventService.updateEvent(widget.event!.id, eventModel);
        eventId = widget.event!.id;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Return to previous screen with event data
      Navigator.pop(context, eventId);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving event: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateLocationName(latlong2.LatLng point) async {
    try {
      final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&zoom=18&addressdetails=1'
      ));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] ?? '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
        setState(() {
          _locationController.text = address;
        });
      }
    } catch (e) {
      _locationController.text = '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
    }
  }

  Future<void> _searchLocation() async {
    if (_locationController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Search for location
      final searchResponse = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${_locationController.text}&format=json&limit=1'
      ));
      
      if (searchResponse.statusCode == 200) {
        final data = json.decode(searchResponse.body);
        if (data.isNotEmpty) {
          final point = latlong2.LatLng(
            double.parse(data[0]['lat']),
            double.parse(data[0]['lon'])
          );
          
          setState(() {
            _selectedLocation = point;
          });
          
          // Get proper address name
          await _updateLocationName(point);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching location: ${e.toString()}'))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
