import 'package:regalo_by_amna/models/bill_item.dart';
import 'package:regalo_by_amna/models/invoice_settings.dart';
import 'package:regalo_by_amna/models/payment_status.dart';
import 'package:regalo_by_amna/services/billing_service.dart';

/// A saved bill. Item names, prices, and totals stay as they were at generation.
class Invoice {
  Invoice({
    required this.id,
    required this.number,
    required this.createdAt,
    required List<BillItem> items,
    required this.settings,
    this.customerName,
    this.customerPhone,
    this.billDiscount = 0,
    this.tax = 0,
    this.deliveryCharges = 0,
    this.amountPaid = 0,
    this.notes,
  }) : items = List.unmodifiable(items);

  final String id;
  final String number;
  final DateTime createdAt;
  final String? customerName;
  final String? customerPhone;
  final List<BillItem> items;
  final double billDiscount;
  final double tax;
  final double deliveryCharges;
  final double amountPaid;
  final String? notes;
  final InvoiceSettings settings;

  String get customerLabel {
    final name = customerName?.trim();
    if (name == null || name.isEmpty) {
      return 'Walk-in';
    }
    return name;
  }

  double get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  double get itemDiscounts => items.fold(0, (sum, item) => sum + item.discount);

  double get grandTotal => BillingService.grandTotal(
    subtotal: subtotal,
    billDiscount: billDiscount,
    tax: tax,
    deliveryCharges: deliveryCharges,
  );

  double get balance =>
      BillingService.balance(grandTotal: grandTotal, amountPaid: amountPaid);

  PaymentStatus get paymentStatus => BillingService.paymentStatus(
    grandTotal: grandTotal,
    amountPaid: amountPaid,
  );
}
