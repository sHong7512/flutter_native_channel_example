import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'native_channel.dart';

class NativeChannelPage extends StatefulWidget {
  const NativeChannelPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<NativeChannelPage> createState() => _NativeChannelPageState();
}

class _NativeChannelPageState extends State<NativeChannelPage> {
  String _value = 'empty';

  StreamSubscription? _countStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_value, textAlign: TextAlign.center),
          _button(NativeChannel.random, 'getRandomNumber'),
          _button(NativeChannel.random, 'getRandomString'),
          ElevatedButton(
            onPressed: () {
              if (_countStream == null) {
                _countStream =
                    NativeChannel.count.eventChannel.receiveBroadcastStream().listen((event) {
                  _value = 'count :: $event';
                  setState(() {});
                });
              } else {
                _countStream?.cancel();
                _countStream = null;

                _value = "count :: canceled!";
                setState(() {});
              }
            },
            child: const Text('countStream start/stop'),
          ),
          if (Platform.isAndroid) _button(NativeChannel.klog, 'requestPermission'),
          if (Platform.isAndroid) _button(NativeChannel.klog, 'runFloating'),
          if (Platform.isAndroid)
            _button(NativeChannel.klog, 'showFloatLog', {
              '${DateTime.now().hour}h ${DateTime.now().minute}m ${DateTime.now().second}s':
                  'Message!!'
            }),
          if (Platform.isIOS) _button(NativeChannel.overlay, 'showNativeOverlay'),
        ],
      ),
    );
  }

  ElevatedButton _button(NativeChannel channelName, String method, [Map<String, String>? args]) {
    return ElevatedButton(
      onPressed: () async {
        _value = await channelName.callMethod(method, args);
        setState(() {});
      },
      child: Text(method),
    );
  }

  @override
  void dispose() {
    _countStream?.cancel();
    super.dispose();
  }
}
