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
              '${eq.a}x² + ${eq.b}x + ${eq.c} = 0', textAlign: TextAlign.center
            ),
            const SizedBox(height: 20),
            if (eq.a == 0) ...[ // Handle linear case
              const Text(
                "This is a linear equation (a=0).",
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (eq.b != 0) Text('Solution: x = ${(-eq.c / eq.b).toStringAsFixed(3)}', style: const TextStyle(fontFamily: 'serif', fontStyle: FontStyle.italic))
              else if (eq.c == 0) const Text('Solution: x \u2208 \u211D', style: TextStyle(fontFamily: 'serif'))
              else const Text('Solution: x \u2208 \u2205', style: TextStyle(fontFamily: 'serif')),

            ] else ...[ // Quadratic case
              Text(eq.solutions['description'], textAlign: TextAlign.center),
              const SizedBox(height: 20),

              if (eq.solutions['roots'] != null)
                Text(
                  'x = ${eq.solutions['roots']}',
                  // style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif', fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              // const SizedBox(height: 10),
              if (eq.solutions['vertex'] != null)
                Text(
                  'vertex = ${eq.solutions['vertex']}',
                  // style: const TextStyle(fontSize: 16, fontFamily: 'serif', fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
            ]
          ],
        ),
      ),
    );
  }
  }
