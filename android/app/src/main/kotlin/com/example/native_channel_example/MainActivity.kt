package com.example.native_channel_example

import com.shong.klog.Klog
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.flow
import java.util.*

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        makeRandomChannel(flutterEngine)

        makeKlogChannel(flutterEngine)

        makeCountChannel(flutterEngine)
    }

    private fun makeRandomChannel(flutterEngine: FlutterEngine) {
        val methodChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "example.com/Random")
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getRandomNumber" -> {
                    val rand = Random().nextInt(100)
                    result.success(rand)
                }
                "getRandomString" -> {
                    val rand = ('a'..'z').shuffled().take(4).joinToString("")
                    result.success(rand)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun makeKlogChannel(flutterEngine: FlutterEngine) {
        val methodChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "example.com/Klog")
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> {
                    Klog.reqPermission(this)
                    result.success("requestPermission")
                }
                "runFloating" -> {
                    Klog.runFloating(this)
                    result.success("runFloating")
                }
                "showFloatLog" -> {
                    val args = call.arguments as Map<*, *>

                    for (a in args.entries) {
                        if (a.key is String && a.value is String)
                            Klog.f(a.key as String, a.value as String)
                    }
                    result.success("showFloatLog")
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun makeCountChannel(flutterEngine: FlutterEngine) {
        val eventChannel =
            EventChannel(flutterEngine.dartExecutor.binaryMessenger, "example.com/Count")
        eventChannel.setStreamHandler(
            object : EventChannel.StreamHandler {
                var job: Job? = null
                val countFlow = flow<Int> {
                    var cnt = 0
                    while (true) {
                        this.emit(++cnt)
                        delay(1000)
                    }
                }

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    job?.cancel()
                    job = CoroutineScope(Dispatchers.Main).launch {
                        countFlow.collect {
                            events?.success(it)
                        }
                    }
                    Klog.d(this, "onListen Job Run")
                }

                override fun onCancel(arguments: Any?) {
                    job?.cancel()
                    Klog.d(this, "onCancel Job cancel")
                }

            }
        )
    }

    override fun onBackPressed() {
        super.onBackPressed()

        Klog.stopFloating(this)
        activity.finish()
    }

}
