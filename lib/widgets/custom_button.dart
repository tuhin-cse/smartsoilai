import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

enum ButtonVariant { primary, secondary, outline, ghost, social }

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool fullWidth;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final bool loading;

  const CustomButton({
    super.key,
    required this.title,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.fullWidth = false,
    this.leftIcon,
    this.rightIcon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || loading;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(isDisabled),
          foregroundColor: _getTextColor(isDisabled),
          elevation: variant == ButtonVariant.primary ? 2 : 0,
          shadowColor: variant == ButtonVariant.primary
              ? AppColors.primary500.withOpacity(0.3)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: _getBorderSide(isDisabled),
          ),
          padding: _getPadding(),
          minimumSize: Size(0, _getHeight()),
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getTextColor(isDisabled),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leftIcon != null) ...[
                    leftIcon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: _getFontSize(),
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(isDisabled),
                    ),
                  ),
                  if (rightIcon != null) ...[
                    const SizedBox(width: 8),
                    rightIcon!,
                  ],
                ],
              ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDisabled) {
    if (isDisabled) {
      return AppColors.buttonDisabled;
    }

    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary500;
      case ButtonVariant.secondary:
        return AppColors.buttonDisabled;
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.ghost:
        return Colors.transparent;
      case ButtonVariant.social:
        return const Color(0xFFF5F5F5);
    }
  }

  Color _getTextColor(bool isDisabled) {
    if (isDisabled) {
      return Colors.white.withOpacity(0.6);
    }

    switch (variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
        return AppColors.textPrimary;
      case ButtonVariant.outline:
        return AppColors.primary500;
      case ButtonVariant.ghost:
        return AppColors.primary500;
      case ButtonVariant.social:
        return AppColors.textPrimary;
    }
  }

  BorderSide _getBorderSide(bool isDisabled) {
    switch (variant) {
      case ButtonVariant.outline:
        return BorderSide(
          color: isDisabled ? AppColors.buttonDisabled : AppColors.primary500,
          width: 1,
        );
      case ButtonVariant.social:
        return const BorderSide(color: Color(0xFFE8EBF0), width: 1);
      default:
        return BorderSide.none;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 16;
    }
  }
}
