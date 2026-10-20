import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Shop branding and invoice options. Generated bills keep their own copy.
class InvoiceSettings {
  const InvoiceSettings({
    this.shopName = 'Regalo by Amna',
    this.logoPath,
    this.logoBytes,
    this.address = '12 Garden Lane, Gulberg, Lahore',
    this.phone = '042-111-0000',
    this.email = 'hello@regalobyamna.example',
    this.invoiceTitle = 'Invoice',
    this.numberPrefix = 'INV-',
    this.nextNumber = 1005,
    this.thankYouMessage = 'Thank you for choosing Regalo by Amna.',
    this.footerText = 'Fresh flowers, thoughtfully arranged.',
    this.terms = 'Please check your arrangement before you leave. Delivery times are estimates.',
    this.currencyCode = 'PKR',
    this.currencySymbol = 'Rs.',
    this.dateFormat = 'd MMM yyyy',
    this.showCustomer = true,
    this.showItemDiscounts = true,
    this.showTax = true,
    this.showDelivery = true,
    this.showPayment = true,
    this.accentColorValue = 0xFF1E3A2F,
  });

  const InvoiceSettings.regalo() : this();

  final String shopName;
  final String? logoPath;
  final Uint8List? logoBytes;
  final String address;
  final String phone;
  final String email;
  final String invoiceTitle;
  final String numberPrefix;
  final int nextNumber;
  final String thankYouMessage;
  final String footerText;
  final String terms;
  final String currencyCode;
  final String currencySymbol;
  final String dateFormat;
  final bool showCustomer;
  final bool showItemDiscounts;
  final bool showTax;
  final bool showDelivery;
  final bool showPayment;
  final int accentColorValue;

  Color get accentColor => Color(accentColorValue);

  String get nextInvoiceNumber =>
      '$numberPrefix${nextNumber.toString().padLeft(4, '0')}';

  InvoiceSettings copyWith({
    String? shopName,
    String? logoPath,
    Uint8List? logoBytes,
    String? address,
    String? phone,
    String? email,
    String? invoiceTitle,
    String? numberPrefix,
    int? nextNumber,
    String? thankYouMessage,
    String? footerText,
    String? terms,
    String? currencyCode,
    String? currencySymbol,
    String? dateFormat,
    bool? showCustomer,
    bool? showItemDiscounts,
    bool? showTax,
    bool? showDelivery,
    bool? showPayment,
    int? accentColorValue,
    bool clearLogo = false,
  }) {
    return InvoiceSettings(
      shopName: shopName ?? this.shopName,
      logoPath: clearLogo ? null : (logoPath ?? this.logoPath),
      logoBytes: clearLogo ? null : (logoBytes ?? this.logoBytes),
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      invoiceTitle: invoiceTitle ?? this.invoiceTitle,
      numberPrefix: numberPrefix ?? this.numberPrefix,
      nextNumber: nextNumber ?? this.nextNumber,
      thankYouMessage: thankYouMessage ?? this.thankYouMessage,
      footerText: footerText ?? this.footerText,
      terms: terms ?? this.terms,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      dateFormat: dateFormat ?? this.dateFormat,
      showCustomer: showCustomer ?? this.showCustomer,
      showItemDiscounts: showItemDiscounts ?? this.showItemDiscounts,
      showTax: showTax ?? this.showTax,
      showDelivery: showDelivery ?? this.showDelivery,
      showPayment: showPayment ?? this.showPayment,
      accentColorValue: accentColorValue ?? this.accentColorValue,
    );
  }
}
