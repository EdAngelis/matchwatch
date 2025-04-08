import 'package:flutter/material.dart';

void main() {
  runApp(const WearCountersApp());
}

class WearCountersApp extends StatelessWidget {
  const WearCountersApp({super.key});

  @override
  Widget build(BuildContext context) {
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
  }

  void _incrementRight() {
    setState(() => counterB++);
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
