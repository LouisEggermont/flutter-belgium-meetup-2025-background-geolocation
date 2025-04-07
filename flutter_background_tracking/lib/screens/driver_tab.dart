import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider.dart';

class DriverTab extends ConsumerWidget {
  const DriverTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideState = ref.watch(rideStateProvider);
    final isActive = rideState.isRideActive;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              isActive ? rideState.stopRide() : rideState.startRide();
            },
            child: Text(isActive ? 'Stop Ride' : 'Start Ride'),
          ),
        ],
      ),
    );
  }
}
