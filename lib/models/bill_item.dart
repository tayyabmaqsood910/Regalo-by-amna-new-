import 'package:regalo_by_amna/services/billing_service.dart';

class BillItem {
  const BillItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.productId,
    this.discount = 0,
  });

  final String id;
  final String? productId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double discount;

  double get lineTotal => BillingService.lineTotal(
    quantity: quantity,
    unitPrice: unitPrice,
    discount: discount,
  );

  BillItem copyWith({
    String? id,
    String? productId,
    String? name,
    int? quantity,
    double? unitPrice,
    double? discount,
    bool clearProductId = false,
  }) {
    return BillItem(
      id: id ?? this.id,
      productId: clearProductId ? null : (productId ?? this.productId),
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
    );
  }
}
