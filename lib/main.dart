import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quadratic_eq_solver_flutter/model/equation_provider.dart';
import 'package:quadratic_eq_solver_flutter/screens/chart_page.dart';
import 'package:quadratic_eq_solver_flutter/screens/input_page.dart';
import 'package:quadratic_eq_solver_flutter/screens/solution_page.dart';

const String appTitle = "Quadratic Solver & Plotter"; // Renamed for clarity

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true, // Recommended for new apps
      ),
      // Removed title parameter here as it's not used by QuadraticPlotter constructor
      home: Test(),
    );
  }
}

class Test extends ConsumerWidget {
  static const size = 12.0;
  const Test({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eq = ref.watch(equationNotifierProvider);

    return DefaultTabController(length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle), // Use const Text
          bottom:
            TabBar(
              labelStyle: const TextStyle(fontSize: 11),
              labelPadding: EdgeInsets.zero,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [ // Use const Tabs
                Tab(text: "Inputs", icon: Icon(Icons.input), iconMargin: EdgeInsets.only(bottom: 2)),
                Tab(text: "Graph", icon: Icon(Icons.show_chart), iconMargin: EdgeInsets.only(bottom: 2)),
              ],
            ),        ),
        body: TabBarView(
          children: [
            InputPage(),
            ChartPage()
          ],
        ),
      ),
    );
  }

}
