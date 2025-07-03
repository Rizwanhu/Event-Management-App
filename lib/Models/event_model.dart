import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show TimeOfDay;

enum EventStatus {
  draft,
  pending,
  approved,
  rejected,
  live,
  completed,
  cancelled
}

enum TicketType {
  free,
  paid,
  donation
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final String organizerId;
  final String organizerName;
  final DateTime eventDate;
  final TimeOfDay? eventTime;
  final String location;
  final double? latitude;
  final double? longitude;
  final String category;
  final List<String> tags;
  final List<String> imageUrls;
  final TicketType ticketType;
  final double? ticketPrice;
  final int? maxAttendees;
  final int currentAttendees;
  final EventStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final String? rejectionReason;
  final Map<String, dynamic>? customFields;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.organizerId,
    required this.organizerName,
    required this.eventDate,
    this.eventTime,
    required this.location,
    this.latitude,
    this.longitude,
    required this.category,
    this.tags = const [],
    this.imageUrls = const [],
    this.ticketType = TicketType.free,
    this.ticketPrice,
    this.maxAttendees,
    this.currentAttendees = 0,
    this.status = EventStatus.draft,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = false,
    this.rejectionReason,
    this.customFields,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'eventDate': Timestamp.fromDate(eventDate),
      'eventTime': eventTime != null ? '${eventTime!.hour}:${eventTime!.minute}' : null,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'tags': tags,
      'imageUrls': imageUrls,
      'ticketType': ticketType.toString().split('.').last,
      'ticketPrice': ticketPrice,
      'maxAttendees': maxAttendees,
      'currentAttendees': currentAttendees,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublished': isPublished,
      'rejectionReason': rejectionReason,
      'customFields': customFields,
    };
  }

  static EventModel fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      organizerId: map['organizerId'] ?? '',
      organizerName: map['organizerName'] ?? '',
      eventDate: (map['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eventTime: map['eventTime'] != null ? 
        TimeOfDay(
          hour: int.parse(map['eventTime'].split(':')[0]),
          minute: int.parse(map['eventTime'].split(':')[1])
        ) : null,
      location: map['location'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      category: map['category'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      ticketType: _parseTicketType(map['ticketType']),
      ticketPrice: map['ticketPrice']?.toDouble(),
      maxAttendees: map['maxAttendees']?.toInt(),
      currentAttendees: map['currentAttendees']?.toInt() ?? 0,
      status: _parseEventStatus(map['status']),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublished: map['isPublished'] ?? false,
      rejectionReason: map['rejectionReason'],
      customFields: map['customFields'],
    );
  }

  static TicketType _parseTicketType(String? ticketType) {
    switch (ticketType) {
      case 'free':
        return TicketType.free;
      case 'paid':
        return TicketType.paid;
      case 'donation':
        return TicketType.donation;
      default:
        return TicketType.free;
    }
  }

  static EventStatus _parseEventStatus(String? status) {
    switch (status) {
      case 'draft':
        return EventStatus.draft;
      case 'pending':
        return EventStatus.pending;
      case 'approved':
        return EventStatus.approved;
      case 'rejected':
        return EventStatus.rejected;
      case 'live':
        return EventStatus.live;
      case 'completed':
        return EventStatus.completed;
      case 'cancelled':
        return EventStatus.cancelled;
      default:
        return EventStatus.draft;
    }
  }

  EventModel copyWith({
    String? title,
    String? description,
    String? organizerId,
    String? organizerName,
    DateTime? eventDate,
    TimeOfDay? eventTime,
    String? location,
    double? latitude,
    double? longitude,
    String? category,
    List<String>? tags,
    List<String>? imageUrls,
    TicketType? ticketType,
    double? ticketPrice,
    int? maxAttendees,
    int? currentAttendees,
    EventStatus? status,
    DateTime? updatedAt,
    bool? isPublished,
    String? rejectionReason,
    Map<String, dynamic>? customFields,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      imageUrls: imageUrls ?? this.imageUrls,
      ticketType: ticketType ?? this.ticketType,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isPublished: isPublished ?? this.isPublished,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      customFields: customFields ?? this.customFields,
    );
  }
}
