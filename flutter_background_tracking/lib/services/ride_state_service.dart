import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class RideStateService extends ChangeNotifier {
  bool _isRideActive = false;
  final String _boxName = 'ride_state';

  bool get isRideActive => _isRideActive;

  RideStateService() {
    _loadRideState(); // Load when the service is created
  }

  Future<void> _loadRideState() async {
    final box = await Hive.openBox(_boxName);
    _isRideActive = box.get('isRideActive', defaultValue: false);
    notifyListeners();
  }

  Future<void> startRide() async {
    _isRideActive = true;
    final box = await Hive.openBox(_boxName);
    await box.put('isRideActive', true);
    notifyListeners();
  }

  Future<void> stopRide() async {
    _isRideActive = false;
    final box = await Hive.openBox(_boxName);
    await box.put('isRideActive', false);
    notifyListeners();
  }
}
