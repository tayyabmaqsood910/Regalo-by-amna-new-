import 'package:regalo_by_amna/models/payment_status.dart';

/// Totals for a flower-shop bill.
///
/// Subtotal is the sum of line totals. A line total is quantity × unit price,
/// minus that line's discount. Grand total is subtotal − bill discount + tax
/// + delivery charges.
abstract final class BillingService {
  static double lineTotal({
    required int quantity,
    required double unitPrice,
    required double discount,
  }) {
    final raw = (quantity * unitPrice) - discount;
    if (raw < 0) {
      return 0;
    }
    return raw;
  }

  static double grandTotal({
    required double subtotal,
    required double billDiscount,
    required double tax,
    required double deliveryCharges,
  }) {
    final raw = subtotal - billDiscount + tax + deliveryCharges;
    if (raw < 0) {
      return 0;
    }
    return raw;
  }

  static PaymentStatus paymentStatus({
    required double grandTotal,
    required double amountPaid,
  }) {
    if (amountPaid <= 0.009) {
      return PaymentStatus.unpaid;
    }
    if (amountPaid + 0.009 < grandTotal) {
      return PaymentStatus.partial;
    }
    return PaymentStatus.paid;
  }

  static double balance({
    required double grandTotal,
    required double amountPaid,
  }) {
    final remaining = grandTotal - amountPaid;
    if (remaining < 0) {
      return 0;
    }
    return remaining;
  }
}
