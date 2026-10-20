import 'package:flutter/material.dart';

enum AppDestination {
  dashboard(
    label: 'Dashboard',
    shortLabel: 'Home',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
  ),
  newBill(
    label: 'New Bill',
    shortLabel: 'New Bill',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
  ),
  products(
    label: 'Products',
    shortLabel: 'Products',
    icon: Icons.local_florist_outlined,
    selectedIcon: Icons.local_florist,
  ),
  billHistory(
    label: 'Bill History',
    shortLabel: 'History',
    icon: Icons.history,
    selectedIcon: Icons.history,
  ),
  invoiceCustomization(
    label: 'Invoice Customization',
    shortLabel: 'Invoice',
    icon: Icons.brush_outlined,
    selectedIcon: Icons.brush,
  ),
  settings(
    label: 'Settings',
    shortLabel: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  );

  const AppDestination({
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String shortLabel;
  final IconData icon;
  final IconData selectedIcon;

  /// Sidebar and rail entries. Invoice customization opens from Settings.
  static List<AppDestination> get menu =>
      values.where((item) => item != invoiceCustomization).toList();
}
