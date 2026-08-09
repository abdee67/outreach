import 'business_status.dart';
import 'reject_reason.dart';

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
    this.dateFirstContacted,
    this.dateLastContacted,
    this.totalCallAttempts = 0,
    this.lastCallDurationMin,
    this.followUpDate,
    this.rejectReason,
    this.dealValue,
    this.dateBooked,
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
  final DateTime? dateFirstContacted;
  final DateTime? dateLastContacted;
  final int totalCallAttempts;
  final int? lastCallDurationMin;
  final DateTime? followUpDate;
  final RejectReason? rejectReason;
  final double? dealValue;
  final DateTime? dateBooked;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasPendingFollowUp {
    if (followUpDate == null) return false;
    return followUpDate!.isAfter(DateTime.now());
  }

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
    DateTime? dateFirstContacted,
    DateTime? dateLastContacted,
    int? totalCallAttempts,
    int? lastCallDurationMin,
    DateTime? followUpDate,
    RejectReason? rejectReason,
    double? dealValue,
    DateTime? dateBooked,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearFollowUpDate = false,
    bool clearRejectReason = false,
    bool clearDateBooked = false,
    bool clearDealValue = false,
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
      dateFirstContacted: dateFirstContacted ?? this.dateFirstContacted,
      dateLastContacted: dateLastContacted ?? this.dateLastContacted,
      totalCallAttempts: totalCallAttempts ?? this.totalCallAttempts,
      lastCallDurationMin: lastCallDurationMin ?? this.lastCallDurationMin,
      followUpDate: clearFollowUpDate ? null : (followUpDate ?? this.followUpDate),
      rejectReason: clearRejectReason ? null : (rejectReason ?? this.rejectReason),
      dealValue: clearDealValue ? null : (dealValue ?? this.dealValue),
      dateBooked: clearDateBooked ? null : (dateBooked ?? this.dateBooked),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Business recordCall({required int durationMin}) {
    final now = DateTime.now();
    return copyWith(
      dateFirstContacted: dateFirstContacted ?? now,
      dateLastContacted: now,
      totalCallAttempts: totalCallAttempts + 1,
      lastCallDurationMin: durationMin,
      status: status == BusinessStatus.notContacted
          ? BusinessStatus.called
          : status,
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
      'date_first_contacted': dateFirstContacted?.toIso8601String(),
      'date_last_contacted': dateLastContacted?.toIso8601String(),
      'total_call_attempts': totalCallAttempts,
      'last_call_duration_min': lastCallDurationMin,
      'follow_up_date': followUpDate?.toIso8601String(),
      'reject_reason': rejectReason?.name,
      'deal_value': dealValue,
      'date_booked': dateBooked?.toIso8601String(),
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
      dateFirstContacted: _parseDateTime(map['date_first_contacted']),
      dateLastContacted: _parseDateTime(map['date_last_contacted']),
      totalCallAttempts: (map['total_call_attempts'] as num?)?.toInt() ?? 0,
      lastCallDurationMin: (map['last_call_duration_min'] as num?)?.toInt(),
      followUpDate: _parseDateTime(map['follow_up_date']),
      rejectReason: RejectReason.fromString(map['reject_reason'] as String?),
      dealValue: (map['deal_value'] as num?)?.toDouble(),
      dateBooked: _parseDateTime(map['date_booked']),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value == null || value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
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
