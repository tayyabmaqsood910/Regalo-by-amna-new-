import 'package:flutter/foundation.dart';
import 'package:regalo_by_amna/data/demo_data.dart';
import 'package:regalo_by_amna/models/bill_draft.dart';
import 'package:regalo_by_amna/models/bill_item.dart';
import 'package:regalo_by_amna/models/invoice.dart';
import 'package:regalo_by_amna/models/invoice_settings.dart';
import 'package:regalo_by_amna/models/product.dart';
import 'package:regalo_by_amna/services/shop_backup.dart';

/// In-memory session for the billing desk. Nothing is written to disk.
class DemoStore extends ChangeNotifier {
  DemoStore({
    List<Product>? products,
    List<Invoice>? invoices,
    InvoiceSettings? settings,
  }) : _products = List<Product>.of(products ?? DemoData.products()),
       _invoices = List<Invoice>.of(invoices ?? DemoData.sessionBills()),
       _settings = settings ?? const InvoiceSettings.regalo();

  final List<Product> _products;
  List<Invoice> _invoices;
  InvoiceSettings _settings;
  BillDraft _draft = const BillDraft();
  int _lineSequence = 0;

  List<Product> get products => List.unmodifiable(_products);

  List<Invoice> get invoices => List.unmodifiable(_invoices);

  InvoiceSettings get settings => _settings;

  void updateSettings(InvoiceSettings settings) {
    _settings = settings;
    notifyListeners();
  }

  BillDraft get draft => _draft;

  int get billCount => _invoices.length;

  double get totalSales =>
      _invoices.fold(0, (sum, bill) => sum + bill.grandTotal);

  List<Invoice> get billsNewestFirst {
    final sorted = List<Invoice>.of(_invoices)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  List<Invoice> get recentBills => List.unmodifiable(billsNewestFirst.take(5));

  void addCatalogProduct(Product product) {
    _products.insert(0, product);
    notifyListeners();
  }

  void updateCatalogProduct(Product product) {
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index < 0) {
      return;
    }
    _products[index] = product;
    notifyListeners();
  }

  void deleteCatalogProduct(String id) {
    _products.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void addProduct(Product product, {double? unitPrice}) {
    final price = unitPrice ?? product.price;
    final items = List<BillItem>.of(_draft.items);
    final index = items.indexWhere(
      (item) => item.productId == product.id && item.unitPrice == price,
    );
    if (index >= 0) {
      final current = items[index];
      items[index] = current.copyWith(quantity: current.quantity + 1);
    } else {
      items.add(
        BillItem(
          id: _nextLineId(),
          productId: product.id,
          name: product.name,
          quantity: 1,
          unitPrice: price,
        ),
      );
    }
    _draft = _draft.copyWith(items: items);
    notifyListeners();
  }

  void addCustomItem({
    required String name,
    required double unitPrice,
    int quantity = 1,
    double discount = 0,
  }) {
    final items = List<BillItem>.of(_draft.items)
      ..add(
        BillItem(
          id: _nextLineId(),
          name: name.trim(),
          quantity: quantity,
          unitPrice: unitPrice,
          discount: discount,
        ),
      );
    _draft = _draft.copyWith(items: items);
    notifyListeners();
  }

  void updateLine(
    String id, {
    int? quantity,
    double? unitPrice,
    double? discount,
  }) {
    final items = [
      for (final item in _draft.items)
        if (item.id == id)
          item.copyWith(
            quantity: quantity,
            unitPrice: unitPrice,
            discount: discount,
          )
        else
          item,
    ];
    _draft = _draft.copyWith(items: items);
    notifyListeners();
  }

  void removeLine(String id) {
    _draft = _draft.copyWith(
      items: _draft.items.where((item) => item.id != id).toList(),
    );
    notifyListeners();
  }

  void updateDraft({
    String? customerName,
    String? customerPhone,
    double? billDiscount,
    double? tax,
    double? deliveryCharges,
    double? amountPaid,
    String? notes,
  }) {
    final next = _draft.copyWith(
      customerName: customerName,
      customerPhone: customerPhone,
      billDiscount: billDiscount,
      tax: tax,
      deliveryCharges: deliveryCharges,
      amountPaid: amountPaid,
      notes: notes,
    );
    if (_sameCharges(next)) {
      return;
    }
    _draft = next;
    notifyListeners();
  }

  void clearDraft() {
    if (!_draft.hasContent) {
      return;
    }
    _draft = const BillDraft();
    notifyListeners();
  }

  /// Saves a snapshot of the open bill. Returns null when the bill has no items.
  Invoice? generateCurrentBill() {
    if (_draft.items.isEmpty) {
      return null;
    }
    final savedSettings = _settings;
    final invoice = Invoice(
      id: 'inv-${savedSettings.nextNumber}',
      number: savedSettings.nextInvoiceNumber,
      createdAt: DateTime.now(),
      customerName: _blankToNull(_draft.customerName),
      customerPhone: _blankToNull(_draft.customerPhone),
      items: _draft.items,
      billDiscount: _draft.billDiscount,
      tax: _draft.tax,
      deliveryCharges: _draft.deliveryCharges,
      amountPaid: _draft.amountPaid,
      notes: _blankToNull(_draft.notes),
      settings: savedSettings,
    );
    _invoices = [..._invoices, invoice];
    _settings = savedSettings.copyWith(
      nextNumber: savedSettings.nextNumber + 1,
    );
    _draft = const BillDraft();
    notifyListeners();
    return invoice;
  }

  void clearSessionBills() {
    _invoices = [];
    notifyListeners();
  }

  void restoreSampleBills() {
    _invoices = DemoData.sessionBills();
    notifyListeners();
  }

  void applySnapshot(ShopSnapshot snapshot) {
    _products
      ..clear()
      ..addAll(snapshot.products);
    _invoices = List<Invoice>.of(snapshot.invoices);
    _settings = snapshot.settings;
    _draft = snapshot.draft;
    notifyListeners();
  }

  void factoryReset() {
    _products
      ..clear()
      ..addAll(DemoData.products());
    _invoices = [];
    _settings = const InvoiceSettings.regalo();
    _draft = const BillDraft();
    notifyListeners();
  }

  String exportBackup() {
    return ShopBackup.encode(
      products: _products,
      invoices: _invoices,
      settings: _settings,
      draft: _draft,
    );
  }

  String _nextLineId() {
    _lineSequence += 1;
    return 'line-$_lineSequence';
  }

  bool _sameCharges(BillDraft next) {
    return next.customerName == _draft.customerName &&
        next.customerPhone == _draft.customerPhone &&
        next.billDiscount == _draft.billDiscount &&
        next.tax == _draft.tax &&
        next.deliveryCharges == _draft.deliveryCharges &&
        next.amountPaid == _draft.amountPaid &&
        next.notes == _draft.notes &&
        identical(next.items, _draft.items);
  }

  String? _blankToNull(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
