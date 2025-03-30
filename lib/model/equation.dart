import 'dart:math'; // For sqrt

class Equation {
  // --- Class Member Variables ---
  // Made these fields public but only populated by the internal _calculateSolutions
  double? root1;
  double? root2;
  double? root; // Used for single real root (discriminant == 0) or linear root (a == 0)
  late List<(double, double)> dataPoints = [];

  // Use 'late final' for solutions as it's initialized exactly once in the constructor
  // and won't change afterwards.
  late final Map<String, dynamic> solutions;

  // Input parameters remain final
  final double a;
  final double b;
  final double c;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  Equation({
    required this.a,
    required this.b,
    required this.c,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  }) {
    // Calculate solutions upon object creation
    solutions = _calculateSolutions();
    dataPoints = _generateDataPoints();
  }

  List<(double, double)> _generateDataPoints() {
    // Ensure bounds are valid before generating
    // if (!_validateBounds()) {
    //   dataPoints = []; // Clear points if bounds invalid
    //   return;
    // }

    List<(double, double)> points = [];
    const int numPoints = 200; // Use a fixed number of points for consistent detail
    final double step = (maxX - minX) / numPoints;

    if (step <= 0) { // Avoid infinite loop or errors if minX >= maxX
      return [];
    }

    for (int i = 0; i <= numPoints; i++) {
      double x = minX + i * step;
      // Check for potential overflow or invalid results with extreme coefficients
      try {
        double y = a * x * x + b * x + c;
        // Add checks for NaN or Infinity if necessary, depending on expected inputs
        if (y.isFinite) {
          points.add((x, y));
        }
      } catch (e) {
        // Handle potential math errors with extreme values if needed
        // print("Error calculating point at x=$x: $e");
      }
    }
    return points;
  }

  Map<String, dynamic> _calculateSolutions() {
    // --- Case 1: Linear Equation (a == 0) ---
    if (a == 0) {
      if (b != 0) {
        // Solve bx + c = 0  => x = -c / b
        root = -c / b;
        return {
          'description': 'Linear Equation (a=0)',
          'root_type': 'Single real root',
          'roots': root?.toStringAsFixed(3), // Display the calculated root
        };
      } else {
        // Case a=0 and b=0: Equation becomes 0x^2 + 0x + c = 0 => c = 0
        if (c == 0) {
          // 0 = 0, infinite solutions
          return {
            'description': 'Linear Equation (a=0, b=0, c=0)',
            'root_type': 'Infinite solutions (identity 0=0)',
          };
        } else {
          // c = 0 where c != 0, no solution
          return {
            'description': 'Linear Equation (a=0, b=0, c!=0)',
            'root_type': 'No solution (contradiction c=0)',
          };
        }
      }
    }

    // --- Case 2: Quadratic Equation (a != 0) ---
    final double discriminant = b * b - 4 * a * c;
    final double vertexX = -b / (2 * a);
    final double vertexY = a * vertexX * vertexX + b * vertexX + c;
    // Use num.isFinite to avoid issues with potential NaN/Infinity if a=0 slipped through
    // although the previous check should prevent it. Good practice anyway.
    String vertexString = (vertexX.isFinite && vertexY.isFinite)
        ? '(${vertexX.toStringAsFixed(3)}, ${vertexY.toStringAsFixed(3)})'
        : 'Invalid Vertex';


    if (discriminant > 0) {
      // Two distinct real roots
      // CORRECTION: Assign results to class members using 'this.'
      this.root1 = (-b + sqrt(discriminant)) / (2 * a);
      this.root2 = (-b - sqrt(discriminant)) / (2 * a);
      return {
        'description': 'Quadratic: Two distinct real roots.',
        'root_type': 'Real, distinct',
        'roots': '${this.root1?.toStringAsFixed(3)}, ${this.root2?.toStringAsFixed(3)}',
        'vertex': vertexString,
        'discriminant': discriminant,
      };
    } else if (discriminant == 0) {
      // One real root (repeated)
      // CORRECTION: Assign result to class member 'root' using 'this.'
      this.root = -b / (2 * a); // This is also the vertex x-coordinate
      return {
        'description': 'Quadratic: One real root (repeated).',
        'root_type': 'Real, repeated',
        'roots': this.root?.toStringAsFixed(3),
        'vertex': vertexString, // Vertex lies on the x-axis
        'discriminant': discriminant,
      };
    } else {
      // Two complex roots (no real roots)
      // Class members root, root1, root2 remain null (as they store real roots)
      final double realPart = -b / (2 * a);
      // Use abs(discriminant) or -discriminant inside sqrt for complex part
      final double imagPart = sqrt(-discriminant) / (2 * a);
      return {
        'description': 'Quadratic: Two complex roots (no real roots).',
        'root_type': 'Complex conjugate',
        'roots': '${realPart.toStringAsFixed(3)} ± ${imagPart.abs().toStringAsFixed(3)}i', // Use abs for imagPart display
        'vertex': vertexString,
        'discriminant': discriminant,
      };
    }
  }
}