import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.weatherBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Jessore Khulna',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Main temperature section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '27°C',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: AppColors.textPrimary,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'H: 23°',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'L: 14°',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Weather icon
                SizedBox(
                  width: 80,
                  height: 60,
                  child: Stack(
                    children: [
                      // Cloud icon
                      Positioned(
                        left: 10,
                        top: 15,
                        child: Container(
                          width: 50,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.weatherCloud,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      // Sun icon
                      Positioned(
                        right: 10,
                        top: 5,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: AppColors.weatherSun,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.wb_sunny,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Weather metrics grid
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(
              children: [
                Expanded(child: _buildMetric('Humidity', '40%')),
                Expanded(child: _buildMetric('Precipitation', '5.1 Ml')),
                Expanded(child: _buildMetric('Pressure', '450 hpa')),
                Expanded(child: _buildMetric('Wind', '23 m/s')),
              ],
            ),
          ),

          // Sunrise/Sunset section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
            child: Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '5:20 am',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sunrise',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: CustomPaint(
                      size: const Size(150, 70),
                      painter: SunTimelinePainter(),
                    ),
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '7:20 Pm',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sunset',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class SunTimelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dashedPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw dashed arc
    final path = Path();
    path.moveTo(15, size.height - 10);
    path.quadraticBezierTo(size.width / 2, 5, size.width - 15, size.height - 10);

    _drawDashedPath(canvas, path, dashedPaint, 6, 6);

    // Draw sun
    final sunPaint = Paint()
      ..color = AppColors.weatherSun
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.6, 20),
      8,
      sunPaint,
    );

    // Draw timeline dots
    final dotPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;

    final positions = [0.17, 0.27, 0.37, 0.47, 0.6, 0.73, 0.83, 0.9];
    for (int i = 0; i < positions.length; i++) {
      final x = size.width * positions[i];
      final y = _getYForX(x, size);
      canvas.drawCircle(
        Offset(x, y),
        i == 4 ? 2 : 1.5, // Larger dot for current position
        i == 4 ? sunPaint : dotPaint,
      );
    }
  }

  double _getYForX(double x, Size size) {
    final normalizedX = x / size.width;
    return size.height - 10 - (4 * (size.height - 20) * normalizedX * (1 - normalizedX));
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, double dashWidth, double dashSpace) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        final length = draw ? dashWidth : dashSpace;
        final nextDistance = distance + length;
        final extractPath = pathMetric.extractPath(distance, nextDistance);
        if (draw) {
          canvas.drawPath(extractPath, paint);
        }
        distance = nextDistance;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
