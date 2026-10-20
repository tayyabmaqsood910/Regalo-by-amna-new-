import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regalo_by_amna/app_scope.dart';
import 'package:regalo_by_amna/models/product.dart';
import 'package:regalo_by_amna/screens/products/product_form_dialog.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';
import 'package:regalo_by_amna/utils/format.dart';
import 'package:regalo_by_amna/widgets/app_button.dart';
import 'package:regalo_by_amna/widgets/app_card.dart';
import 'package:regalo_by_amna/widgets/confirm_dialog.dart';
import 'package:regalo_by_amna/widgets/page_header.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  String _query = '';
  String? _category;

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final symbol = store.settings.currencySymbol;
    final categories = store.products
        .map((product) => product.category)
        .whereType<String>()
        .toSet()
        .toList();
    final needle = _query.trim().toLowerCase();
    final products = store.products.where((product) {
      final matchesCategory =
          _category == null || product.category == _category;
      final matchesQuery =
          needle.isEmpty ||
          product.name.toLowerCase().contains(needle) ||
          (product.category?.toLowerCase().contains(needle) ?? false);
      return matchesCategory && matchesQuery;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = constraints.maxWidth < 600 ? 16.0 : 32.0;
        final contentWidth =
            (constraints.maxWidth > 1120 ? 1120 : constraints.maxWidth) -
            (padding * 2);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Padding(
              padding: EdgeInsets.fromLTRB(padding, 20, padding, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'Products',
                    subtitle:
                        '${store.products.length} items in the price list. Stock is not tracked.',
                    action: AppButton(
                      key: const Key('add-product'),
                      label: 'Add product',
                      icon: Icons.add,
                      onPressed: () => _openForm(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('price-list-search'),
                    controller: _search,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                      hintText: 'Search products',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _CategoryChip(
                                label: 'All',
                                selected: _category == null,
                                onSelected: () =>
                                    setState(() => _category = null),
                              ),
                              for (final category in categories) ...[
                                const SizedBox(width: 8),
                                _CategoryChip(
                                  label: category,
                                  selected: _category == category,
                                  onSelected: () =>
                                      setState(() => _category = category),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        key: const Key('add-product-chip'),
                        onPressed: () => _openForm(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: products.isEmpty
                        ? const Align(
                            alignment: Alignment.topLeft,
                            child: Text('No products match that search.'),
                          )
                        : SingleChildScrollView(
                            controller: _scroll,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                for (final product in products)
                                  SizedBox(
                                    width: _tileWidth(contentWidth),
                                    child: _PriceListCard(
                                      product: product,
                                      symbol: symbol,
                                      onEdit: () => _openForm(product: product),
                                      onDelete: () => _delete(product),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openForm({Product? product}) async {
    final result = await showDialog<ProductFormResult>(
      context: context,
      builder: (context) => ProductFormDialog(product: product),
    );
    if (!mounted || result == null) {
      return;
    }
    final store = AppScope.of(context);
    switch (result) {
      case ProductFormSaved(:final product):
        final exists = store.products.any((item) => item.id == product.id);
        if (exists) {
          store.updateCatalogProduct(product);
        } else {
          store.addCatalogProduct(product);
          setState(() {
            _category = null;
            _query = '';
            _search.clear();
          });
          _showNewest();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              exists
                  ? '${product.name} updated.'
                  : '${product.name} added to the price list.',
            ),
          ),
        );
      case ProductFormDeleted(:final id):
        store.deleteCatalogProduct(id);
    }
  }

  void _showNewest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(0);
      }
    });
  }

  double _tileWidth(double available) {
    const gap = 12.0;
    final columns = available >= 900
        ? 3
        : available >= 560
        ? 2
        : 1;
    return (available - (gap * (columns - 1))) / columns;
  }

  Future<void> _delete(Product product) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete ${product.name}?',
      message: 'This removes it from the price list. Bills already made keep their items and prices.',
      confirmLabel: 'Delete product',
      destructive: true,
    );
    if (!mounted || !confirmed) {
      return;
    }
    AppScope.of(context).deleteCatalogProduct(product.id);
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

class _PriceListCard extends StatelessWidget {
  const _PriceListCard({
    required this.product,
    required this.symbol,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final String symbol;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.imageBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                product.imageBytes!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(product.name, style: Theme.of(context).textTheme.titleMedium),
          if (product.category != null) ...[
            const SizedBox(height: 4),
            Text(
              product.category!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (product.description != null) ...[
            const SizedBox(height: 8),
            Text(
              product.description!,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatMoney(product.price, symbol: symbol),
                  style: GoogleFonts.outfit(
                    color: AppColors.forest,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Delete ${product.name}',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: AppColors.muted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
