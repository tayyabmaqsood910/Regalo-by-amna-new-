import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regalo_by_amna/app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpDesk(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const RegaloApp());
    await tester.pump();
  }

  testWidgets('dashboard shows session bills and sales', (tester) async {
    await pumpDesk(tester);

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Rs. 33,400.00'), findsOneWidget);
    expect(find.byKey(const Key('dashboard-sales-chart')), findsOneWidget);
    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('Sara Malik'), findsOneWidget);
    expect(find.text('Ayesha Khan'), findsOneWidget);
    expect(find.text('Walk-in'), findsOneWidget);
    expect(find.text('Hassan Ali'), findsOneWidget);
  });

  testWidgets('a recent bill opens its saved summary', (tester) async {
    await pumpDesk(tester);

    await tester.ensureVisible(find.text('INV-1001'));
    await tester.tap(find.text('INV-1001'));
    await tester.pumpAndSettle();

    expect(find.text('Rose Bouquet'), findsOneWidget);
    expect(find.text('Grand total'), findsOneWidget);
    expect(find.text('12 Garden Lane, Gulberg, Lahore'), findsOneWidget);
    expect(find.byKey(const Key('print-80')), findsOneWidget);
    expect(find.text('Rs. 4,500.00'), findsWidgets);
  });

  testWidgets('clearing the session updates the dashboard', (tester) async {
    await pumpDesk(tester);

    await tester.tap(find.byKey(const Key('nav-settings')));
    await tester.pumpAndSettle();
    expect(find.text('4 bills'), findsOneWidget);

    await tester.tap(find.byKey(const Key('clear-session')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear bills'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('0 bills'), findsOneWidget);
    expect(find.text('Rs. 0.00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-dashboard')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('empty-bills')), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('quick links open products and a new bill', (tester) async {
    await pumpDesk(tester);

    await tester.tap(find.byKey(const Key('quick-products')));
    await tester.pumpAndSettle();
    expect(
      find.text('14 items in the price list. Stock is not tracked.'),
      findsOneWidget,
    );
    expect(find.text('Red Rose'), findsOneWidget);
    expect(find.text('Gift Card'), findsOneWidget);
    expect(find.text('Roses'), findsWidgets);
    expect(find.text('Bouquets'), findsWidgets);

    await tester.tap(find.byKey(const Key('nav-newBill')));
    await tester.pumpAndSettle();
    expect(find.text('Current bill'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-invoice-customization')));
    await tester.pumpAndSettle();
    expect(find.text('Regalo by Amna'), findsWidgets);
    expect(find.text('INV-1005'), findsOneWidget);
  });

  testWidgets('a product can be added, edited, and deleted', (tester) async {
    await pumpDesk(tester);
    await tester.tap(find.byKey(const Key('nav-products')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-product')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('product-name')), 'Orchid');
    await tester.enterText(find.byKey(const Key('product-price')), '350');
    await tester.enterText(find.byKey(const Key('product-category')), 'Stems');
    await tester.tap(find.byKey(const Key('save-product')));
    await tester.pumpAndSettle();

    expect(find.text('Orchid'), findsOneWidget);
    expect(find.text('Rs. 350.00'), findsOneWidget);

    await tester.ensureVisible(find.text('Orchid'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Orchid'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('product-price')), '400');
    await tester.tap(find.byKey(const Key('save-product')));
    await tester.pumpAndSettle();
    expect(find.text('Rs. 400.00'), findsWidgets);
    expect(find.text('Rs. 350.00'), findsNothing);

    await tester.ensureVisible(find.byTooltip('Delete Orchid'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete Orchid'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete product'));
    await tester.pumpAndSettle();
    expect(find.text('Orchid'), findsNothing);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('a catalog flower can be added and repriced on the bill', (
    tester,
  ) async {
    await pumpDesk(tester);
    await tester.tap(find.byKey(const Key('nav-newBill')));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'Stems'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product-sunflower')), findsOneWidget);
    expect(find.byKey(const Key('product-red-rose')), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, 'All'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('product-search')), 'Red Rose');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product-red-rose')), findsOneWidget);
    expect(find.byKey(const Key('product-lily')), findsNothing);

    expect(find.text('Rs. 150.00'), findsNothing);

    await tester.tap(find.byKey(const Key('product-red-rose')));
    await tester.pumpAndSettle();
    expect(find.text('Price for this bill (Rs.)'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(EditableText),
      ),
      '180',
    );
    await tester.tap(find.text('Add to bill'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('line-total-line-1')), findsOneWidget);
    expect(find.text('Rs. 180.00'), findsWidgets);
    expect(find.text('Rs. 150.00'), findsNothing);
  });

  testWidgets('invoice settings update the live preview', (tester) async {
    await pumpDesk(tester);
    await tester.tap(find.byKey(const Key('nav-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-invoice-customization')));
    await tester.pumpAndSettle();

    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Ayesha Khan'), findsOneWidget);
    expect(find.text('INV-1005'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('invoice-shop-name')),
      'Bloom Room',
    );
    await tester.pump();
    expect(find.text('Bloom Room'), findsWidgets);

    await tester.tap(find.byKey(const Key('invoice-more')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('toggle-customer-information')));
    await tester.tap(find.byKey(const Key('toggle-customer-information')));
    await tester.pump();
    expect(find.text('Ayesha Khan'), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('layout-58')));
    await tester.tap(find.byKey(const Key('layout-58')));
    await tester.pump();
    expect(find.text('58 mm'), findsOneWidget);
    expect(find.text('Bloom Room'), findsWidgets);
  });

  testWidgets('factory reset clears the session bills', (tester) async {
    await pumpDesk(tester);
    await tester.tap(find.byKey(const Key('nav-settings')));
    await tester.pumpAndSettle();
    expect(find.text('4 bills'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('factory-reset')));
    await tester.tap(find.byKey(const Key('factory-reset')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Factory reset'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('0 bills'), findsOneWidget);
    expect(find.text('Rs. 0.00'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('bill history search filters by customer', (tester) async {
    await pumpDesk(tester);
    await tester.tap(find.byKey(const Key('nav-billHistory')));
    await tester.pumpAndSettle();

    expect(find.text('Sara Malik'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('bill-search')), 'Hassan');
    await tester.pump();
    expect(find.text('Sara Malik'), findsNothing);
    expect(find.text('Hassan Ali'), findsOneWidget);
  });
}
