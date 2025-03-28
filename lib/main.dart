import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const title = "Quadratic Equation Solver";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
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
  final TextEditingController aController = TextEditingController();
  final TextEditingController bController = TextEditingController();
  final TextEditingController cController = TextEditingController();
  final TextEditingController minXController = TextEditingController();
  final TextEditingController maxXController = TextEditingController();
  final TextEditingController minYController = TextEditingController();
  final TextEditingController maxYController = TextEditingController();

  double a = 1.0;
  double b = 0.0;
  double c = 0.0;
  double minX = -10.0;
  double maxX = 10.0;
  double minY = -10.0;
  double maxY = 10.0;

  List<FlSpot> _generateDataPoints() {
    List<FlSpot> dataPoints = [];
    for (double x = minX; x <= maxX; x += 0.1) {
      double y = a * x * x + b * x + c;
      dataPoints.add(FlSpot(x, y));
    }
    return dataPoints;
  }

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    updateControllers();
  }

  void updateControllers(){
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
      appBar: AppBar(
        title: Text(title),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Inputs"),
            Tab(text: "Solution"),
            Tab(text: "Graph"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInputsTab(),
          _buildSolutionPage(),
          _buildChart(),
        ],
      ),
    );
  }

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
          Text("Enter equation coefficients"),
          _buildCoefficientInputs(),
          SizedBox(height: 10),
          Text("Enter initial graph bounds"),
          _buildChartBoundsInputs(),
        ],
      ),
    );
  }

  Widget _buildCoefficientInputs() {
    return Column(
      children: [

        _buildTextField('Coefficient a', aController, (value) => setState(() => a = double.tryParse(value) ?? a)),
        _buildTextField('Coefficient b', bController, (value) => setState(() => b = double.tryParse(value) ?? b)),
        _buildTextField('Coefficient c', cController, (value) => setState(() => c = double.tryParse(value) ?? c)),
      ],
    );
  }

  Widget _buildChartBoundsInputs() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 3,
      children: [
        _buildTextField('Min X', minXController, (value) => setState(() => minX = double.tryParse(value) ?? minX)),
        _buildTextField('Max X', maxXController, (value) => setState(() => maxX = double.tryParse(value) ?? maxX)),
        _buildTextField('Min Y', minYController, (value) => setState(() => minY = double.tryParse(value) ?? minY)),
        _buildTextField('Max Y', maxYController, (value) => setState(() => maxY = double.tryParse(value) ?? maxY)),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: UnderlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: onChanged,
      ),
    );
  }

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

  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: value == 0 ? Colors.black : Colors.grey,
                      strokeWidth: value == 0 ? 2 : 0.5,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: value == 0 ? Colors.black : Colors.grey,
                      strokeWidth: value == 0 ? 2 : 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text('x'),
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text('y'),
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                minX: minX,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateDataPoints(),
                    isCurved: true,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          GridView.count(
            crossAxisSpacing: 10.0,mainAxisSpacing: 10.0,
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 5,
            children: [
              FilledButton(onPressed: _zoomIn, child: Text('Zoom In')),
              FilledButton(onPressed: _zoomOut, child: Text('Zoom Out')),
              FilledButton(onPressed: _moveLeft, child: Text('Move Left')),
              FilledButton(onPressed: _moveRight, child: Text('Move Right')),
            ],
          )
        ],
      ),
    );
  }

  void _zoomIn() {
    setState(() {
      minX *= 0.9;
      maxX *= 0.9;
      minY *= 0.9;
      maxY *= 0.9;
    });
  }

  void _zoomOut() {
    setState(() {
      minX *= 1.1;
      maxX *= 1.1;
      minY *= 1.1;
      maxY *= 1.1;
    });
  }

  void _moveLeft() {
    setState(() {
      minX -= 1;
      maxX -= 1;
    });
  }

  void _moveRight() {
    setState(() {
      minX += 1;
      maxX += 1;
    });
  }
}
