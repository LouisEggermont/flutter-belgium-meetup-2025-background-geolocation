import 'package:flutter/material.dart';
import 'package:flutter_background_tracking/services/sendbird_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/driver_tab.dart';
import 'screens/customer_tab.dart';
import 'services/geolocation_service.dart';
import 'models/location_message.dart';
import 'providers/provider.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

@pragma('vm:entry-point')
void headlessTask(bg.HeadlessEvent headlessEvent) async {
  debugPrint('[📡 HeadlessTask] Received event: ${headlessEvent.name}');

  switch (headlessEvent.name) {
    case bg.Event.LOCATION:
      final bg.Location location = headlessEvent.event;
      debugPrint(
        '📍 [HeadlessTask] Location: ${location.coords.latitude}, ${location.coords.longitude}',
      );

      final appDocDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocDir.path);
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(LocationMessageAdapter());
      }

      final box = await Hive.openBox<LocationMessage>('locationBox');

      final locationMessage = LocationMessage(
        lat: location.coords.latitude,
        lon: location.coords.longitude,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        battery: location.battery.level * 100,
        speed: location.coords.speed,
      );

      await box.add(locationMessage);
      await box.close();

      break;

    case bg.Event.TERMINATE:
      debugPrint('🛑 App was terminated');
      break;

    case bg.Event.MOTIONCHANGE:
      debugPrint('🚶 Motion change: ${headlessEvent.event}');
      break;

    default:
      debugPrint('[HeadlessTask] Unhandled event: ${headlessEvent.name}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  Hive.registerAdapter(LocationMessageAdapter());
  await Hive.openBox<LocationMessage>('locationBox');
  await Hive.openBox('ride_state');

  await WakelockPlus.enable(); // Prevent the device from sleeping

  await GeolocationService.init();
  await SendbirdService.initSdk();

  runApp(const ProviderScope(child: MyApp()));

  bg.BackgroundGeolocation.registerHeadlessTask(headlessTask);
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(driverRideManagerProvider);
    ref.watch(customerRideManagerProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tracking POC',
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Tracking POC'),
            bottom: const TabBar(
              tabs: [Tab(text: 'Driver'), Tab(text: 'Customer')],
            ),
          ),
          body: const TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [DriverTab(), CustomerTab()],
          ),
        ),
      ),
    );
  }
}
