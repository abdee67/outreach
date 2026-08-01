import 'business_status.dart';

class Business {
  Business({
    this.id,
    required this.name,
    this.address,
    this.category,
    this.phone,
    this.latitude,
    this.longitude,
    this.googleMapsUrl,
    this.status = BusinessStatus.notContacted,
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final int? id;
  final String name;
  final String? address;
  final String? category;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final String? googleMapsUrl;
  final BusinessStatus status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Business copyWith({
    int? id,
    String? name,
    String? address,
    String? category,
    String? phone,
    double? latitude,
    double? longitude,
    String? googleMapsUrl,
    BusinessStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      category: category ?? this.category,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'category': category,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'google_maps_url': googleMapsUrl,
      'status': status.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      id: map['id'] as int?,
      name: map['name'] as String,
      address: map['address'] as String?,
      category: map['category'] as String?,
      phone: map['phone'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      googleMapsUrl: map['google_maps_url'] as String?,
      status: BusinessStatus.fromString(map['status'] as String? ?? ''),
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class CategoryCount {
  const CategoryCount({required this.category, required this.count});

  final String category;
  final int count;
}

class BusinessStats {
  const BusinessStats({
    required this.total,
    required this.notContacted,
    required this.called,
    required this.interested,
    required this.booked,
    required this.rejected,
  });

  final int total;
  final int notContacted;
  final int called;
  final int interested;
  final int booked;
  final int rejected;

  static const empty = BusinessStats(
    total: 0, 
    notContacted: 0,
    called: 0, 
    interested: 0,
    booked: 0,
    rejected: 0,
  );
}
