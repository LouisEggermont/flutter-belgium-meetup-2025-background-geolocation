import 'dart:async';
import 'package:flutter/material.dart';
import '../models/location_message.dart';
import '../services/i_sendbird_service.dart';

const int mockDelayMultiplier = 1; // Change to 0 for no delay

class MockSendbirdService implements ISendbirdService {
  static bool _initialized = false;

  static Future<void> initSdk() async {
    if (_initialized) return;
    await Future.delayed(Duration(milliseconds: 100 * mockDelayMultiplier));
    _initialized = true;
    debugPrint("✅ [Mock] SDK initialized");
  }

  final String userId;

  static final StreamController<LocationMessage> _messageController =
      StreamController<LocationMessage>.broadcast();

  StreamSubscription<LocationMessage>? _subscription;

  MockSendbirdService(this.userId);

  @override
  Future<void> connect() async {
    await Future.delayed(Duration(milliseconds: 300 * mockDelayMultiplier));
    debugPrint("✅ [Mock] Connected as $userId");
  }

  @override
  Future<void> joinChannel(String channelUrl) async {
    await Future.delayed(Duration(milliseconds: 200 * mockDelayMultiplier));
    debugPrint("✅ [Mock] Joined channel $channelUrl");
  }

  @override
  Future<void> sendLocationUpdate(LocationMessage location) async {
    await Future.delayed(Duration(milliseconds: 100 * mockDelayMultiplier));
    debugPrint("📤 [Mock][$userId] Sent location update: ${location.toJson()}");
    _messageController.add(location);
  }

  @override
  void listenToMessages(Function(LocationMessage) onLocationReceived) {
    debugPrint("📡 [Mock][$userId] Listening for messages");
    _subscription = _messageController.stream.listen((location) {
      debugPrint("📥 [Mock][$userId] Received location: ${location.toJson()}");
      onLocationReceived(location);
    });
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    debugPrint("✅ [Mock] Disconnected");
  }
}
