import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SatelliteCard extends StatelessWidget {
  const SatelliteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.weatherBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/field.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Dark overlay
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            // Satellite icon (top-left)
            const Positioned(
              top: 20,
              left: 20,
              child: Icon(
                Icons.satellite_alt,
                color: Colors.white,
                size: 40,
              ),
            ),

            // Live badge (top-right)
            Positioned(
              top: 16,
              right: 20,
              child: Container(
                height: 26,
                width: 66,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white, width: 0.5),
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Overlay chips
            Positioned(
              left: 120,
              top: 156,
              child: _buildOverlayChip('Real-time Fields'),
            ),
            Positioned(
              left: 38,
              top: 208,
              child: _buildOverlayChip('Hydro Health'),
            ),
            Positioned(
              left: 161,
              top: 217,
              child: _buildOverlayChip('SmartGrow'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayChip(String text) {
    return Container(
      height: 22,
      decoration: BoxDecoration(
        color: AppColors.primary600,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
