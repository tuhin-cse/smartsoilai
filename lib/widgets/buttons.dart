import 'package:flutter/material.dart';
import 'package:smartsoilai/constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool disabled;

  const PrimaryButton({
    super.key,
    required this.title,
    this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary500,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
