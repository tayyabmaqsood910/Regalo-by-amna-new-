import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regalo_by_amna/navigation/app_destination.dart';
import 'package:regalo_by_amna/screens/bill_history/bill_history_screen.dart';
import 'package:regalo_by_amna/screens/dashboard/dashboard_screen.dart';
import 'package:regalo_by_amna/screens/invoice_customization/invoice_customization_screen.dart';
import 'package:regalo_by_amna/screens/pos/new_bill_screen.dart';
import 'package:regalo_by_amna/screens/products/products_screen.dart';
import 'package:regalo_by_amna/screens/settings/settings_screen.dart';
import 'package:regalo_by_amna/theme/app_breakpoints.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';
import 'package:regalo_by_amna/widgets/app_sidebar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppDestination _destination = AppDestination.dashboard;

  void _select(AppDestination destination) {
    setState(() => _destination = destination);
    _scaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final page = _pageFor(_destination);

        if (AppBreakpoints.isDesktop(width)) {
          return Scaffold(
            body: Row(
              children: [
                AppSidebar(selected: _destination, onSelected: _select),
                Expanded(child: page),
              ],
            ),
          );
        }

        if (AppBreakpoints.isTablet(width)) {
          return Scaffold(
            body: Row(
              children: [
                _rail(),
                const VerticalDivider(width: 1, color: AppColors.line),
                Expanded(child: page),
              ],
            ),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text('Regalo'),
            leading: IconButton(
              tooltip: 'Open menu',
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu),
            ),
          ),
          drawer: Drawer(
            backgroundColor: AppColors.card,
            child: AppSidebar(
              selected: _destination,
              onSelected: _select,
              inDrawer: true,
            ),
          ),
          body: page,
        );
      },
    );
  }

  Widget _pageFor(AppDestination destination) {
    return switch (destination) {
      AppDestination.dashboard => DashboardScreen(onNavigate: _select),
      AppDestination.newBill => const NewBillScreen(),
      AppDestination.products => const ProductsScreen(),
      AppDestination.billHistory => const BillHistoryScreen(),
      AppDestination.invoiceCustomization => InvoiceCustomizationScreen(
        onBack: () => _select(AppDestination.settings),
      ),
      AppDestination.settings => SettingsScreen(
        onCustomize: () => _select(AppDestination.invoiceCustomization),
      ),
    };
  }

  Widget _rail() {
    final menu = AppDestination.menu;
    final current = _destination == AppDestination.invoiceCustomization
        ? AppDestination.settings
        : _destination;
    return NavigationRail(
      backgroundColor: AppColors.card,
      selectedIndex: menu.indexOf(current),
      onDestinationSelected: (index) => _select(menu[index]),
      labelType: NavigationRailLabelType.all,
      indicatorColor: AppColors.sageLight,
      selectedIconTheme: const IconThemeData(color: AppColors.forest),
      unselectedIconTheme: const IconThemeData(color: AppColors.muted),
      selectedLabelTextStyle: GoogleFonts.outfit(
        color: AppColors.forest,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: GoogleFonts.outfit(
        color: AppColors.muted,
        fontSize: 12,
      ),
      destinations: [
        for (final destination in menu)
          NavigationRailDestination(
            icon: Icon(destination.icon, key: Key('nav-${destination.name}')),
            selectedIcon: Icon(destination.selectedIcon),
            label: Text(destination.shortLabel),
          ),
      ],
    );
  }
}
