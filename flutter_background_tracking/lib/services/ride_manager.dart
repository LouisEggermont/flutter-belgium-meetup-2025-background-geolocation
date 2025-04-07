import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_background_tracking/services/geolocation_service.dart';
import 'package:flutter_background_tracking/services/i_sendbird_service.dart';
import 'package:flutter_background_tracking/services/ride_state_service.dart';
import '../models/location_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationMessageListProvider =
    StateNotifierProvider<LocationMessageListNotifier, List<LocationMessage>>((
      ref,
    ) {
      return LocationMessageListNotifier();
    });

class LocationMessageListNotifier extends StateNotifier<List<LocationMessage>> {
  LocationMessageListNotifier() : super([]);

  void add(LocationMessage message) {
    state = [...state, message];
  }

  void clear() {
    state = [];
  }
}

class RideManager {
  RideManager({
    required RideStateService rideStateService,
    required ISendbirdService sendbirdService,
    required WidgetRef ref,
  }) {
    debugPrint("🚀 RideManager initialized");

    rideStateService.addListener(() {
      final isActive = rideStateService.isRideActive;
      debugPrint("🔁 Ride state changed: $isActive");

      if (isActive) {
        _startRide(sendbirdService, ref);
      } else {
        _stopRide(sendbirdService, ref);
      }
    });
  }

  Future<void> _startRide(
    ISendbirdService sendbirdService,
    WidgetRef ref,
  ) async {
    await sendbirdService.connect();
    final channelUrl = dotenv.env['SENDBIRD_CHANNEL_URL'];
    if (channelUrl == null) throw Exception("Channel URL missing from .env");
    await sendbirdService.joinChannel(dotenv.env['SENDBIRD_CHANNEL_URL']!);

    debugPrint("🟢 Starting ride...");

    GeolocationService.onLocationUpdate = (bg.Location location) {
      final message = LocationMessage(
        lat: location.coords.latitude,
        lon: location.coords.longitude,
        speed: location.coords.speed,
        battery: location.battery.level * 100,
        timestamp:
            DateTime.parse(location.timestamp).millisecondsSinceEpoch ~/ 1000,
      );
      debugPrint("📍 [RideManager] Location update to be sent.");
      sendbirdService.sendLocationUpdate(message);
    };

    sendbirdService.listenToMessages((LocationMessage message) {
      debugPrint("📥 [RideManager] Received location: ${message.toJson()}");
      ref.read(locationMessageListProvider.notifier).add(message);
    });

    GeolocationService.startTracking();
  }

  void _stopRide(ISendbirdService sendbirdService, WidgetRef ref) {
    debugPrint("🔴 Stopping ride...");
    GeolocationService.stopTracking();
    GeolocationService.onLocationUpdate = null;
    ref.read(locationMessageListProvider.notifier).clear();
    sendbirdService.disconnect();
  }
}
