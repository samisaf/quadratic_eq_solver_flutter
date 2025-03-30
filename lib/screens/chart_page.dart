import 'package:flutter/material.dart';
import 'package:quadratic_eq_solver_flutter/screens/chart_control.dart';
import 'chart_graph.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Expanded(child: ChartGraph()), SafeArea(child:ChartControl())],);
  }
}
