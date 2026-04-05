import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quadratic_eq_solver_flutter/model/equation.dart';
import 'package:quadratic_eq_solver_flutter/model/equation_provider.dart';
import 'package:quadratic_eq_solver_flutter/screens/solution_page.dart';

class InputPage extends ConsumerStatefulWidget {
  const InputPage({super.key});

  @override
  ConsumerState<InputPage> createState() => _InputPageState();
}

class _InputPageState extends ConsumerState<InputPage> {
  late final TextEditingController _aController;
  late final TextEditingController _bController;
  late final TextEditingController _cController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final initialEquation = ref.read(equationNotifierProvider);
    _aController = TextEditingController(text: initialEquation.a.toString());
    _bController = TextEditingController(text: initialEquation.b.toString());
    _cController = TextEditingController(text: initialEquation.c.toString());
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _cController.dispose();
    super.dispose();
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  Widget _buildTextFormField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
        validator: _validateNumber,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final a = double.tryParse(_aController.text) ?? 0.0;
      final b = double.tryParse(_bController.text) ?? 0.0;
      final c = double.tryParse(_cController.text) ?? 0.0;

      final Map<String, double> newBounds = Equation.computeSensibleBounds(a, b, c);

      ref.read(equationNotifierProvider.notifier).updateEquation(
        Equation(
          a: a,
          b: b,
          c: c,
          minX: newBounds['minX']!,
          maxX: newBounds['maxX']!,
          minY: newBounds['minY']!,
          maxY: newBounds['maxY']!,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equation updated!')),
      );
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(equationNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: Text(
                'ax² + bx + c = 0',
                style: TextStyle(fontSize: 16, fontFamily: 'serif', fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextFormField('Coefficient a', _aController),
            _buildTextFormField('Coefficient b', _bController),
            _buildTextFormField('Coefficient c', _cController),
            const SizedBox(height: 20),
            Center(
              child: FilledButton(
                onPressed: _submitForm,
                child: const Text("Calculate Solution & Update Graph"),
              ),
            ),
            const Divider(height: 40),
            const SolutionPage(),
          ],
        ),
      ),
    );
  }
}
