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
  late final TextEditingController _minXController;
  late final TextEditingController _maxXController;
  late final TextEditingController _minYController;
  late final TextEditingController _maxYController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final eq = ref.read(equationNotifierProvider);
    _minXController = TextEditingController(text: eq.minX.toString());
    _maxXController = TextEditingController(text: eq.maxX.toString());
    _minYController = TextEditingController(text: eq.minY.toString());
    _maxYController = TextEditingController(text: eq.maxY.toString());
  }

  @override
  void dispose() {
    _minXController.dispose();
    _maxXController.dispose();
    _minYController.dispose();
    _maxYController.dispose();
    super.dispose();
  }

  void _updateBounds() {
    if (_formKey.currentState!.validate()) {
      final minX = double.tryParse(_minXController.text) ?? -10.0;
      final maxX = double.tryParse(_maxXController.text) ?? 10.0;
      final minY = double.tryParse(_minYController.text) ?? -10.0;
      final maxY = double.tryParse(_maxYController.text) ?? 10.0;

      final eq = ref.read(equationNotifierProvider);
      ref.read(equationNotifierProvider.notifier).updateEquation(
            Equation(
              a: eq.a,
              b: eq.b,
              c: eq.c,
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eq = ref.watch(equationNotifierProvider);

    // Sync controllers if state changes from elsewhere (e.g. pan/zoom)
    if (double.tryParse(_minXController.text) != eq.minX) {
      _minXController.text = eq.minX.toStringAsFixed(2);
      _maxXController.text = eq.maxX.toStringAsFixed(2);
      _minYController.text = eq.minY.toStringAsFixed(2);
      _maxYController.text = eq.maxY.toStringAsFixed(2);
    }

    void _pan({required double dxFactor, required double dyFactor}) {
      final double width = eq.maxX - eq.minX;
      final double height = eq.maxY - eq.minY;
      final double dx = width * dxFactor;
      final double dy = height * dyFactor;

      ref.read(equationNotifierProvider.notifier).updateEquation(
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
      ref.read(equationNotifierProvider.notifier).updateEquation(
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minXController,
                    decoration: const InputDecoration(labelText: 'Min X', isDense: true),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) => _updateBounds(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _maxXController,
                    decoration: const InputDecoration(labelText: 'Max X', isDense: true),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) => _updateBounds(),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minYController,
                    decoration: const InputDecoration(labelText: 'Min Y', isDense: true),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) => _updateBounds(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _maxYController,
                    decoration: const InputDecoration(labelText: 'Max Y', isDense: true),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) => _updateBounds(),
                  ),
                ),
              ],
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 6,
              children: [
                IconButton(onPressed: () => _zoom(0.75), icon: const Icon(Icons.zoom_in)),
                IconButton(onPressed: () => _zoom(1.25), icon: const Icon(Icons.zoom_out)),
                IconButton(onPressed: () => _pan(dxFactor: -0.1, dyFactor: 0), icon: const Icon(Icons.arrow_back)),
                IconButton(onPressed: () => _pan(dxFactor: 0.1, dyFactor: 0), icon: const Icon(Icons.arrow_forward)),
                IconButton(onPressed: () => _pan(dxFactor: 0, dyFactor: 0.1), icon: const Icon(Icons.arrow_upward)),
                IconButton(onPressed: () => _pan(dxFactor: 0, dyFactor: -0.1), icon: const Icon(Icons.arrow_downward)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
