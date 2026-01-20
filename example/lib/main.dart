import 'package:flutter/material.dart';
import 'package:flutter_body_part_selector/flutter_body_part_selector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Body Part Selector Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BodySelectorExample(),
    );
  }
}

class BodySelectorExample extends StatefulWidget {
  const BodySelectorExample({super.key});

  @override
  State<BodySelectorExample> createState() => _BodySelectorExampleState();
}

class _BodySelectorExampleState extends State<BodySelectorExample> {
  final controller = BodyMapController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Part Selector'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip),
            onPressed: controller.toggleView,
            tooltip: 'Flip view',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: controller.clearSelection,
            tooltip: 'Clear selection',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Column(
            children: [
              if (controller.selectedMuscles.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade900,
                  width: double.infinity,
                  child: Text(
                    'Selected: ${controller.selectedMuscles.length} muscle(s)',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: InteractiveBodySvg(
                  isFront: controller.isFront,
                  selectedMuscles: controller.selectedMuscles,
                  onMuscleTap: controller.selectMuscle,
                  highlightColor: Colors.blue.withOpacity(0.7),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
