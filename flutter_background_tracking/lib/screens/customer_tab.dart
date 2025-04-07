import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/provider.dart';

class CustomerTab extends ConsumerStatefulWidget {
  const CustomerTab({super.key});

  @override
  ConsumerState<CustomerTab> createState() => _CustomerTabState();
}

class _CustomerTabState extends ConsumerState<CustomerTab> {
  GoogleMapController? _mapController;
  LatLng? _driverPosition;
  bool _initialCameraSet = false;

  @override
  Widget build(BuildContext context) {
    final customerManager = ref.watch(customerRideManagerProvider);
    final isRideActive = ref.watch(
      rideStateProvider.select((s) => s.isRideActive),
    );

    final allMessages = customerManager.allMessages;
    final routePoints = allMessages.map((m) => LatLng(m.lat, m.lon)).toList();
    // for (final p in routePoints) {
    //   debugPrint('🗺️ Route point: ${p.latitude}, ${p.longitude}');
    // }

    if (routePoints.isNotEmpty) {
      final latest = routePoints.last;
      if (_driverPosition != latest) {
        _driverPosition = latest;

        if (_mapController != null && !_initialCameraSet) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_driverPosition!, 15),
          );
          _initialCameraSet = true;
        }
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            isRideActive ? '🚗 A ride is active!' : '❌ No active ride',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _driverPosition ?? const LatLng(0, 0),
              zoom: _driverPosition != null ? 15 : 2,
            ),
            markers:
                _driverPosition != null
                    ? {
                      Marker(
                        markerId: const MarkerId('driver'),
                        position: _driverPosition!,
                        infoWindow: const InfoWindow(title: 'Driver'),
                      ),
                    }
                    : {},
            polylines: {
              if (routePoints.length > 1)
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: routePoints,
                  color: Colors.blue,
                  width: 5,
                ),
            },
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: false,
            zoomControlsEnabled: true,
          ),
        ),
      ],
    );
  }
}
