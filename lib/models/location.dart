class Location {
  final int id;
  final String name;
  final int cityId;
  final int provinceId;
  final int countryId;
  final LocationCity? city;
  final LocationProvince? province;
  final LocationCountry? country;

  Location({
    required this.id,
    required this.name,
    required this.cityId,
    required this.provinceId,
    required this.countryId,
    this.city,
    this.province,
    this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as int,
      name: json['name'] as String,
      cityId: json['city_id'] as int,
      provinceId: json['province_id'] as int,
      countryId: json['country_id'] as int,
      city: json['city'] != null
          ? LocationCity.fromJson(json['city'] as Map<String, dynamic>)
          : null,
      province: json['province'] != null
          ? LocationProvince.fromJson(json['province'] as Map<String, dynamic>)
          : null,
      country: json['country'] != null
          ? LocationCountry.fromJson(json['country'] as Map<String, dynamic>)
          : null,
    );
  }

  String get displayName {
    final parts = <String>[name];
    if (city != null) parts.add(city!.name);
    if (province != null) parts.add(province!.name);
    if (country != null) parts.add(country!.name);
    return parts.join(', ');
  }
}

class LocationCity {
  final int id;
  final String name;
  final int provinceId;
  final int countryId;

  LocationCity({
    required this.id,
    required this.name,
    required this.provinceId,
    required this.countryId,
  });

  factory LocationCity.fromJson(Map<String, dynamic> json) {
    return LocationCity(
      id: json['id'] as int,
      name: json['name'] as String,
      provinceId: json['province_id'] as int,
      countryId: json['country_id'] as int,
    );
  }
}

class LocationProvince {
  final int id;
  final String name;
  final int countryId;

  LocationProvince({
    required this.id,
    required this.name,
    required this.countryId,
  });

  factory LocationProvince.fromJson(Map<String, dynamic> json) {
    return LocationProvince(
      id: json['id'] as int,
      name: json['name'] as String,
      countryId: json['country_id'] as int,
    );
  }
}

class LocationCountry {
  final int id;
  final String name;
  final String code;

  LocationCountry({
    required this.id,
    required this.name,
    required this.code,
  });

  factory LocationCountry.fromJson(Map<String, dynamic> json) {
    return LocationCountry(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
    );
  }
}
