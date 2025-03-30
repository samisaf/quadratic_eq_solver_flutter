import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quadratic_eq_solver_flutter/model/equation_provider.dart';
import 'package:quadratic_eq_solver_flutter/model/equation.dart';

class ChartControl extends ConsumerStatefulWidget {
  const ChartControl({super.key});

  @override
  ConsumerState<ChartControl> createState() => _ChartControlState();
}

class _ChartControlState extends ConsumerState<ChartControl> {
  @override
  Widget build(BuildContext context) {
    final eq = ref.watch(equationNotifierProvider);

    // --- Zoom and Pan Methods ---
    void _pan({required double dxFactor, required double dyFactor}) {
      final double width = eq.maxX - eq.minX;
      final double height = eq.maxY - eq.minY;
      final double dx = width * dxFactor;
      final double dy = height * dyFactor;

      ref
          .read(equationNotifierProvider.notifier)
          .updateEquation(
            Equation(
              a: eq.a,
              b: eq.b,
              c: eq.c,
              minX: eq.minX + dx,
              maxX: eq.maxX + dx,
              minY: eq.minY + dy,
              maxY: eq.maxY + dy,
            ),
          );
    }

    void _zoom(double factor) {
      final double centerX = (eq.minX + eq.maxX) / 2.0;
      final double centerY = (eq.minY + eq.maxY) / 2.0;
      final double newWidth = (eq.maxX - eq.minX) * factor;
      final double newHeight = (eq.maxY - eq.minY) * factor;
      ref
          .read(equationNotifierProvider.notifier)
          .updateEquation(
            Equation(
              a: eq.a,
              b: eq.b,
              c: eq.c,
              minX: centerX - newWidth / 2.0,
              maxX: centerX + newWidth / 2.0,
              minY: centerY - newHeight / 2.0,
              maxY: centerY + newHeight / 2.0,
            ),
          );
    }
    // _validateBounds(); // Ensure bounds remain valid after zoom

    // _updateControllersFromState(); // IMPORTANT: Update text fields
    // _generateDataPoints(); // Regenerate data for new bounds
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.count(
        shrinkWrap: true, // Important in a Column
        physics:
            const NeverScrollableScrollPhysics(), // Disable GridView's scroll
        crossAxisCount: 6, // Arrange buttons nicely
        // crossAxisSpacing: 4.0,
        // mainAxisSpacing: 4.0,
        // childAspectRatio: 1.8, // Adjust button shape
        children: [
          IconButton(
            onPressed: () => _zoom(0.75),
            icon: const Icon(Icons.zoom_in),
          ),
          IconButton(
            onPressed: () => _zoom(1.25),
            icon: const Icon(Icons.zoom_out),
          ),
          IconButton(
            onPressed: () => _pan(dxFactor: -0.1, dyFactor: 0),
            icon: const Icon(Icons.arrow_back),
          ),
          IconButton(
            onPressed: () => _pan(dxFactor: 0.1, dyFactor: 0),
            icon: const Icon(Icons.arrow_forward),
          ),
          // Add Up/Down Buttons
          IconButton(
            onPressed: () => _pan(dxFactor: 0, dyFactor: 0.1),
            icon: const Icon(Icons.arrow_upward),
          ),
          IconButton(
            onPressed: () => _pan(dxFactor: 0, dyFactor: -0.1),
            icon: const Icon(Icons.arrow_downward),
          ),
        ],
      ),
    );
  }
}
