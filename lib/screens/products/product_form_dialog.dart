import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:regalo_by_amna/models/product.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';
import 'package:regalo_by_amna/utils/format.dart';
import 'package:regalo_by_amna/widgets/app_button.dart';
import 'package:regalo_by_amna/widgets/confirm_dialog.dart';

/// A saved product, or a request to delete the product being edited.
sealed class ProductFormResult {}

class ProductFormSaved extends ProductFormResult {
  ProductFormSaved(this.product);

  final Product product;
}

class ProductFormDeleted extends ProductFormResult {
  ProductFormDeleted(this.id);

  final String id;
}

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.product?.name ?? '',
  );
  late final TextEditingController _category = TextEditingController(
    text: widget.product?.category ?? '',
  );
  late final TextEditingController _price = TextEditingController(
    text: widget.product == null
        ? ''
        : formatEditableAmount(widget.product!.price),
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.product?.description ?? '',
  );
  Uint8List? _imageBytes;
  var _clearedImage = false;
  var _pickingImage = false;

  bool get _editing => widget.product != null;

  Uint8List? get _shownImage =>
      _clearedImage ? null : (_imageBytes ?? widget.product?.imageBytes);

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = (MediaQuery.sizeOf(context).width - 96).clamp(
      260.0,
      420.0,
    );
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(_editing ? 'Edit product' : 'Add product'),
      content: SizedBox(
        width: dialogWidth,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  key: const Key('product-name'),
                  controller: _name,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Product name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const Key('product-category'),
                  controller: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'Optional, such as Roses or Bouquets',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const Key('product-price'),
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Default selling price (Rs.)',
                  ),
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
                  key: const Key('product-description'),
                  controller: _description,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Optional',
                  ),
                ),
                const SizedBox(height: 14),
                _ImagePicker(
                  bytes: _shownImage,
                  busy: _pickingImage,
                  onPick: _pickImage,
                  onRemove: _shownImage == null
                      ? null
                      : () => setState(() {
                          _imageBytes = null;
                          _clearedImage = true;
                        }),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (_editing)
          TextButton(onPressed: _delete, child: const Text('Delete')),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        AppButton(
          key: const Key('save-product'),
          label: _editing ? 'Save changes' : 'Save product',
          onPressed: _save,
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    setState(() => _pickingImage = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 75,
      );
      if (file == null || !mounted) {
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() {
        _imageBytes = bytes;
        _clearedImage = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open that photo.')),
      );
    } finally {
      if (mounted) {
        setState(() => _pickingImage = false);
      }
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final category = _category.text.trim();
    final description = _description.text.trim();
    Navigator.pop(
      context,
      ProductFormSaved(
        Product(
          id:
              widget.product?.id ??
              'product-${DateTime.now().microsecondsSinceEpoch}',
          name: _name.text.trim(),
          category: category.isEmpty ? null : category,
          price: parseAmount(_price.text) ?? 0,
          description: description.isEmpty ? null : description,
          imageBytes: _shownImage,
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final product = widget.product;
    if (product == null) {
      return;
    }
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete ${product.name}?',
      message: 'This removes it from the price list. Bills already made keep their items and prices.',
      confirmLabel: 'Delete product',
      destructive: true,
    );
    if (confirmed && mounted) {
      Navigator.pop(context, ProductFormDeleted(product.id));
    }
  }
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({
    required this.bytes,
    required this.busy,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? bytes;
  final bool busy;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              bytes!,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppButton(
              label: bytes == null ? 'Add photo' : 'Change photo',
              icon: Icons.photo_outlined,
              variant: AppButtonVariant.secondary,
              onPressed: busy ? null : onPick,
            ),
            if (onRemove != null)
              AppButton(
                label: 'Remove photo',
                variant: AppButtonVariant.secondary,
                onPressed: busy ? null : onRemove,
              ),
          ],
        ),
      ],
    );
  }
}
