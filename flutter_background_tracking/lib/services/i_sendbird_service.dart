import '../models/location_message.dart';

abstract class ISendbirdService {
  static Future<void> initSdk() async {}
  Future<void> connect();
  Future<void> disconnect();
  Future<void> joinChannel(String channelUrl);
  Future<void> sendLocationUpdate(LocationMessage location);
  void listenToMessages(Function(LocationMessage) onLocationReceived);
}
