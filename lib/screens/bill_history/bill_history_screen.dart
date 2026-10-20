import 'package:flutter/material.dart';
import 'package:regalo_by_amna/app_scope.dart';
import 'package:regalo_by_amna/models/invoice.dart';
import 'package:regalo_by_amna/models/payment_status.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';
import 'package:regalo_by_amna/utils/format.dart';
import 'package:regalo_by_amna/widgets/bill_summary_dialog.dart';
import 'package:regalo_by_amna/widgets/empty_state.dart';
import 'package:regalo_by_amna/widgets/page_header.dart';
import 'package:regalo_by_amna/widgets/payment_status_chip.dart';

class BillHistoryScreen extends StatefulWidget {
  const BillHistoryScreen({super.key});

  @override
  State<BillHistoryScreen> createState() => _BillHistoryScreenState();
}

class _BillHistoryScreenState extends State<BillHistoryScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final bills = store.billsNewestFirst;
    final symbol = store.settings.currencySymbol;
    final needle = _query.trim().toLowerCase();
    final visible = bills.where((bill) {
      if (needle.isEmpty) {
        return true;
      }
      return bill.number.toLowerCase().contains(needle) ||
          bill.customerLabel.toLowerCase().contains(needle) ||
          (bill.customerPhone?.toLowerCase().contains(needle) ?? false);
    }).toList();
    final total = bills.fold<double>(0, (sum, bill) => sum + bill.grandTotal);

    return PageBody(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              title: 'Bill History',
              subtitle: 'Invoices saved during this session.',
            ),
            const SizedBox(height: 20),
            if (bills.isEmpty)
              const EmptyState(
                key: Key('empty-bills'),
                icon: Icons.history,
                title: 'No bills in this session yet',
                message: 'Generated bills will appear here.',
              )
            else ...[
              TextField(
                key: const Key('bill-search'),
                controller: _search,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Search invoice or customer',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              _Summary(bills: bills, total: total, symbol: symbol),
              const SizedBox(height: 16),
              if (visible.isEmpty)
                const Text('No bills match that search.')
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < visible.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 1, color: AppColors.line),
                        _HistoryRow(invoice: visible[i], symbol: symbol),
                      ],
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.bills,
    required this.total,
    required this.symbol,
  });

  final List<Invoice> bills;
  final double total;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    int count(PaymentStatus status) {
      return bills.where((bill) => bill.paymentStatus == status).length;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Wrap(
          spacing: 20,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Count(label: 'Paid', value: count(PaymentStatus.paid)),
            _Count(label: 'Partial', value: count(PaymentStatus.partial)),
            _Count(label: 'Unpaid', value: count(PaymentStatus.unpaid)),
            Text(
              formatMoney(total, symbol: symbol),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.forest,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '$value  ',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.forest,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(
            text: label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.invoice, required this.symbol});

  final Invoice invoice;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showBillSummary(context, invoice),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.number,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    invoice.customerLabel,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    formatDateTime(invoice.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatMoney(invoice.grandTotal, symbol: symbol),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.forest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                PaymentStatusChip(status: invoice.paymentStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
