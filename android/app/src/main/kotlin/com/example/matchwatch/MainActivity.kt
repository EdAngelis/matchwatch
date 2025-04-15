package com.example.matchwatch

import android.os.Bundle
import com.google.android.gms.wearable.MessageClient
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.Wearable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), MessageClient.OnMessageReceivedListener {
    private val CHANNEL = "wear/counter_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendMessage") {
                val message = call.argument<String>("message") ?: "0"
                sendMessageToPhone(message)
                result.success("sent")
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        Wearable.getMessageClient(this).addListener(this)
    }

    override fun onPause() {
        super.onPause()
        Wearable.getMessageClient(this).removeListener(this)
    }

    override fun onMessageReceived(messageEvent: MessageEvent) {
        if (messageEvent.path == "/counter") {
            val message = String(messageEvent.data)
            // Ensure binaryMessenger is non-null before invoking the method
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("onMessageReceived", message)
            }
        }
    }

    private fun sendMessageToPhone(message: String) {
        Thread {
            try {
                Wearable.getNodeClient(this).connectedNodes
                    .addOnSuccessListener { nodes ->
                        for (node in nodes) {
                            Wearable.getMessageClient(this)
                                .sendMessage(node.id, "/counter", message.toByteArray())
                                .addOnSuccessListener {
                                    println("Message sent successfully to node: ${node.displayName}")
                                }
                                .addOnFailureListener { e ->
                                    e.printStackTrace() // Handle failure
                                }
                        }
                    }
                    .addOnFailureListener { e ->
                        e.printStackTrace() // Handle failure to get nodes
                    }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }.start()
    }
}
