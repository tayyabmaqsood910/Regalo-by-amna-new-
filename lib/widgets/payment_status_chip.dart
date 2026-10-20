import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regalo_by_amna/models/payment_status.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';

class PaymentStatusChip extends StatelessWidget {
  const PaymentStatusChip({super.key, required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      PaymentStatus.paid => (AppColors.sageLight, AppColors.sageDeep),
      PaymentStatus.partial => (AppColors.blush, AppColors.blushDeep),
      PaymentStatus.unpaid => (const Color(0xFFF0E6DC), AppColors.forest),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          status.label,
          style: GoogleFonts.outfit(
            color: foreground,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
