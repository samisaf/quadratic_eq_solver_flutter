import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quadratic_eq_solver_flutter/model/equation.dart';
import 'package:quadratic_eq_solver_flutter/model/equation_provider.dart';

class InputPage extends ConsumerStatefulWidget {
  const InputPage({super.key});

  @override
  ConsumerState<InputPage> createState() => _InputPageState();
}

class _InputPageState extends ConsumerState<InputPage> {
  // Use late initialization or initialize directly in initState
  late final TextEditingController _aController;
  late final TextEditingController _bController;
  late final TextEditingController _cController;
  late final TextEditingController _minXController;
  late final TextEditingController _maxXController;
  late final TextEditingController _minYController;
  late final TextEditingController _maxYController;

  // Key for the Form widget
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values from the provider
    // Use ref.read here as we only need the initial value in initState
    final initialEquation = ref.read(equationNotifierProvider);
    _aController = TextEditingController(text: initialEquation.a.toString());
    _bController = TextEditingController(text: initialEquation.b.toString());
    _cController = TextEditingController(text: initialEquation.c.toString());
    _minXController = TextEditingController(text: initialEquation.minX.toString());
    _maxXController = TextEditingController(text: initialEquation.maxX.toString());
    _minYController = TextEditingController(text: initialEquation.minY.toString());
    _maxYController = TextEditingController(text: initialEquation.maxY.toString());
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the tree
    _aController.dispose();
    _bController.dispose();
    _cController.dispose();
    _minXController.dispose();
    _maxXController.dispose();
    _minYController.dispose();
    _maxYController.dispose();
    super.dispose();
  }

  // Helper function for validation
  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    // Add more specific validation if needed (e.g., a != 0)
    // if (label == 'Coefficient a' && double.tryParse(value) == 0) {
    //   return 'Coefficient a cannot be zero';
    // }
    return null; // Return null if valid
  }

  // Build TextField using TextFormField for validation
  Widget _buildTextFormField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField( // Changed from TextField
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          // border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
        validator: _validateNumber, // Use the validator function
        // Optional: Update provider on field change (can be noisy)
        // onChanged: (_) => _trySubmitForm(showErrors: false),
        // Optional: Update provider when focus is lost
        // onEditingComplete: () => _trySubmitForm(showErrors: false),
      ),
    );
  }

  void _submitForm() {
    // Validate all FormFields
    if (_formKey.currentState!.validate()) {
      // If the form is valid, parse the values (use tryParse for safety, although validator should ensure they are parsable)
      final a = double.tryParse(_aController.text) ?? 0.0; // Provide default or handle error
      final b = double.tryParse(_bController.text) ?? 0.0;
      final c = double.tryParse(_cController.text) ?? 0.0;
      final minX = double.tryParse(_minXController.text) ?? -10.0;
      final maxX = double.tryParse(_maxXController.text) ?? 10.0;
      final minY = double.tryParse(_minYController.text) ?? -10.0;
      final maxY = double.tryParse(_maxYController.text) ?? 10.0;

      // Optional: Add validation for min/max pairs
      if (minX >= maxX) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Min X must be less than Max X')),
        );
        return; // Don't submit if bounds are invalid
      }
      if (minY >= maxY) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Min Y must be less than Max Y')),
        );
        return; // Don't submit if bounds are invalid
      }

      // Update the state in the Riverpod provider
      ref.read(equationNotifierProvider.notifier).updateEquation(
        Equation(
          a: a,
          b: b,
          c: c,
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
        ),
      );

      // Optional: Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equation updated!')),
      );
      // Optional: Unfocus keyboard
      FocusScope.of(context).unfocus();

    } else {
      // Optional: Show a general error message if validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to react to external changes
    // Note: This can cause controllers to reset if not handled carefully.
    // The current setup primarily initializes from the provider state
    // and updates the provider on submit. If external updates need
    // to reflect live in the text fields while the user might be typing,
    // more complex logic is needed (e.g., comparing current text vs provider state).
    // For many forms, initializing once and submitting is sufficient.
    ref.watch(equationNotifierProvider); // Keep watching to rebuild if state changes externally

    // --- Optional: More robust synchronization (if needed) ---
    // This checks if the provider state differs from the text field and updates
    // the field. Use with caution as it can interfere with user input.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final currentEquation = ref.read(equationNotifierProvider);
    //   if (_aController.text != currentEquation.a.toString()) {
    //     _aController.text = currentEquation.a.toString();
    //   }
    //   // ... repeat for other controllers ...
    // });
    // --- End Optional Synchronization ---


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form( // Wrap content in a Form widget
        key: _formKey, // Assign the key
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Enter coefficients for ax² + bx + c and graph bounds.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text("Equation Coefficients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildTextFormField('Coefficient a', _aController),
            _buildTextFormField('Coefficient b', _bController),
            _buildTextFormField('Coefficient c', _cController),
            const SizedBox(height: 30),
            const Text("Graph Bounds", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(child: _buildTextFormField('Min X', _minXController)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextFormField('Max X', _maxXController)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildTextFormField('Min Y', _minYController)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextFormField('Max Y', _maxYController)),
              ],
            ),
            const SizedBox(height: 20), // Add space before button
            Center( // Center the button
              child: FilledButton(
                onPressed: _submitForm, // Call the submit function
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}