import 'package:flutter/material.dart';
import 'package:regalo_by_amna/app_scope.dart';
import 'package:regalo_by_amna/models/invoice.dart';
import 'package:regalo_by_amna/models/payment_status.dart';
import 'package:regalo_by_amna/navigation/app_destination.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';
import 'package:regalo_by_amna/utils/format.dart';
import 'package:regalo_by_amna/widgets/app_button.dart';
import 'package:regalo_by_amna/widgets/bill_summary_dialog.dart';
import 'package:regalo_by_amna/widgets/empty_state.dart';
import 'package:regalo_by_amna/widgets/page_header.dart';
import 'package:regalo_by_amna/widgets/payment_status_chip.dart';
import 'package:regalo_by_amna/widgets/sales_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.onNavigate});

  final ValueChanged<AppDestination> onNavigate;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _search = TextEditingController();
  String _query = '';
  PaymentStatus? _status;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final symbol = store.settings.currencySymbol;
    final bills = store.billsNewestFirst;
    final collected = bills.fold<double>(0, (sum, bill) => sum + bill.amountPaid);
    final outstanding = bills.fold<double>(0, (sum, bill) => sum + bill.balance);
    final needle = _query.trim().toLowerCase();
    final visible = bills.where((bill) {
      final matchesStatus = _status == null || bill.paymentStatus == _status;
      final matchesQuery =
          needle.isEmpty ||
          bill.number.toLowerCase().contains(needle) ||
          bill.customerLabel.toLowerCase().contains(needle);
      return matchesStatus && matchesQuery;
    }).toList();

    return PageBody(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: 'Dashboard',
              subtitle: store.settings.shopName,
              action: AppButton(
                key: const Key('new-bill'),
                label: 'New bill',
                icon: Icons.add,
                onPressed: () => widget.onNavigate(AppDestination.newBill),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: [
                TextButton(
                  key: const Key('quick-products'),
                  onPressed: () => widget.onNavigate(AppDestination.products),
                  child: const Text('Products'),
                ),
                TextButton(
                  key: const Key('view-history'),
                  onPressed: () =>
                      widget.onNavigate(AppDestination.billHistory),
                  child: const Text('Bill history'),
                ),
                TextButton(
                  key: const Key('quick-invoice'),
                  onPressed: () => widget.onNavigate(
                    AppDestination.invoiceCustomization,
                  ),
                  child: const Text('Invoice'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Metrics(
              bills: store.billCount,
              sales: formatMoney(store.totalSales, symbol: symbol),
              collected: formatMoney(collected, symbol: symbol),
              outstanding: formatMoney(outstanding, symbol: symbol),
            ),
            if (bills.isNotEmpty) ...[
              const SizedBox(height: 16),
              SalesChart(bills: store.invoices),
            ],
            const SizedBox(height: 16),
            if (bills.isEmpty)
              const EmptyState(
                key: Key('empty-bills'),
                icon: Icons.receipt_long_outlined,
                title: 'No bills in this session yet',
                message: 'New bills are listed here as soon as they are saved.',
              )
            else ...[
              TextField(
                key: const Key('dashboard-search'),
                controller: _search,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Search invoice or customer',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  _Filter(
                    label: 'All',
                    selected: _status == null,
                    onTap: () => setState(() => _status = null),
                  ),
                  for (final status in PaymentStatus.values)
                    _Filter(
                      label: status.label,
                      selected: _status == status,
                      onTap: () => setState(() => _status = status),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${visible.length} records',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              if (visible.isEmpty)
                const Text('No records match that search.')
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
                        _Record(invoice: visible[i], symbol: symbol),
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

class _Metrics extends StatelessWidget {
  const _Metrics({
    required this.bills,
    required this.sales,
    required this.collected,
    required this.outstanding,
  });

  final int bills;
  final String sales;
  final String collected;
  final String outstanding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cells = [
              _Metric(
                label: 'Bills',
                value: '$bills',
                valueKey: const Key('dashboard-bill-count'),
              ),
              _Metric(
                label: 'Total',
                value: sales,
                valueKey: const Key('dashboard-sales'),
              ),
              _Metric(label: 'Collected', value: collected),
              _Metric(label: 'Balance', value: outstanding),
            ];
            if (constraints.maxWidth < 640) {
              return Column(
                children: [
                  for (var i = 0; i < cells.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    cells[i],
                  ],
                ],
              );
            }
            return IntrinsicHeight(
              child: Row(
                children: [
                  for (var i = 0; i < cells.length; i++) ...[
                    if (i > 0)
                      const VerticalDivider(width: 1, color: AppColors.line),
                    Expanded(child: cells[i]),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.valueKey});

  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            value,
            key: valueKey,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.forest,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Filter extends StatelessWidget {
  const _Filter({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.sageLight,
      backgroundColor: AppColors.card,
      side: const BorderSide(color: AppColors.line),
      labelStyle: TextStyle(
        color: AppColors.forest,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

class _Record extends StatelessWidget {
  const _Record({required this.invoice, required this.symbol});

  final Invoice invoice;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showBillSummary(context, invoice),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Text(invoice.customerLabel),
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
