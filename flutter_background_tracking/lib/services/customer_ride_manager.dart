import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce/hive.dart';
import '../models/location_message.dart';
import 'i_sendbird_service.dart';
import 'ride_state_service.dart';

class CustomerRideManager extends ChangeNotifier {
  final RideStateService _rideStateService;
  final ISendbirdService _sendbirdService;
  final List<LocationMessage> _receivedMessages = [];

  List<LocationMessage> get allMessages {
    final box = Hive.box<LocationMessage>('locationBox');
    final hiveMessages = box.values.toList();
    final messageSet = {...hiveMessages, ..._receivedMessages};
    return messageSet.toList();
  }

  bool _isListening = false;

  CustomerRideManager({
    required RideStateService rideStateService,
    required ISendbirdService sendbirdService,
  }) : _rideStateService = rideStateService,
       _sendbirdService = sendbirdService {
    debugPrint("🚀 CustomerRideManager initialized");
    _loadStoredLocations();
    _rideStateService.addListener(_onRideStateChanged);
  }

  Future<void> _loadStoredLocations() async {
    final box = await Hive.openBox<LocationMessage>('locationBox');
    final stored = box.values.cast<LocationMessage>().toList();

    _receivedMessages.clear();
    _receivedMessages.addAll(stored);

    debugPrint('📦 Loaded ${stored.length} stored locations from Hive');
    notifyListeners();
  }

  void _onRideStateChanged() {
    final isActive = _rideStateService.isRideActive;
    debugPrint("📡 [Customer] Ride state changed: $isActive");

    if (isActive) {
      _startListening();
    } else {
      _stopListening();
    }
  }

  void _startListening() async {
    if (_isListening) return;

    debugPrint("🟢 [Customer] Start listening for location updates");
    _isListening = true;

    await _sendbirdService.connect();
    await _sendbirdService.joinChannel(dotenv.env['SENDBIRD_CHANNEL_URL']!);

    _sendbirdService.listenToMessages((LocationMessage message) {
      debugPrint("📥 [Customer] Received location: ${message.toJson()}");
      _receivedMessages.add(message);

      final box = Hive.box<LocationMessage>('locationBox');
      box.add(message);

      notifyListeners();
    });
  }

  void _stopListening() {
    if (!_isListening) return;

    debugPrint("🔴 [Customer] Stop listening for location updates");
    _isListening = false;

    _sendbirdService.disconnect();
    _receivedMessages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint("💀 CustomerRideManager disposed");
    _stopListening();
    _rideStateService.removeListener(_onRideStateChanged);
    super.dispose();
  }
}
