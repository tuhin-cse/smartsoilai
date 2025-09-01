import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smartsoilai/constants/app_colors.dart';

class SettingsTileNew extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;
  final bool showDivider;

  const SettingsTileNew({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                  color: AppColors.primary500,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: titleColor ?? Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary500,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(color: Colors.grey[200], height: 1),
      ],
    );
  }
}
