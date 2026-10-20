import 'dart:convert';
import 'dart:typed_data';

import 'package:regalo_by_amna/models/bill_draft.dart';
import 'package:regalo_by_amna/models/bill_item.dart';
import 'package:regalo_by_amna/models/invoice.dart';
import 'package:regalo_by_amna/models/invoice_settings.dart';
import 'package:regalo_by_amna/models/product.dart';

class ShopSnapshot {
  const ShopSnapshot({
    required this.products,
    required this.invoices,
    required this.settings,
    required this.draft,
  });

  final List<Product> products;
  final List<Invoice> invoices;
  final InvoiceSettings settings;
  final BillDraft draft;
}

/// JSON backup of the in-memory shop. Version 1.
abstract final class ShopBackup {
  static const version = 1;

  static String encode({
    required List<Product> products,
    required List<Invoice> invoices,
    required InvoiceSettings settings,
    required BillDraft draft,
  }) {
    final payload = <String, Object?>{
      'version': version,
      'products': products.map(_productToJson).toList(),
      'invoices': invoices.map(_invoiceToJson).toList(),
      'settings': _settingsToJson(settings),
      'draft': _draftToJson(draft),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  static ShopSnapshot decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('This file is not a Regalo backup.');
    }
    final version = decoded['version'];
    if (version != ShopBackup.version) {
      throw FormatException('Unsupported backup version: $version');
    }
    final products = decoded['products'];
    final invoices = decoded['invoices'];
    final settings = decoded['settings'];
    final draft = decoded['draft'];
    if (products is! List || invoices is! List || settings is! Map) {
      throw const FormatException('This backup is missing shop data.');
    }
    return ShopSnapshot(
      products: [
        for (final item in products)
          if (item is Map) _productFromJson(item) else _bad('product'),
      ],
      invoices: [
        for (final item in invoices)
          if (item is Map) _invoiceFromJson(item) else _bad('invoice'),
      ],
      settings: _settingsFromJson(settings),
      draft: draft is Map ? _draftFromJson(draft) : const BillDraft(),
    );
  }

  static Never _bad(String label) {
    throw FormatException('This backup has an invalid $label.');
  }
}

Map<String, Object?> _productToJson(Product product) {
  return {
    'id': product.id,
    'name': product.name,
    'price': product.price,
    'imagePath': product.imagePath,
    'imageBytes': _bytes(product.imageBytes),
    'category': product.category,
    'description': product.description,
  };
}

Product _productFromJson(Map<dynamic, dynamic> json) {
  return Product(
    id: _string(json['id'], 'product id'),
    name: _string(json['name'], 'product name'),
    price: _double(json['price']),
    imagePath: _optionalString(json['imagePath']),
    imageBytes: _optionalBytes(json['imageBytes']),
    category: _optionalString(json['category']),
    description: _optionalString(json['description']),
  );
}

Map<String, Object?> _invoiceToJson(Invoice invoice) {
  return {
    'id': invoice.id,
    'number': invoice.number,
    'createdAt': invoice.createdAt.toIso8601String(),
    'customerName': invoice.customerName,
    'customerPhone': invoice.customerPhone,
    'billDiscount': invoice.billDiscount,
    'tax': invoice.tax,
    'deliveryCharges': invoice.deliveryCharges,
    'amountPaid': invoice.amountPaid,
    'notes': invoice.notes,
    'items': invoice.items.map(_itemToJson).toList(),
    'settings': _settingsToJson(invoice.settings),
  };
}

Invoice _invoiceFromJson(Map<dynamic, dynamic> json) {
  final items = json['items'];
  if (items is! List) {
    throw const FormatException('A bill in this backup has no items.');
  }
  final settings = json['settings'];
  return Invoice(
    id: _string(json['id'], 'invoice id'),
    number: _string(json['number'], 'invoice number'),
    createdAt: DateTime.parse(_string(json['createdAt'], 'invoice date')),
    customerName: _optionalString(json['customerName']),
    customerPhone: _optionalString(json['customerPhone']),
    billDiscount: _double(json['billDiscount']),
    tax: _double(json['tax']),
    deliveryCharges: _double(json['deliveryCharges']),
    amountPaid: _double(json['amountPaid']),
    notes: _optionalString(json['notes']),
    items: [
      for (final item in items)
        if (item is Map) _itemFromJson(item) else ShopBackup._bad('line'),
    ],
    settings: settings is Map
        ? _settingsFromJson(settings)
        : const InvoiceSettings.regalo(),
  );
}

Map<String, Object?> _itemToJson(BillItem item) {
  return {
    'id': item.id,
    'productId': item.productId,
    'name': item.name,
    'quantity': item.quantity,
    'unitPrice': item.unitPrice,
    'discount': item.discount,
  };
}

BillItem _itemFromJson(Map<dynamic, dynamic> json) {
  return BillItem(
    id: _string(json['id'], 'line id'),
    productId: _optionalString(json['productId']),
    name: _string(json['name'], 'line name'),
    quantity: _int(json['quantity']),
    unitPrice: _double(json['unitPrice']),
    discount: _double(json['discount']),
  );
}

Map<String, Object?> _draftToJson(BillDraft draft) {
  return {
    'customerName': draft.customerName,
    'customerPhone': draft.customerPhone,
    'billDiscount': draft.billDiscount,
    'tax': draft.tax,
    'deliveryCharges': draft.deliveryCharges,
    'amountPaid': draft.amountPaid,
    'notes': draft.notes,
    'items': draft.items.map(_itemToJson).toList(),
  };
}

BillDraft _draftFromJson(Map<dynamic, dynamic> json) {
  final items = json['items'];
  return BillDraft(
    customerName: _optionalString(json['customerName']) ?? '',
    customerPhone: _optionalString(json['customerPhone']) ?? '',
    billDiscount: _double(json['billDiscount']),
    tax: _double(json['tax']),
    deliveryCharges: _double(json['deliveryCharges']),
    amountPaid: _double(json['amountPaid']),
    notes: _optionalString(json['notes']) ?? '',
    items: [
      if (items is List)
        for (final item in items)
          if (item is Map) _itemFromJson(item),
    ],
  );
}

Map<String, Object?> _settingsToJson(InvoiceSettings settings) {
  return {
    'shopName': settings.shopName,
    'logoPath': settings.logoPath,
    'logoBytes': _bytes(settings.logoBytes),
    'address': settings.address,
    'phone': settings.phone,
    'email': settings.email,
    'invoiceTitle': settings.invoiceTitle,
    'numberPrefix': settings.numberPrefix,
    'nextNumber': settings.nextNumber,
    'thankYouMessage': settings.thankYouMessage,
    'footerText': settings.footerText,
    'terms': settings.terms,
    'currencyCode': settings.currencyCode,
    'currencySymbol': settings.currencySymbol,
    'dateFormat': settings.dateFormat,
    'showCustomer': settings.showCustomer,
    'showItemDiscounts': settings.showItemDiscounts,
    'showTax': settings.showTax,
    'showDelivery': settings.showDelivery,
    'showPayment': settings.showPayment,
    'accentColorValue': settings.accentColorValue,
  };
}

InvoiceSettings _settingsFromJson(Map<dynamic, dynamic> json) {
  return InvoiceSettings(
    shopName: _optionalString(json['shopName']) ?? 'Regalo by Amna',
    logoPath: _optionalString(json['logoPath']),
    logoBytes: _optionalBytes(json['logoBytes']),
    address: _optionalString(json['address']) ?? '',
    phone: _optionalString(json['phone']) ?? '',
    email: _optionalString(json['email']) ?? '',
    invoiceTitle: _optionalString(json['invoiceTitle']) ?? 'Invoice',
    numberPrefix: _optionalString(json['numberPrefix']) ?? 'INV-',
    nextNumber: json['nextNumber'] == null ? 1005 : _int(json['nextNumber']),
    thankYouMessage: _optionalString(json['thankYouMessage']) ?? '',
    footerText: _optionalString(json['footerText']) ?? '',
    terms: _optionalString(json['terms']) ?? '',
    currencyCode: _optionalString(json['currencyCode']) ?? 'PKR',
    currencySymbol: _optionalString(json['currencySymbol']) ?? 'Rs.',
    dateFormat: _optionalString(json['dateFormat']) ?? 'd MMM yyyy',
    showCustomer: json['showCustomer'] != false,
    showItemDiscounts: json['showItemDiscounts'] != false,
    showTax: json['showTax'] != false,
    showDelivery: json['showDelivery'] != false,
    showPayment: json['showPayment'] != false,
    accentColorValue: json['accentColorValue'] is int
        ? json['accentColorValue'] as int
        : 0xFF1E3A2F,
  );
}

String? _bytes(Uint8List? bytes) {
  if (bytes == null || bytes.isEmpty) {
    return null;
  }
  return base64Encode(bytes);
}

Uint8List? _optionalBytes(Object? value) {
  final text = _optionalString(value);
  if (text == null) {
    return null;
  }
  return base64Decode(text);
}

String _string(Object? value, String label) {
  final text = _optionalString(value);
  if (text == null) {
    throw FormatException('This backup is missing $label.');
  }
  return text;
}

String? _optionalString(Object? value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  if (text.isEmpty) {
    return null;
  }
  return value.toString();
}

double _double(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse('${value ?? ''}') ?? 0;
}

int _int(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  return int.tryParse('${value ?? ''}') ?? 0;
}
