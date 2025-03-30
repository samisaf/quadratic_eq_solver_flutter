import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quadratic_eq_solver_flutter/model/equation.dart';

Equation equation = Equation(a: 5, b: 12, c: 8, minX: -10, maxX: 10, minY: -10, maxY: 10);

// final equationProvider = Provider((ref) => equation); // regular provider

class EquationNotifier extends Notifier<Equation>{
  @override
  Equation build() {
    return equation;
  }

  void updateEquation(Equation newEquation){
    state = newEquation;
  }

}

final equationNotifierProvider = NotifierProvider(() => EquationNotifier());