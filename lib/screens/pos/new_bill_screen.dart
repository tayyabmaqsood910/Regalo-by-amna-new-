import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regalo_by_amna/app_scope.dart';
import 'package:regalo_by_amna/models/product.dart';
import 'package:regalo_by_amna/services/demo_store.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';
import 'package:regalo_by_amna/utils/format.dart';
import 'package:regalo_by_amna/widgets/app_button.dart';
import 'package:regalo_by_amna/widgets/app_card.dart';
import 'package:regalo_by_amna/widgets/bill_item_row.dart';
import 'package:regalo_by_amna/widgets/bill_summary_dialog.dart';
import 'package:regalo_by_amna/widgets/confirm_dialog.dart';
import 'package:regalo_by_amna/widgets/empty_state.dart';
import 'package:regalo_by_amna/widgets/page_header.dart';
import 'package:regalo_by_amna/widgets/payment_status_chip.dart';
import 'package:regalo_by_amna/widgets/product_card.dart';
import 'package:regalo_by_amna/widgets/synced_text_field.dart';

class NewBillScreen extends StatefulWidget {
  const NewBillScreen({super.key});

  @override
  State<NewBillScreen> createState() => _NewBillScreenState();
}

class _NewBillScreenState extends State<NewBillScreen> {
  final _search = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final padding = width < 600 ? 16.0 : 28.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 20, padding, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'New Bill',
            subtitle: 'Choose an item, then set the price for this sale.',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final catalog = _CatalogPane(
                  store: store,
                  query: _query,
                  category: _category,
                  search: _search,
                  onQuery: (value) => setState(() => _query = value),
                  onCategory: (value) => setState(() => _category = value),
                );
                final bill = _BillPane(store: store);
                if (constraints.maxWidth >= 980) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 5, child: catalog),
                      const SizedBox(width: 16),
                      Expanded(flex: 6, child: bill),
                    ],
                  );
                }
                return Column(
                  children: [
                    Expanded(flex: 5, child: catalog),
                    const SizedBox(height: 12),
                    Expanded(flex: 6, child: bill),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogPane extends StatelessWidget {
  const _CatalogPane({
    required this.store,
    required this.query,
    required this.category,
    required this.search,
    required this.onQuery,
    required this.onCategory,
  });

  final DemoStore store;
  final String query;
  final String? category;
  final TextEditingController search;
  final ValueChanged<String> onQuery;
  final ValueChanged<String?> onCategory;

  @override
  Widget build(BuildContext context) {
    final categories = store.products
        .map((product) => product.category)
        .whereType<String>()
        .toSet()
        .toList();
    final needle = query.trim().toLowerCase();
    final products = store.products.where((product) {
      final matchesCategory = category == null || product.category == category;
      final matchesQuery =
          needle.isEmpty ||
          product.name.toLowerCase().contains(needle) ||
          (product.category?.toLowerCase().contains(needle) ?? false);
      return matchesCategory && matchesQuery;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const Key('product-search'),
          controller: search,
          onChanged: onQuery,
          decoration: const InputDecoration(
            hintText: 'Search flowers',
            prefixIcon: Icon(Icons.search),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _CategoryChip(
                label: 'All',
                selected: category == null,
                onSelected: () => onCategory(null),
              ),
              for (final name in categories) ...[
                const SizedBox(width: 8),
                _CategoryChip(
                  label: name,
                  selected: category == name,
                  onSelected: () => onCategory(name),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: products.isEmpty
              ? const Center(child: Text('No flowers match that search.'))
              : GridView.builder(
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    mainAxisExtent: 72,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      key: Key('product-${product.id}'),
                      product: product,
                      onTap: () =>
                          _addProductAtCustomPrice(context, store, product),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: AppColors.sageLight,
      backgroundColor: AppColors.card,
      side: const BorderSide(color: AppColors.line),
      labelStyle: GoogleFonts.outfit(
        color: AppColors.forest,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}

class _BillPane extends StatelessWidget {
  const _BillPane({required this.store});

  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final draft = store.draft;
    final symbol = store.settings.currencySymbol;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current bill',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Prices here apply to this bill only.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (draft.items.isNotEmpty)
                PaymentStatusChip(status: draft.paymentStatus),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                SyncedTextField(
                  key: const Key('customer-name'),
                  value: draft.customerName,
                  label: 'Customer name',
                  hint: 'Optional',
                  onChanged: (value) => store.updateDraft(customerName: value),
                ),
                const SizedBox(height: 10),
                SyncedTextField(
                  value: draft.customerPhone,
                  label: 'Phone',
                  hint: 'Optional',
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => store.updateDraft(customerPhone: value),
                ),
                const SizedBox(height: 8),
                if (draft.items.isEmpty)
                  const EmptyState(
                    icon: Icons.local_florist_outlined,
                    title: 'No items yet',
                    message: 'Tap a flower, or add something that is not on the list.',
                  )
                else
                  for (final item in draft.items)
                    BillItemRow(
                      key: ValueKey(item.id),
                      item: item,
                      symbol: symbol,
                      onQuantity: (quantity) =>
                          store.updateLine(item.id, quantity: quantity),
                      onUnitPrice: (price) =>
                          store.updateLine(item.id, unitPrice: price),
                      onDiscount: (discount) =>
                          store.updateLine(item.id, discount: discount),
                      onRemove: () => store.removeLine(item.id),
                    ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppButton(
                    key: const Key('add-custom-item'),
                    label: 'Add custom item',
                    icon: Icons.add,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => _showCustomItemDialog(context, store),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MoneyField(
                        value: draft.billDiscount,
                        label: 'Bill discount',
                        onChanged: (value) =>
                            store.updateDraft(billDiscount: value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MoneyField(
                        value: draft.tax,
                        label: 'Tax',
                        onChanged: (value) => store.updateDraft(tax: value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: MoneyField(
                        value: draft.deliveryCharges,
                        label: 'Delivery',
                        onChanged: (value) =>
                            store.updateDraft(deliveryCharges: value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MoneyField(
                        value: draft.amountPaid,
                        label: 'Amount paid',
                        onChanged: (value) =>
                            store.updateDraft(amountPaid: value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SyncedTextField(
                  value: draft.notes,
                  label: 'Notes',
                  hint: 'Delivery instructions, optional',
                  maxLines: 2,
                  onChanged: (value) => store.updateDraft(notes: value),
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          _TotalLine(
            label: 'Subtotal',
            value: formatMoney(draft.subtotal, symbol: symbol),
          ),
          _TotalLine(
            label: 'Item discounts',
            value: formatMoney(draft.itemDiscounts, symbol: symbol),
          ),
          _TotalLine(
            label: 'Bill discount',
            value: formatMoney(draft.billDiscount, symbol: symbol),
          ),
          _TotalLine(
            label: 'Tax',
            value: formatMoney(draft.tax, symbol: symbol),
          ),
          _TotalLine(
            label: 'Delivery',
            value: formatMoney(draft.deliveryCharges, symbol: symbol),
          ),
          _TotalLine(
            label: 'Grand total',
            value: formatMoney(draft.grandTotal, symbol: symbol),
            emphasis: true,
          ),
          _TotalLine(
            label: 'Amount paid',
            value: formatMoney(draft.amountPaid, symbol: symbol),
          ),
          _TotalLine(
            label: 'Balance',
            value: formatMoney(draft.balance, symbol: symbol),
            emphasis: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  key: const Key('clear-bill'),
                  label: 'Clear',
                  variant: AppButtonVariant.secondary,
                  onPressed: draft.hasContent
                      ? () => _clear(context, store)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  key: const Key('generate-bill'),
                  label: 'Generate bill',
                  icon: Icons.check,
                  onPressed: () => _generate(context, store),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _clear(BuildContext context, DemoStore store) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Clear this bill?',
      message: 'The flowers on this bill will be removed. Saved bills stay in history.',
      confirmLabel: 'Clear bill',
      destructive: true,
    );
    if (confirmed) {
      store.clearDraft();
    }
  }

  Future<void> _generate(BuildContext context, DemoStore store) async {
    if (store.draft.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one item before generating the bill.'),
        ),
      );
      return;
    }
    final invoice = store.generateCurrentBill();
    if (invoice == null || !context.mounted) {
      return;
    }
    await showBillSummary(context, invoice);
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
            fontSize: 15,
            color: AppColors.forest,
          )
        : GoogleFonts.outfit(fontSize: 13, color: AppColors.ink);
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

Future<void> _addProductAtCustomPrice(
  BuildContext context,
  DemoStore store,
  Product product,
) async {
  final price = await showDialog<double>(
    context: context,
    builder: (dialogContext) => _PriceDialog(product: product),
  );
  if (price == null) {
    return;
  }
  store.addProduct(product, unitPrice: price);
}

class _PriceDialog extends StatefulWidget {
  const _PriceDialog({required this.product});

  final Product product;

  @override
  State<_PriceDialog> createState() => _PriceDialogState();
}

class _PriceDialogState extends State<_PriceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _price = TextEditingController(
    text: formatEditableAmount(widget.product.price),
  );

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(widget.product.name),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _price,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Price for this bill (Rs.)',
          ),
          validator: (value) {
            final parsed = parseAmount(value ?? '');
            if (parsed == null || parsed < 0) {
              return 'Enter 0 or more';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }
            Navigator.pop(context, parseAmount(_price.text));
          },
          child: const Text('Add to bill'),
        ),
      ],
    );
  }
}

Future<void> _showCustomItemDialog(
  BuildContext context,
  DemoStore store,
) async {
  final name = TextEditingController();
  final price = TextEditingController();
  final quantity = TextEditingController(text: '1');
  final formKey = GlobalKey<FormState>();

  final added = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Custom item'),
        content: Form(
          key: formKey,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Price (Rs.)'),
                  validator: (value) {
                    final parsed = parseAmount(value ?? '');
                    if (parsed == null || parsed < 0) {
                      return 'Enter 0 or more';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: quantity,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed < 1) {
                      return 'Enter a quantity of at least 1';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Add item'),
          ),
        ],
      );
    },
  );

  if (added ?? false) {
    store.addCustomItem(
      name: name.text,
      unitPrice: parseAmount(price.text) ?? 0,
      quantity: int.parse(quantity.text),
    );
  }
  name.dispose();
  price.dispose();
  quantity.dispose();
}
