import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regalo_by_amna/models/invoice_settings.dart';
import 'package:regalo_by_amna/utils/format.dart';

enum InvoicePaper { thermal58, thermal80, a4 }

/// A fixed arrangement so the customization preview can show every toggle.
class InvoicePreviewSample {
  static final createdAt = DateTime(2026, 10, 20, 13, 15);
  static const customerName = 'Ayesha Khan';
  static const customerPhone = '0301-5550142';
  static const lines = [
    _PreviewLine('Red Rose', 2, 150, 0),
    _PreviewLine('Birthday Bouquet', 1, 5200, 200),
  ];
  static const tax = 100.0;
  static const delivery = 200.0;
  static const amountPaid = 4000.0;

  static double get itemDiscounts =>
      lines.fold(0, (sum, line) => sum + line.discount);

  static double get subtotal =>
      lines.fold(0, (sum, line) => sum + line.lineTotal);

  static double grandTotal(InvoiceSettings settings) {
    return subtotal +
        (settings.showTax ? tax : 0) +
        (settings.showDelivery ? delivery : 0);
  }
}

class _PreviewLine {
  const _PreviewLine(this.name, this.quantity, this.unitPrice, this.discount);

  final String name;
  final int quantity;
  final double unitPrice;
  final double discount;

  double get lineTotal {
    final total = (quantity * unitPrice) - discount;
    return total < 0 ? 0 : total;
  }
}

class InvoicePreview extends StatelessWidget {
  const InvoicePreview({
    super.key,
    required this.settings,
    required this.paper,
  });

  final InvoiceSettings settings;
  final InvoicePaper paper;

  @override
  Widget build(BuildContext context) {
    final thermal = paper != InvoicePaper.a4;
    final width = switch (paper) {
      InvoicePaper.thermal58 => 220.0,
      InvoicePaper.thermal80 => 302.0,
      InvoicePaper.a4 => double.infinity,
    };
    final invoice = _InvoiceBody(settings: settings, thermal: thermal);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(thermal ? 4 : 8),
            border: Border.all(color: const Color(0xFFE7E0D6)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2C1A20),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: invoice,
        ),
      ),
    );
  }
}

class _InvoiceBody extends StatelessWidget {
  const _InvoiceBody({required this.settings, required this.thermal});

  final InvoiceSettings settings;
  final bool thermal;

  @override
  Widget build(BuildContext context) {
    final accent = settings.accentColor;
    final symbol = settings.currencySymbol;
    String money(double amount) => formatMoney(amount, symbol: symbol);
    final grand = InvoicePreviewSample.grandTotal(settings);
    final balance = grand - InvoicePreviewSample.amountPaid;
    final shop = settings.shopName.trim().isEmpty
        ? 'Shop name'
        : settings.shopName.trim();
    final title = settings.invoiceTitle.trim().isEmpty
        ? 'Invoice'
        : settings.invoiceTitle.trim();

    final header = Column(
      crossAxisAlignment: thermal
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (settings.logoBytes != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Image.memory(
              settings.logoBytes!,
              height: thermal ? 42 : 56,
              fit: BoxFit.contain,
            ),
          )
        else
          Icon(Icons.local_florist, color: accent, size: thermal ? 22 : 28),
        Text(
          shop,
          textAlign: thermal ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.cormorantGaramond(
            fontSize: thermal ? 22 : 28,
            fontWeight: FontWeight.w600,
            color: thermal ? accent : Colors.white,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          settings.address,
          textAlign: thermal ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.outfit(
            fontSize: 11,
            height: 1.35,
            color: thermal ? const Color(0xFF5C534C) : const Color(0xFFF6EDE4),
          ),
        ),
        Text(
          '${settings.phone}  ·  ${settings.email}',
          textAlign: thermal ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: thermal ? const Color(0xFF5C534C) : const Color(0xFFF6EDE4),
          ),
        ),
      ],
    );

    final meta = Column(
      crossAxisAlignment: thermal
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: thermal ? accent : accent,
          ),
        ),
        Text(
          settings.nextInvoiceNumber,
          style: GoogleFonts.outfit(
            fontSize: thermal ? 13 : 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          formatInvoiceDate(InvoicePreviewSample.createdAt, settings.dateFormat),
          style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF6D6560)),
        ),
        Text(
          settings.currencyCode,
          style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF6D6560)),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (thermal)
          Padding(padding: const EdgeInsets.fromLTRB(12, 14, 12, 8), child: header)
        else
          ColoredBox(
            color: accent,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: header,
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(thermal ? 12 : 20, 12, thermal ? 12 : 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (thermal) ...[
                meta,
                const SizedBox(height: 8),
                const _Rule(),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: SizedBox()),
                    meta,
                  ],
                ),
              if (settings.showCustomer) ...[
                const SizedBox(height: 10),
                Text(
                  InvoicePreviewSample.customerName,
                  textAlign: thermal ? TextAlign.center : TextAlign.start,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  InvoicePreviewSample.customerPhone,
                  textAlign: thermal ? TextAlign.center : TextAlign.start,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: const Color(0xFF6D6560),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              const _Rule(),
              for (final line in InvoicePreviewSample.lines) ...[
                const SizedBox(height: 8),
                _LineRow(line: line, money: money),
              ],
              const SizedBox(height: 8),
              const _Rule(),
              const SizedBox(height: 8),
              _AmountRow(label: 'Subtotal', value: money(InvoicePreviewSample.subtotal)),
              if (settings.showItemDiscounts)
                _AmountRow(
                  label: 'Item discounts',
                  value: money(InvoicePreviewSample.itemDiscounts),
                ),
              if (settings.showTax)
                _AmountRow(label: 'Tax', value: money(InvoicePreviewSample.tax)),
              if (settings.showDelivery)
                _AmountRow(
                  label: 'Delivery',
                  value: money(InvoicePreviewSample.delivery),
                ),
              const SizedBox(height: 4),
              _AmountRow(label: 'Grand total', value: money(grand), strong: true, color: accent),
              if (settings.showPayment) ...[
                _AmountRow(
                  label: 'Amount paid',
                  value: money(InvoicePreviewSample.amountPaid),
                ),
                _AmountRow(label: 'Balance', value: money(balance < 0 ? 0 : balance)),
              ],
              if (settings.thankYouMessage.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  settings.thankYouMessage.trim(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
              if (settings.footerText.trim().isNotEmpty)
                Text(
                  settings.footerText.trim(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: const Color(0xFF6D6560),
                  ),
                ),
              if (settings.terms.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  settings.terms.trim(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    height: 1.35,
                    color: const Color(0xFF8A817A),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line, required this.money});

  final _PreviewLine line;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          line.name,
          style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                '${line.quantity} × ${money(line.unitPrice)}',
                style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF6D6560)),
              ),
            ),
            Text(
              money(line.lineTotal),
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        if (line.discount > 0)
          Text(
            'Discount ${money(line.discount)}',
            style: GoogleFonts.outfit(fontSize: 10.5, color: const Color(0xFF8E3B3B)),
          ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.strong = false,
    this.color,
  });

  final String label;
  final String value;
  final bool strong;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.outfit(
      fontSize: strong ? 13.5 : 12,
      fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFFE4DCD0));
  }
}
