import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Title of the application
const title = "Quadratic Equation Solver";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Setting the title of the app
      title: title,
      // Defining the app theme color scheme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      // Setting the initial screen of the app to the QuadraticPlotter widget
      home: QuadraticPlotter(title),
    );
  }
}

class QuadraticPlotter extends StatefulWidget {
  const QuadraticPlotter(title, {super.key});

  @override
  _QuadraticPlotterState createState() => _QuadraticPlotterState();
}

class _QuadraticPlotterState extends State<QuadraticPlotter> with SingleTickerProviderStateMixin {
  // Text controllers for user input
  final TextEditingController aController = TextEditingController();
  final TextEditingController bController = TextEditingController();
  final TextEditingController cController = TextEditingController();
  final TextEditingController minXController = TextEditingController();
  final TextEditingController maxXController = TextEditingController();
  final TextEditingController minYController = TextEditingController();
  final TextEditingController maxYController = TextEditingController();

  // Default values for coefficients and graph bounds
  double a = 1.0;
  double b = 0.0;
  double c = 0.0;
  double minX = -10.0;
  double maxX = 10.0;
  double minY = -10.0;
  double maxY = 10.0;

  // Generate data points for the quadratic function to plot
  List<FlSpot> _generateDataPoints() {
    List<FlSpot> dataPoints = [];
    for (double x = minX; x <= maxX; x += 0.1) {
      double y = a * x * x + b * x + c;
      dataPoints.add(FlSpot(x, y));
    }
    return dataPoints;
  }

  // Controller for the tab view
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize text fields with default values
    aController.text = a.toString();
    bController.text = b.toString();
    cController.text = c.toString();
    minXController.text = minX.toString();
    maxXController.text = maxX.toString();
    minYController.text = minY.toString();
    maxYController.text = maxY.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display app bar with tab navigation
      appBar: AppBar(
        title: Text(title),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Inputs"),      // Input coefficients and bounds
            Tab(text: "Solution"),    // Display solution related messages
            Tab(text: "Graph"),       // Plot graph
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInputsTab(),    // Render inputs tab
          _buildSolutionPage(), // Render solution page
          _buildChart(),        // Render chart
        ],
      ),
    );
  }

  // Build the inputs tab UI
  Widget _buildInputsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Text(
            'This app helps solve and plot a quadratic function of the form ax² + bx + c = 0. Adjust the coefficients and graph bounds below.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text("Enter coefficients"),
          _buildCoefficientInputs(), // Input fields for coefficients
          SizedBox(height: 10),
          Text("Enter graph bounds"),
          _buildChartBoundsInputs(), // Input fields for graph bounds
        ],
      ),
    );
  }

  // Build input fields for the coefficients a, b, c
  Widget _buildCoefficientInputs() {
    return Column(
      children: [
        _buildTextField('Coefficient a', aController, (value) => setState(() => a = double.tryParse(value) ?? a)),
        _buildTextField('Coefficient b', bController, (value) => setState(() => b = double.tryParse(value) ?? b)),
        _buildTextField('Coefficient c', cController, (value) => setState(() => c = double.tryParse(value) ?? c)),
      ],
    );
  }

  // Build input fields for the graph bounds
  Widget _buildChartBoundsInputs() {
    return Column(
      children: [
        _buildTextField('Min X', minXController, (value) => setState(() => minX = double.tryParse(value) ?? minX)),
        _buildTextField('Max X', maxXController, (value) => setState(() => maxX = double.tryParse(value) ?? maxX)),
        _buildTextField('Min Y', minYController, (value) => setState(() => minY = double.tryParse(value) ?? minY)),
        _buildTextField('Max Y', maxYController, (value) => setState(() => maxY = double.tryParse(value) ?? maxY)),
      ],
    );
  }

  // Helper method to build text input field
  Widget _buildTextField(String label, TextEditingController controller, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: UnderlineInputBorder(),
        ),
        keyboardType: TextInputType.number, // Allow only numeric input
        onChanged: onChanged,
      ),
    );
  }

  // Build the solution page which includes a description
  Widget _buildSolutionPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'This app plots a quadratic function based on the coefficients you provide. Adjust the input fields to see the changes in the plot.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Build the chart to plot the quadratic function
  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true), // Enable grid lines
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              axisNameWidget: Text('x'), // Label for x-axis
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text('y'), // Label for y-axis
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: true), // Enable border
          minX: minX, // Minimum x value for graph
          maxX: maxX, // Maximum x value for graph
          minY: minY, // Minimum y value for graph
          maxY: maxY, // Maximum y value for graph
          lineBarsData: [
            LineChartBarData(
              spots: _generateDataPoints(), // Data points to plot
              isCurved: true,               // Curve the line
              barWidth: 3,                  // Width of the line
              dotData: FlDotData(show: false), // Hide data point dots
            ),
          ],
        ),
      ),
    );
  }
}
