import 'package:regalo_by_amna/models/bill_item.dart';
import 'package:regalo_by_amna/models/payment_status.dart';
import 'package:regalo_by_amna/services/billing_service.dart';

/// The bill open on the counter. It is not saved until it is generated.
class BillDraft {
  const BillDraft({
    this.items = const [],
    this.customerName = '',
    this.customerPhone = '',
    this.billDiscount = 0,
    this.tax = 0,
    this.deliveryCharges = 0,
    this.amountPaid = 0,
    this.notes = '',
  });

  final List<BillItem> items;
  final String customerName;
  final String customerPhone;
  final double billDiscount;
  final double tax;
  final double deliveryCharges;
  final double amountPaid;
  final String notes;

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

  bool get hasContent =>
      items.isNotEmpty ||
      customerName.trim().isNotEmpty ||
      customerPhone.trim().isNotEmpty ||
      notes.trim().isNotEmpty ||
      billDiscount != 0 ||
      tax != 0 ||
      deliveryCharges != 0 ||
      amountPaid != 0;

  BillDraft copyWith({
    List<BillItem>? items,
    String? customerName,
    String? customerPhone,
    double? billDiscount,
    double? tax,
    double? deliveryCharges,
    double? amountPaid,
    String? notes,
  }) {
    return BillDraft(
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      billDiscount: billDiscount ?? this.billDiscount,
      tax: tax ?? this.tax,
      deliveryCharges: deliveryCharges ?? this.deliveryCharges,
      amountPaid: amountPaid ?? this.amountPaid,
      notes: notes ?? this.notes,
    );
  }
}
