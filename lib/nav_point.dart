class NavPoint {
  late String _name;
  late double _latitude;
  late double _longitude;

  NavPoint({name, latitude = 0.0, longitude = 0.0}) {
    _name = name;
    _latitude = latitude;
    _longitude = longitude;
  }

  double get longitude => _longitude;

  double get latitude => _latitude;

  String get name => _name;

  Map<String, dynamic> toJson() => {
    'name': name,
    'latitude': _latitude,
    'longitude': _longitude
  };
}