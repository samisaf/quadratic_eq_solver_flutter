import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quadratic_eq_solver_flutter/model/equation_provider.dart';


class SolutionPage extends ConsumerWidget {
  const SolutionPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eq = ref.watch(equationNotifierProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Equation: ${eq.a}x² + ${eq.b}x + ${eq.c} = 0',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (eq.a == 0) ...[ // Handle linear case
              const Text(
                "This is a linear equation (a=0).",
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (eq.b != 0) Text('Solution: x = ${(-eq.c / eq.b).toStringAsFixed(3)}')
              else if (eq.c == 0) const Text('Solution: All x are solutions (0 = 0)')
              else const Text('Solution: No solution (c = 0, c != 0)'),

            ] else ...[ // Quadratic case
              Text(eq.solutions['description'], textAlign: TextAlign.center),
              if (eq.solutions['roots'] != null)
                Text(
                  'Roots: ${eq.solutions['roots']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 10),
              if (eq.solutions['vertex'] != null)
                Text(
                  'Vertex (x, y): ${eq.solutions['vertex']}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
            ]
          ],
        ),
      ),
    );
  }
  }
