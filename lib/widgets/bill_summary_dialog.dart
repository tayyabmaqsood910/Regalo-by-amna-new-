import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regalo_by_amna/models/invoice.dart';
import 'package:regalo_by_amna/services/thermal_receipt.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';
import 'package:regalo_by_amna/utils/format.dart';
import 'package:regalo_by_amna/widgets/app_button.dart';
import 'package:regalo_by_amna/widgets/payment_status_chip.dart';

Future<void> showBillSummary(BuildContext context, Invoice invoice) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final height = MediaQuery.sizeOf(dialogContext).height;
      return Dialog(
        backgroundColor: AppColors.card,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 460, maxHeight: height * 0.9),
          child: _BillSummary(invoice: invoice),
        ),
      );
    },
  );
}

class _BillSummary extends StatefulWidget {
  const _BillSummary({required this.invoice});

  final Invoice invoice;

  @override
  State<_BillSummary> createState() => _BillSummaryState();
}

class _BillSummaryState extends State<_BillSummary> {
  double? _printingWidth;

  Future<void> _print(double widthMm) async {
    setState(() => _printingWidth = widthMm);
    try {
      final sent = await printThermalReceipt(
        widget.invoice,
        widthMm: widthMm,
      );
      if (!mounted) {
        return;
      }
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            sent
                ? '${widget.invoice.number} was sent to the printer.'
                : 'Printing was cancelled.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The printer could not be opened. $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _printingWidth = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final settings = invoice.settings;
    final symbol = settings.currencySymbol;
    String money(double amount) => formatMoney(amount, symbol: symbol);
    final busy = _printingWidth != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.line),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (settings.logoBytes != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Image.memory(
                          settings.logoBytes!,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                    Text(
                      settings.shopName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: settings.accentColor,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      settings.address,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${settings.phone}  ·  ${settings.email}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invoice.number,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              Text(
                                formatInvoiceDate(
                                  invoice.createdAt,
                                  settings.dateFormat,
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        PaymentStatusChip(status: invoice.paymentStatus),
                      ],
                    ),
                    if (settings.showCustomer) ...[
                      const SizedBox(height: 12),
                      Text(
                        invoice.customerLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (invoice.customerPhone != null)
                        Text(
                          invoice.customerPhone!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                    const Divider(height: 22),
                    for (final item in invoice.items) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${item.quantity} × ${money(item.unitPrice)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (settings.showItemDiscounts &&
                                    item.discount > 0)
                                  Text(
                                    'Item discount ${money(item.discount)}',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.blushDeep,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(money(item.lineTotal)),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    const Divider(height: 12),
                    _TotalLine(label: 'Subtotal', value: money(invoice.subtotal)),
                    if (settings.showItemDiscounts)
                      _TotalLine(
                        label: 'Item discounts',
                        value: money(invoice.itemDiscounts),
                      ),
                    _TotalLine(
                      label: 'Bill discount',
                      value: money(invoice.billDiscount),
                    ),
                    if (settings.showTax)
                      _TotalLine(label: 'Tax', value: money(invoice.tax)),
                    if (settings.showDelivery)
                      _TotalLine(
                        label: 'Delivery',
                        value: money(invoice.deliveryCharges),
                      ),
                    const SizedBox(height: 6),
                    _TotalLine(
                      label: 'Grand total',
                      value: money(invoice.grandTotal),
                      emphasis: true,
                    ),
                    if (settings.showPayment) ...[
                      _TotalLine(
                        label: 'Amount paid',
                        value: money(invoice.amountPaid),
                      ),
                      _TotalLine(
                        label: 'Balance',
                        value: money(invoice.balance),
                      ),
                    ],
                    if (invoice.notes != null &&
                        invoice.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        invoice.notes!.trim(),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (settings.thankYouMessage.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        settings.thankYouMessage.trim(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                    ],
                    if (settings.footerText.trim().isNotEmpty)
                      Text(
                        settings.footerText.trim(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  AppButton(
                    key: const Key('print-58'),
                    label: _printingWidth == 58 ? 'Opening…' : 'Print 58 mm',
                    icon: Icons.print_outlined,
                    variant: AppButtonVariant.secondary,
                    onPressed: busy ? null : () => _print(58),
                  ),
                  AppButton(
                    key: const Key('print-80'),
                    label: _printingWidth == 80 ? 'Opening…' : 'Print 80 mm',
                    icon: Icons.print,
                    onPressed: busy ? null : () => _print(80),
                  ),
                  TextButton(
                    onPressed: busy ? null : () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TotalLine extends StatelessWidget {
  const _TotalLine({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final style = emphasis
        ? GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.forest,
          )
        : GoogleFonts.outfit(fontSize: 14, color: AppColors.ink);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
