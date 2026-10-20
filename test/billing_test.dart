import 'package:flutter_test/flutter_test.dart';
import 'package:regalo_by_amna/services/shop_backup.dart';
import 'package:regalo_by_amna/services/billing_service.dart';
import 'package:regalo_by_amna/services/thermal_receipt.dart';
import 'package:regalo_by_amna/data/demo_data.dart';
import 'package:regalo_by_amna/models/payment_status.dart';
import 'package:regalo_by_amna/models/product.dart';
import 'package:regalo_by_amna/services/demo_store.dart';

void main() {
  test('line and grand totals follow the billing formula', () {
    expect(
      BillingService.lineTotal(quantity: 6, unitPrice: 400, discount: 0),
      2400,
    );
    expect(
      BillingService.lineTotal(quantity: 1, unitPrice: 1000, discount: 200),
      800,
    );
    expect(
      BillingService.lineTotal(quantity: 1, unitPrice: 100, discount: 250),
      0,
    );
    expect(
      BillingService.grandTotal(
        subtotal: 3450,
        billDiscount: 150,
        tax: 0,
        deliveryCharges: 200,
      ),
      3500,
    );
  });

  test('sample bills keep item prices, discounts, and payment status', () {
    final bills = DemoData.sessionBills(now: DateTime(2026, 10, 20, 15));

    final walkIn = bills.singleWhere((bill) => bill.number == 'INV-1002');
    expect(walkIn.customerLabel, 'Walk-in');
    expect(walkIn.subtotal, 3450);
    expect(walkIn.itemDiscounts, 0);
    expect(walkIn.grandTotal, 3500);
    expect(walkIn.balance, 2000);
    expect(walkIn.paymentStatus, PaymentStatus.partial);

    final birthday = bills.singleWhere((bill) => bill.number == 'INV-1004');
    expect(birthday.itemDiscounts, 200);
    expect(birthday.subtotal, 6000);
    expect(birthday.grandTotal, 6000);
    expect(birthday.paymentStatus, PaymentStatus.paid);

    final wedding = bills.singleWhere((bill) => bill.number == 'INV-1003');
    expect(wedding.grandTotal, 19400);
    expect(wedding.paymentStatus, PaymentStatus.unpaid);
    expect(wedding.notes, 'Deliver to the hall before 4 PM.');
  });

  test('clearing the session resets sales until sample bills are restored', () {
    final store = DemoStore();
    expect(store.billCount, 4);
    expect(store.totalSales, 33400);
    expect(store.products, hasLength(14));

    store.clearSessionBills();
    expect(store.billCount, 0);
    expect(store.totalSales, 0);
    expect(store.recentBills, isEmpty);

    store.restoreSampleBills();
    expect(store.billCount, 4);
    expect(store.totalSales, 33400);
    expect(store.recentBills.first.number, 'INV-1004');
  });

  test('adding a flower keeps the price list and saves a new invoice', () {
    final store = DemoStore();
    final rose = store.products.firstWhere(
      (product) => product.id == 'red-rose',
    );

    store.addProduct(rose);
    store.addProduct(rose);
    expect(store.draft.items, hasLength(1));
    expect(store.draft.items.single.quantity, 2);
    expect(store.draft.items.single.unitPrice, 150);

    store.updateLine(store.draft.items.single.id, unitPrice: 180, discount: 20);
    expect(
      store.products.firstWhere((product) => product.id == 'red-rose').price,
      150,
    );
    expect(store.draft.subtotal, 340);

    store.addCustomItem(name: 'Loose petals', unitPrice: 80);
    store.updateDraft(
      billDiscount: 10,
      tax: 5,
      deliveryCharges: 20,
      amountPaid: 50,
    );
    expect(store.draft.grandTotal, 435);
    expect(store.draft.balance, 385);
    expect(store.draft.paymentStatus, PaymentStatus.partial);

    final invoice = store.generateCurrentBill();
    expect(invoice, isNotNull);
    expect(invoice!.number, 'INV-1005');
    expect(invoice.grandTotal, 435);
    expect(invoice.items.first.unitPrice, 180);
    expect(
      store.products.firstWhere((product) => product.id == 'red-rose').price,
      150,
    );
    expect(store.draft.items, isEmpty);
    expect(store.billCount, 5);
    expect(store.settings.nextInvoiceNumber, 'INV-1006');
    expect(store.totalSales, 33400 + 435);
    expect(DemoStore().generateCurrentBill(), isNull);
  });

  test('catalog edits do not change a bill that was already saved', () {
    final store = DemoStore();
    final rose = store.products.firstWhere(
      (product) => product.id == 'red-rose',
    );
    store.addProduct(rose, unitPrice: 175);
    final invoice = store.generateCurrentBill();

    store.updateCatalogProduct(rose.copyWith(name: 'Changed rose', price: 999));
    store.addCatalogProduct(
      const Product(id: 'orchid', name: 'Orchid', price: 350),
    );
    expect(store.products, hasLength(15));
    store.updateSettings(store.settings.copyWith(shopName: 'Later name'));
    expect(invoice!.settings.shopName, 'Regalo by Amna');
    expect(store.settings.shopName, 'Later name');
    expect(invoice.items.first.name, 'Red Rose');
    expect(invoice.items.first.unitPrice, 175);

    store.deleteCatalogProduct('red-rose');
    expect(store.products.any((product) => product.id == 'red-rose'), isFalse);
    expect(
      store.invoices
          .firstWhere((bill) => bill.id == invoice.id)
          .items
          .first
          .name,
      'Red Rose',
    );
  });

  test('a saved bill can be turned into a thermal receipt', () async {
    final invoice = DemoStore().billsNewestFirst.first;
    final bytes = await buildThermalReceipt(invoice, widthMm: 80);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(400));
  });

  test('a backup restores the shop and a factory reset returns the sample', () {
    final store = DemoStore();
    store.addCatalogProduct(
      const Product(id: 'orchid', name: 'Orchid', price: 350),
    );
    store.updateSettings(store.settings.copyWith(shopName: 'Bloom Room'));
    store.clearSessionBills();
    final copy = ShopBackup.decode(store.exportBackup());

    final fresh = DemoStore();
    fresh.applySnapshot(copy);
    expect(fresh.settings.shopName, 'Bloom Room');
    expect(fresh.products.any((product) => product.id == 'orchid'), isTrue);
    expect(fresh.billCount, 0);

    fresh.factoryReset();
    expect(fresh.settings.shopName, 'Regalo by Amna');
    expect(fresh.products.any((product) => product.id == 'orchid'), isFalse);
    expect(fresh.products, hasLength(14));
    expect(fresh.billCount, 0);
    expect(fresh.totalSales, 0);
    expect(fresh.draft.items, isEmpty);
  });
}
