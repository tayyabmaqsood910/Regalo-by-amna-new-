import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:regalo_by_amna/models/invoice.dart';
import 'package:regalo_by_amna/utils/format.dart';

/// Builds a narrow receipt PDF and opens the system print dialog.
Future<bool> printThermalReceipt(Invoice invoice, {required double widthMm}) {
  final format = _roll(widthMm);
  return Printing.layoutPdf(
    name: invoice.number,
    format: format,
    dynamicLayout: true,
    forceCustomPrintPaper: true,
    onLayout: (pageFormat) => buildThermalReceipt(invoice, format: pageFormat),
  );
}

Future<Uint8List> buildThermalReceipt(
  Invoice invoice, {
  PdfPageFormat? format,
  double widthMm = 80,
}) async {
  final pageFormat = format ?? _roll(widthMm);
  final document = pw.Document();
  document.addPage(
    pw.Page(
      pageFormat: pageFormat,
      build: (context) => _receipt(invoice),
    ),
  );
  return Uint8List.fromList(await document.save());
}

PdfPageFormat _roll(double widthMm) {
  return PdfPageFormat(
    widthMm * PdfPageFormat.mm,
    double.infinity,
    marginAll: 3 * PdfPageFormat.mm,
  );
}

pw.Widget _receipt(Invoice invoice) {
  final settings = invoice.settings;
  final symbol = settings.currencySymbol;
  String money(double amount) => formatMoney(amount, symbol: symbol);
  final muted = PdfColor.fromInt(0xFF5C534C);
  final ink = PdfColor.fromInt(0xFF24302A);
  final accent = PdfColor.fromInt(settings.accentColorValue);
  final title = settings.invoiceTitle.trim().isEmpty
      ? 'Invoice'
      : settings.invoiceTitle.trim();
  final shop = settings.shopName.trim().isEmpty
      ? 'Shop'
      : settings.shopName.trim();

  pw.Widget line(String label, String value, {bool strong = false}) {
    final style = pw.TextStyle(
      fontSize: strong ? 11 : 9,
      fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: strong ? accent : ink,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(child: pw.Text(label, style: style)),
          pw.Text(value, style: style),
        ],
      ),
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      if (settings.logoBytes != null)
        pw.Center(
          child: pw.Image(
            pw.MemoryImage(settings.logoBytes!),
            height: 42,
            fit: pw.BoxFit.contain,
          ),
        ),
      pw.Text(
        shop,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: accent,
        ),
      ),
      pw.SizedBox(height: 2),
      pw.Text(
        settings.address,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontSize: 8, color: muted),
      ),
      pw.Text(
        '${settings.phone} | ${settings.email}',
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontSize: 8, color: muted),
      ),
      pw.SizedBox(height: 6),
      pw.Text(
        title.toUpperCase(),
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 8,
          letterSpacing: 1.2,
          fontWeight: pw.FontWeight.bold,
          color: accent,
        ),
      ),
      pw.Text(
        invoice.number,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
      ),
      pw.Text(
        formatInvoiceDate(
          invoice.createdAt,
          settings.dateFormat,
        ).replaceAll('·', '-'),
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontSize: 8, color: muted),
      ),
      if (settings.showCustomer) ...[
        pw.SizedBox(height: 6),
        pw.Text(
          invoice.customerLabel,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        if (invoice.customerPhone != null)
          pw.Text(
            invoice.customerPhone!,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 8, color: muted),
          ),
      ],
      pw.Divider(color: PdfColors.grey400, height: 12),
      for (final item in invoice.items) ...[
        pw.Text(
          item.name,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                '${item.quantity} x ${money(item.unitPrice)}',
                style: pw.TextStyle(fontSize: 8, color: muted),
              ),
            ),
            pw.Text(
              money(item.lineTotal),
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        if (settings.showItemDiscounts && item.discount > 0)
          pw.Text(
            'Discount ${money(item.discount)}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.red800),
          ),
        pw.SizedBox(height: 4),
      ],
      pw.Divider(color: PdfColors.grey400, height: 10),
      line('Subtotal', money(invoice.subtotal)),
      if (settings.showItemDiscounts)
        line('Item discounts', money(invoice.itemDiscounts)),
      line('Bill discount', money(invoice.billDiscount)),
      if (settings.showTax) line('Tax', money(invoice.tax)),
      if (settings.showDelivery) line('Delivery', money(invoice.deliveryCharges)),
      line('Grand total', money(invoice.grandTotal), strong: true),
      if (settings.showPayment) ...[
        line('Amount paid', money(invoice.amountPaid)),
        line('Balance', money(invoice.balance)),
        pw.SizedBox(height: 2),
        pw.Text(
          invoice.paymentStatus.label,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
      ],
      if (invoice.notes != null && invoice.notes!.trim().isNotEmpty) ...[
        pw.SizedBox(height: 6),
        pw.Text(
          invoice.notes!.trim(),
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 8, color: muted),
        ),
      ],
      if (settings.thankYouMessage.trim().isNotEmpty) ...[
        pw.SizedBox(height: 8),
        pw.Text(
          settings.thankYouMessage.trim(),
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
      ],
      if (settings.footerText.trim().isNotEmpty)
        pw.Text(
          settings.footerText.trim(),
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 8, color: muted),
        ),
      if (settings.terms.trim().isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Text(
          settings.terms.trim(),
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 7, color: muted),
        ),
      ],
    ],
  );
}
