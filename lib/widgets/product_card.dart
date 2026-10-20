import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regalo_by_amna/models/product.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';
import 'package:regalo_by_amna/widgets/app_card.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            fontSize: 15,
            height: 1.25,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
