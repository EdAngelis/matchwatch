import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const WearCountersApp());
}

class MessageSender {
  static const MethodChannel _channel = MethodChannel('wear/counter_channel');

  static Future<void> sendMessage(String message) async {
    try {
      await _channel.invokeMethod('sendMessage', {'message': message});
    } catch (e) {
      print('Failed to send message: $e');
    }
  }
}

class MessageReceiver {
  static const MethodChannel _channel = MethodChannel('wear/counter_channel');

  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      print("Received message from native: ${call.method}");
      if (call.method == "onMessageReceived") {
        final String message = call.arguments as String;
        print("Message received from native: $message");
        // Handle the message (e.g., update the UI or state)
      }
    });
  }
}

class WearCountersApp extends StatelessWidget {
  const WearCountersApp({super.key});

  @override
  Widget build(BuildContext context) {
    MessageReceiver.initialize(); // Initialize the message receiver
    print("WearCountersApp initialized");
    return MaterialApp(
      title: 'Wear OS Counters',
      theme: ThemeData.dark(),
      home: const DualCounterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DualCounterScreen extends StatefulWidget {
  const DualCounterScreen({super.key});

  @override
  State<DualCounterScreen> createState() => _DualCounterScreenState();
}

class _DualCounterScreenState extends State<DualCounterScreen> {
  int counterA = 0;
  int counterB = 0;

  void _incrementLeft() {
    setState(() => counterA++);
    MessageSender.sendMessage("1");
  }

  void _incrementRight() {
    setState(() => counterB++);
    MessageSender.sendMessage("0");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (TapUpDetails details) {
            final screenWidth = MediaQuery.of(context).size.width;
            final dx = details.localPosition.dx;

            if (dx < screenWidth / 2) {
              _incrementLeft();
            } else {
              _incrementRight();
            }
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TAP TO COUNT',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Text(
                  'A: $counterA    B: $counterB',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
