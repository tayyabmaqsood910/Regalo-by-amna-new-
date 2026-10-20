import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      child: Column(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.blush,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(icon, color: AppColors.forest),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: AppColors.muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}
