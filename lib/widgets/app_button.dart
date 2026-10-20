import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    final textStyle = GoogleFonts.outfit(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    const padding = EdgeInsets.symmetric(horizontal: 18, vertical: 14);

    return switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.cream,
          padding: padding,
          shape: shape,
          textStyle: textStyle,
        ),
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.forest,
          side: const BorderSide(color: AppColors.sage),
          padding: padding,
          shape: shape,
          textStyle: textStyle,
        ),
        child: child,
      ),
      AppButtonVariant.destructive => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: AppColors.cream,
          padding: padding,
          shape: shape,
          textStyle: textStyle,
        ),
        child: child,
      ),
    };
  }
}
