import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class GeolocationService {
  static Function(bg.Location)? onLocationUpdate;

  static Future<void> init() async {
    await bg.BackgroundGeolocation.ready(
      bg.Config(
        // notification: bg.Notification(
        //   title: "Tracking Active",
        //   text: "Your location is being tracked",
        //   // channelName: "Location Tracking",
        //   // priority: bg.Config.NOTIFICATION_PRIORITY_HIGH,
        // ),
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        // enableHeadless: true,
        // time-based tracking on Android
        distanceFilter: 0,
        locationUpdateInterval: 8000, // This interval is inexact
        fastestLocationUpdateInterval: 3000,
        // distanceFilter: 10.0,
        stopOnTerminate: false,
        startOnBoot: true,
        debug: false,
        pausesLocationUpdatesAutomatically: false,
        disableStopDetection: true,
        isMoving: true, // only for android emulator location simulation 🚨🚨
        stopTimeout: 0,
        geofenceModeHighAccuracy: true,
        logLevel: bg.Config.LOG_LEVEL_OFF,
      ),
    );

    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      debugPrint(
        "📍 Location update received: ${location.coords.latitude}, ${location.coords.longitude}",
      );
      if (onLocationUpdate != null) {
        onLocationUpdate!(location);
      }
    });
    debugPrint("✅ Geolocation initialized");
  }

  static Future<void> startTracking() async {
    debugPrint("🏁 Attempting to start tracking...");

    final state = await bg.BackgroundGeolocation.state;

    if (state.enabled) {
      debugPrint("⚠️ Tracking is already started, skipping...");
      return;
    }

    try {
      await bg.BackgroundGeolocation.start();
      // await bg.BackgroundGeolocation.changePace(true);
      debugPrint("✅ Background geolocation started");
    } catch (e) {
      debugPrint("❌ Failed to start tracking: $e");
    }
  }

  static Future<void> stopTracking() async {
    debugPrint("🛑 Stopping background tracking...");
    await bg.BackgroundGeolocation.stop();
    debugPrint("🛑 Background tracking stopped");
  }
}
