import 'package:flutter_background_tracking/services/customer_ride_manager.dart';
import 'package:flutter_background_tracking/services/driver_ride_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ride_state_service.dart';
import '../services/i_sendbird_service.dart';
import '../services/sendbird_service.dart';
import '../services/sendbird_service_mock.dart';

final rideStateProvider = ChangeNotifierProvider<RideStateService>((ref) {
  return RideStateService();
});

// Sendbird service for multiple users and option for mock service (2 users in one app does not work well)
const useMockSendbird = bool.fromEnvironment('USE_MOCK_SENDBIRD');

final sendbirdProvider = Provider<ISendbirdService>((ref) {
  if (useMockSendbird) {
    return MockSendbirdService('mockUserId');
  } else {
    return SendbirdService('realUserId');
  }
});

final sendbirdCustomerProvider = Provider<ISendbirdService>((ref) {
  if (useMockSendbird) {
    return MockSendbirdService("customerId");
  } else {
    return SendbirdService("customerId");
  }
});

final sendbirdDriverProvider = Provider<ISendbirdService>((ref) {
  if (useMockSendbird) {
    return MockSendbirdService("driverId");
  } else {
    return SendbirdService("driverId");
  }
});

// Ride manager split up for driver and customer
final driverRideManagerProvider = Provider<DriverRideManager>((ref) {
  return DriverRideManager(
    rideStateService: ref.read(rideStateProvider),
    sendbirdService: ref.read(sendbirdDriverProvider),
  );
});

final customerRideManagerProvider = ChangeNotifierProvider<CustomerRideManager>(
  (ref) {
    final rideState = ref.read(rideStateProvider);
    final sendbird = ref.read(sendbirdCustomerProvider);
    return CustomerRideManager(
      rideStateService: rideState,
      sendbirdService: sendbird,
    );
  },
);
