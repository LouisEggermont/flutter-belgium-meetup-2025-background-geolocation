import 'package:hive_ce/hive.dart';
part 'location_message.g.dart';

@HiveType(typeId: 0)
class LocationMessage {
  @HiveField(0)
  final double lat;

  @HiveField(1)
  final double lon;

  @HiveField(2)
  final int timestamp;

  @HiveField(3)
  final double battery;

  @HiveField(4)
  final double speed;

  LocationMessage({
    required this.lat,
    required this.lon,
    required this.timestamp,
    required this.battery,
    required this.speed,
  });

  factory LocationMessage.fromJson(Map<String, dynamic> json) {
    return LocationMessage(
      lat: json['lat'],
      lon: json['lon'],
      timestamp: json['timestamp'],
      battery: json['battery'],
      speed: json['speed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
      'timestamp': timestamp,
      'battery': battery,
      'speed': speed,
    };
  }
}
