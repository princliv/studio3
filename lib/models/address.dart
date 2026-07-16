class Address {
  const Address({
    required this.id,
    this.label,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.zip,
    this.country = 'US',
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  final String id;
  final String? label;
  final String firstName;
  final String lastName;
  final String phone;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String zip;
  final String country;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  String get fullName => '$firstName $lastName';

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      label: json['label'] as String?,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      line1: json['line1'] as String? ?? '',
      line2: json['line2'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zip: json['zip'] as String? ?? '',
      country: json['country'] as String? ?? 'US',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toRequestBody() {
    return {
      if (label != null && label!.isNotEmpty) 'label': label,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'line1': line1,
      if (line2 != null && line2!.isNotEmpty) 'line2': line2,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (isDefault) 'isDefault': isDefault,
    };
  }

  Address copyWith({
    String? id,
    String? label,
    String? firstName,
    String? lastName,
    String? phone,
    String? line1,
    String? line2,
    String? city,
    String? state,
    String? zip,
    String? country,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
