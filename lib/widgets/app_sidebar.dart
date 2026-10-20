import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regalo_by_amna/navigation/app_destination.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.selected,
    required this.onSelected,
    this.inDrawer = false,
  });

  final AppDestination selected;
  final ValueChanged<AppDestination> onSelected;
  final bool inDrawer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: inDrawer ? 280 : 240,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(right: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _BrandBlock(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  children: [
                    for (final destination in AppDestination.menu)
                      _NavTile(
                        destination: destination,
                        selected: destination == selected ||
                            (destination == AppDestination.settings &&
                                selected ==
                                    AppDestination.invoiceCustomization),
                        onSelected: onSelected,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Regalo',
            style: GoogleFonts.cormorantGaramond(
              color: AppColors.forest,
              fontSize: 32,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'by Amna',
            style: GoogleFonts.outfit(
              color: AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.destination,
    required this.selected,
    required this.onSelected,
  });

  final AppDestination destination;
  final bool selected;
  final ValueChanged<AppDestination> onSelected;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.forest : AppColors.ink;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? AppColors.sageLight : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          key: Key('nav-${destination.name}'),
          borderRadius: BorderRadius.circular(8),
          onTap: () => onSelected(destination),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  color: foreground,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    destination.label,
                    style: GoogleFonts.outfit(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
