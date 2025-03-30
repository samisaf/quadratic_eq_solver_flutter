import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quadratic_eq_solver_flutter/model/equation.dart';
import 'package:quadratic_eq_solver_flutter/model/equation_provider.dart'; // Assuming this defines EquationState
import 'dart:math';

// --- Constants for Styling and Configuration ---
const double _axisStrokeWidth = 1.5;
const double _gridStrokeWidth = 0.5;
const double _lineBarWidth = 2.5;
const double _axisTitleFontSize = 14.0; // Adjusted from axisNameSize
const double _axisLabelReservedSize = 30.0; // Increased slightly for potentially larger numbers

/// A widget that displays a line chart representation of a quadratic equation.
///
/// It observes the equation state from [equationNotifierProvider] and renders
/// the corresponding parabola using the `fl_chart` package.
class ChartGraph extends ConsumerWidget {
  const ChartGraph({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eqState = ref.watch(equationNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final gridColor = Colors.grey.withOpacity(0.3); // Could also use theme color if desired
    final axisColor = theme.disabledColor; // Using a less prominent theme color for axes


    // --- Pre-calculate intervals ---
    // Ensure valid ranges before calculating intervals
    final double horizontalInterval = (eqState.maxX > eqState.minX)
        ? _calculateNiceInterval(eqState.minX, eqState.maxX)
        : 1.0;
    final double verticalInterval = (eqState.maxY > eqState.minY)
        ? _calculateNiceInterval(eqState.minY, eqState.maxY)
        : 1.0;

    // --- Build Chart Data ---
    final chartData = _buildLineChartData(
      context: context,
      eqState: eqState,
      horizontalInterval: horizontalInterval,
      verticalInterval: verticalInterval,
      gridColor: gridColor,
      axisColor: axisColor,
      colorScheme: colorScheme,
      textTheme: textTheme,
    );

    // --- Handle potential invalid range ---
    // fl_chart can sometimes throw errors if min/max are equal or inverted.
    if (eqState.minX >= eqState.maxX || eqState.minY >= eqState.maxY) {
      return Center(
        child: Text(
          'Invalid data range for chart.',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
        ),
      );
    }

    return Padding(
      // Add some padding around the chart
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
        chartData,
        // Optional: duration for animations when data changes
        // swapAnimationDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  /// Builds the core configuration for the LineChart.
  LineChartData _buildLineChartData({
    required BuildContext context,
    required Equation eqState, // Assuming your provider provides an 'EquationState' object
    required double horizontalInterval,
    required double verticalInterval,
    required Color gridColor,
    required Color axisColor,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return LineChartData(
      // --- Grid ---
      gridData: _buildGridData(
        horizontalInterval: horizontalInterval,
        verticalInterval: verticalInterval,
        gridColor: gridColor,
        axisColor: axisColor,
      ),

      // --- Titles (Labels & Axis Names) ---
      titlesData: _buildTitlesData(
        horizontalInterval: horizontalInterval,
        verticalInterval: verticalInterval,
        axisColor: axisColor,
        textTheme: textTheme,
      ),

      // --- Border ---
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: axisColor.withOpacity(0.5), width: 1),
      ),

      // --- Axis Limits ---
      minX: eqState.minX,
      maxX: eqState.maxX,
      minY: eqState.minY,
      maxY: eqState.maxY,

      // --- Line Data ---
      lineBarsData: [
        _buildLineBarData(eqState.dataPoints, colorScheme.primary),
      ],

      // --- Tooltips (Optional but Recommended) ---
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          // tooltipBgColor: colorScheme.primary.withOpacity(0.8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '(${spot.x.toStringAsFixed(1)}, ${spot.y.toStringAsFixed(1)})', // Format numbers
                TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true, // Enable tap/drag gestures
      ),
    );
  }

  /// Configures the grid lines.
  FlGridData _buildGridData({
    required double horizontalInterval,
    required double verticalInterval,
    required Color gridColor,
    required Color axisColor,
  }) {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      getDrawingHorizontalLine: (value) => _getAxisLine(value, gridColor, axisColor),
      horizontalInterval: horizontalInterval,
      drawVerticalLine: true,
      getDrawingVerticalLine: (value) => _getAxisLine(value, gridColor, axisColor),
      verticalInterval: verticalInterval,
    );
  }

  /// Helper to draw grid/axis lines, making the 0-axis thicker.
  FlLine _getAxisLine(double value, Color gridColor, Color axisColor) {
    final bool isAxis = (value - 0.0).abs() < 0.001; // Check if value is close to zero
    return FlLine(
      color: isAxis ? axisColor : gridColor,
      strokeWidth: isAxis ? _axisStrokeWidth : _gridStrokeWidth,
    );
  }

  /// Configures the axis titles (labels and names).
  FlTitlesData _buildTitlesData({
    required double horizontalInterval,
    required double verticalInterval,
    required Color axisColor,
    required TextTheme textTheme,
  }) {
    return FlTitlesData(
      show: true,
      // --- Bottom (X Axis) ---
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: _axisLabelReservedSize,
          interval: horizontalInterval,
          getTitlesWidget: (value, meta) =>
              _buildSideTitleWidget(value, meta, textTheme, axisColor),
        ),
        // axisNameWidget: Text('x', style: textTheme.titleSmall?.copyWith(color: axisColor)),
        axisNameSize: _axisTitleFontSize + 4, // Slightly larger space for axis name
      ),
      // --- Left (Y Axis) ---
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: _axisLabelReservedSize,
          interval: verticalInterval,
          getTitlesWidget: (value, meta) =>
              _buildSideTitleWidget(value, meta, textTheme, axisColor),
        ),
        // axisNameWidget: Text('y', style: textTheme.titleSmall?.copyWith(color: axisColor)),
        axisNameSize: _axisTitleFontSize + 4,
      ),
      // --- Hide Top & Right ---
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  /// Builds the widget for individual axis labels.
  Widget _buildSideTitleWidget(double value, TitleMeta meta, TextTheme textTheme, Color axisColor) {
    // Avoid drawing label at min/max edge if it overlaps axis name or looks cluttered
    // if (value == meta.min || value == meta.max) {
    //   return Container();
    // }
    final style = textTheme.bodySmall?.copyWith(
      color: axisColor,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    // Format label (e.g., show 1 decimal place)
    final String text = value.toStringAsFixed(meta.appliedInterval < 0.5 ? 1 : 0);

    return SideTitleWidget(meta: meta,
      // axisSide: meta.axisSide,
      space: 4.0, // Padding between axis line and label text
      child: Text(text, style: style),
    );
  }

  /// Configures the appearance of the plotted line.
  LineChartBarData _buildLineBarData(List<(double, double)> points, Color lineColor) {
    return LineChartBarData(
      spots: points.map((p) => FlSpot(p.$1, p.$2)).toList(),
      isCurved: true,
      color: lineColor,
      barWidth: _lineBarWidth,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  /// Calculate a reasonable interval for grid lines/labels.
  /// Tries to find a "nice" number (multiples of 1, 2, 5, 10).
  /// Renamed from _calculateGridInterval for clarity.
  double _calculateNiceInterval(double min, double max) {
    // If range is zero or negative, return a default interval
    if (max <= min) return 1.0;

    final double range = max - min;
    // Aim for roughly 4-8 grid lines/labels
    double roughInterval = range / 5.0;

    // Calculate the exponent and magnitude
    double exponent = (log(roughInterval) / ln10).floor().toDouble();
    double magnitude = pow(10, exponent).toDouble();
    double residual = roughInterval / magnitude; // Value between 1 and 10 (exclusive)

    // Snap to a "nice" value (1, 2, 5, or 10) * magnitude
    if (residual > 5) {
      return 10 * magnitude; // e.g., range 60 -> rough 12 -> 10 * 10 = 100 (adjusts up) -> maybe refine logic? -> range 60 / 5 = 12 -> magnitude 10, residual 1.2 -> returns 2 * 10 = 20. Seems ok.
    } else if (residual > 2) {
      return 5 * magnitude;  // e.g., range 30 -> rough 6 -> returns 5 * 1 = 5.
    } else if (residual > 1) {
      return 2 * magnitude;  // e.g., range 15 -> rough 3 -> returns 2 * 1 = 2.
    } else {
      return 1 * magnitude;  // e.g., range 8 -> rough 1.6 -> returns 1 * 1 = 1.
    }
  }
}