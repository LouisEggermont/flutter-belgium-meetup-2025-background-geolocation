import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce/hive.dart';
import '../models/location_message.dart';
import 'geolocation_service.dart';
import 'i_sendbird_service.dart';
import 'ride_state_service.dart';

class DriverRideManager {
  DriverRideManager({
    required RideStateService rideStateService,
    required ISendbirdService sendbirdService,
  }) {
    debugPrint("🚀 DriverRideManager initialized");

    rideStateService.addListener(() {
      final isActive = rideStateService.isRideActive;
      debugPrint("🔁 Ride state changed: $isActive");

      if (isActive) {
        _startRide(sendbirdService);
      } else {
        _stopRide(sendbirdService);
      }
    });
  }

  Future<void> _startRide(ISendbirdService sendbirdService) async {
    await sendbirdService.connect();
    await sendbirdService.joinChannel(dotenv.env['SENDBIRD_CHANNEL_URL']!);

    final box = await Hive.openBox<LocationMessage>('locationBox');

    debugPrint("🟢 Driver started ride...");

    GeolocationService.onLocationUpdate = (bg.Location location) {
      final message = LocationMessage(
        lat: location.coords.latitude,
        lon: location.coords.longitude,
        speed: location.coords.speed,
        battery: location.battery.level * 100,
        timestamp:
            DateTime.parse(location.timestamp).millisecondsSinceEpoch ~/ 1000,
      );
      debugPrint("📍 [Driver] Sending location update");
      sendbirdService.sendLocationUpdate(message);
      box.add(message);
    };

    GeolocationService.startTracking();
  }

  void _stopRide(ISendbirdService sendbirdService) async {
    debugPrint("🔴 Driver stopped ride");
    GeolocationService.stopTracking();
    GeolocationService.onLocationUpdate = null;
    sendbirdService.disconnect();

    final box = Hive.box<LocationMessage>('locationBox');
    await box.clear();
  }
}
