class CityLocation {
  const CityLocation({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.state,
  });

  factory CityLocation.fromJson(Map<String, dynamic> json) {
    return CityLocation(
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      latitude: (json['lat'] as num?)?.toDouble() ?? 0,
      longitude: (json['lon'] as num?)?.toDouble() ?? 0,
      state: json['state'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'country': country,
      'lat': latitude,
      'lon': longitude,
      if (state != null) 'state': state,
    };
  }

  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String? state;

  String get displayName {
    if (state == null || state!.isEmpty) {
      return '$name, $country';
    }
    return '$name, $state, $country';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CityLocation &&
        other.name == name &&
        other.country == country &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.state == state;
  }

  @override
  int get hashCode => Object.hash(name, country, latitude, longitude, state);

  CityLocation copyWith({
    String? name,
    String? country,
    double? latitude,
    double? longitude,
    String? state,
  }) {
    return CityLocation(
      name: name ?? this.name,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      state: state ?? this.state,
    );
  }
}
