// Generated by Hive CE
// Do not modify
// Check in to version control

import 'package:hive_ce/hive.dart';
import 'package:flutter_background_tracking/models/location_message.dart';

extension HiveRegistrar on HiveInterface {
  void registerAdapters() {
    registerAdapter(LocationMessageAdapter());
  }
}
