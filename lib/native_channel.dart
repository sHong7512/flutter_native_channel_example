import 'dart:io';

import 'package:flutter/services.dart';

enum NativeChannel { random, klog, count, overlay }

extension ChannelExtension on NativeChannel {
  static const String _randomPath = 'example.com/Random';
  static const String _klogPath = 'example.com/Klog';
  static const String _countPath = 'example.com/Count';
  static const String _overlayPath = 'example.com/Overlay';

  bool get isMethodChannel {
    switch (this) {
      case NativeChannel.random:
        return true;
      case NativeChannel.klog:
        if(Platform.isAndroid) return true;
        return false;
      case NativeChannel.count:
        return false;
      case NativeChannel.overlay:
        if(Platform.isIOS) return true;
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
      case NativeChannel.overlay:
        return _overlayPath;
    }
  }

  MethodChannel get methodChannel {
    switch (this) {
      case NativeChannel.random:
        return const MethodChannel(_randomPath);
      case NativeChannel.klog:
        return const MethodChannel(_klogPath);
      case NativeChannel.overlay:
        return const MethodChannel(_overlayPath);
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
