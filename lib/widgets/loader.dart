import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smartsoilai/constants/app_colors.dart';

class LoaderView extends StatelessWidget {
  final bool loading;
  final Widget child;

  const LoaderView({super.key, required this.loading, required this.child});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(backgroundColor: Colors.white, body: Loader());
    }
    return child;
  }
}

class LoaderStack extends StatelessWidget {
  final bool loading;
  final Widget child;
  final bool shouldUpdateChildWidget;

  const LoaderStack({
    super.key,
    required this.loading,
    required this.child,
    this.shouldUpdateChildWidget = false,
  });

  @override
  Widget build(BuildContext context) {
    if (shouldUpdateChildWidget) {
      if (loading) {
        return Stack(
          children: [
            child,
            Container(
              color: Colors.white.withOpacity(0.9),
              child: const Loader(),
            ),
          ],
        );
      }
      return child;
    }
    return Stack(
      children: [
        child,
        if (loading)
          Container(
            color: Colors.white.withOpacity(0.9),
            child: const Loader(),
          ),
      ],
    );
  }
}

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF8F1),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary500.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main loading animation
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Car icon with light green background
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF8F1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/images/logo.png",
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                  // Rotating circle animation
                  SpinKitRing(
                    color: AppColors.primary500,
                    size: 90.0,
                    lineWidth: 2.0,
                    duration: const Duration(milliseconds: 1500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
