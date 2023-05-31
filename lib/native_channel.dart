import 'package:flutter/services.dart';

enum NativeChannel { random, klog, count }

extension ChannelExtension on NativeChannel {
  static const String _randomPath = 'example.com/Random';
  static const String _klogPath = 'example.com/Klog';
  static const String _countPath = 'example.com/Count';

  bool get isMethodChannel {
    switch (this) {
      case NativeChannel.random:
        return true;
      case NativeChannel.klog:
        return true;
      case NativeChannel.count:
        return false;
    }
  }

  String get platformPath {
    switch (this) {
      case NativeChannel.random:
        return _randomPath;
      case NativeChannel.klog:
        return _klogPath;
      case NativeChannel.count:
        return _countPath;
    }
  }

  MethodChannel get methodChannel {
    switch (this) {
      case NativeChannel.random:
        return const MethodChannel(_randomPath);
      case NativeChannel.klog:
        return const MethodChannel(_klogPath);
      default:
        throw Exception('UnDefined MethodChannel Name <$name>');
    }
  }

  EventChannel get eventChannel {
    switch (this) {
      case NativeChannel.count:
        return const EventChannel(_countPath);
      default:
        throw Exception('UnDefined EventChannel Name <$name}>');
    }
  }

  Future<String> callMethod(String method, [Map<String, String>? args]) async {
    try {
      final result = await methodChannel.invokeMethod(method, args);
      return '$result';
    } on PlatformException catch (e) {
      return 'error message : ${e.message}';
    }
  }
}
