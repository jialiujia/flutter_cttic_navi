import 'nav_point.dart';

enum NavType {
  IN, OUT
}

class NavEnity {
  late NavType _type;
  late String _userId;
  late String _deviceId;
  late String _carNo;
  late NavPoint? _startPoint;
  late NavPoint _endPoint;
  late List<NavPoint> _intermediatePoints;

  NavEnity(NavType type, String userId, String deviceId, String carNo, NavPoint endPoint,
      {NavPoint? startPoint, List<NavPoint>? intermediatePoints}) {
    _type = type;
    _userId = userId;
    _deviceId = deviceId;
    _carNo = carNo;
    _startPoint = startPoint;
    _endPoint = endPoint;
    if(intermediatePoints == null) {
      _intermediatePoints = [];
    } else {
      _intermediatePoints = intermediatePoints;
    }
  }

  NavType get type => _type;

  List<NavPoint> get intermediatePoints => _intermediatePoints;

  NavPoint get endPoint => _endPoint;

  NavPoint? get startPoint => _startPoint;

  String get carNo => _carNo;

  String get deviceId => _deviceId;

  String get userId => _userId;

  Map<String, dynamic> toJson() => {
    'type': _type.index,
    'userId': _userId,
    'deviceId': _deviceId,
    'carNo': _carNo,
    'startPoint': _startPoint?.toJson(),
    'endPoint': _endPoint.toJson(),
    'intermediatePoints': (_intermediatePoints.map((e) {return e.toJson();}).toList())
  };
}