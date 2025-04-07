import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/location_message.dart';
import '../services/i_sendbird_service.dart';

class SendbirdService implements ISendbirdService {
  final String userId;
  OpenChannel? _channel;
  static bool _initialized = false;

  SendbirdService(this.userId);

  static Future<void> initSdk() async {
    if (_initialized) return;

    final appId = dotenv.env['SENDBIRD_APP_ID'];
    if (appId == null || appId.isEmpty) {
      throw Exception('Missing SENDBIRD_APP_ID in environment');
    }

    debugPrint("📦 Initializing Sendbird SDK with App ID: $appId");
    SendbirdChat.init(appId: appId);
    _initialized = true;
    debugPrint("✅ Sendbird SDK initialized");
  }

  @override
  Future<void> connect() async {
    try {
      await SendbirdChat.connect(userId);
      debugPrint("✅ Connected to Sendbird as $userId");
    } catch (e) {
      debugPrint("❌ Sendbird connection error: $userId $e");
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await SendbirdChat.disconnect();
      debugPrint("✅ Disconnected from Sendbird");
    } catch (e) {
      debugPrint("❌ Failed to disconnect from Sendbird: $e");
    }
  }

  @override
  Future<void> joinChannel(String channelUrl) async {
    try {
      _channel = await OpenChannel.getChannel(channelUrl);
      await _channel!.enter();
      debugPrint("✅ Joined and entered channel $channelUrl");
    } catch (e) {
      debugPrint("❌ Failed to join channel: $e");
    }
  }

  @override
  Future<void> sendLocationUpdate(LocationMessage location) async {
    if (_channel == null) {
      debugPrint("⚠️ No active channel to send message");
      return;
    }

    final payload = jsonEncode(location.toJson());
    final params = UserMessageCreateParams(message: payload);

    _channel!.sendUserMessage(
      params,
      handler: (UserMessage message, SendbirdException? e) {
        if (e != null) {
          debugPrint("❌ Failed to send location message: $e");
        } else {
          debugPrint("📤 Sent location update: ${message.message}");
        }
      },
    );
  }

  @override
  void listenToMessages(Function(LocationMessage) onLocationReceived) {
    debugPrint("📡 Setting up channel handler for incoming messages");
    final handler = _LocationHandler(onLocationReceived);
    SendbirdChat.addChannelHandler("location_listener", handler);
  }
}

class _LocationHandler extends OpenChannelHandler {
  final void Function(LocationMessage) callback;

  _LocationHandler(this.callback);

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    debugPrint("📥 Handler triggered on channel: ${channel.channelUrl}");
    debugPrint("📥 Message: ${message.message}");

    if (message is UserMessage) {
      try {
        final data = jsonDecode(message.message);
        final location = LocationMessage.fromJson(data);
        callback(location);
      } catch (e) {
        debugPrint("❌ Failed to parse location message: $e");
      }
    } else {
      debugPrint("⚠️ Ignored non-UserMessage: ${message.runtimeType}");
    }
  }
}
