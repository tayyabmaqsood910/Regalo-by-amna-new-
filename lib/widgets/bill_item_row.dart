import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regalo_by_amna/models/bill_item.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';
import 'package:regalo_by_amna/utils/format.dart';
import 'package:regalo_by_amna/widgets/synced_text_field.dart';

class BillItemRow extends StatelessWidget {
  const BillItemRow({
    super.key,
    required this.item,
    required this.symbol,
    required this.onQuantity,
    required this.onUnitPrice,
    required this.onDiscount,
    required this.onRemove,
  });

  final BillItem item;
  final String symbol;
  final ValueChanged<int> onQuantity;
  final ValueChanged<double> onUnitPrice;
  final ValueChanged<double> onDiscount;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Remove ${item.name}',
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.muted,
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _QuantityStepper(quantity: item.quantity, onChanged: onQuantity),
              const SizedBox(width: 8),
              Expanded(
                child: MoneyField(
                  key: ValueKey('${item.id}-price'),
                  value: item.unitPrice,
                  label: 'Price',
                  onChanged: onUnitPrice,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MoneyField(
                  key: ValueKey('${item.id}-discount'),
                  value: item.discount,
                  label: 'Discount',
                  onChanged: onDiscount,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              formatMoney(item.lineTotal, symbol: symbol),
              key: ValueKey('line-total-${item.id}'),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: AppColors.forest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatefulWidget {
  const _QuantityStepper({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  State<_QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<_QuantityStepper> {
  late final TextEditingController _controller;
  late final FocusNode _focus;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.quantity}');
    _focus = FocusNode()..addListener(_onFocus);
  }

  @override
  void didUpdateWidget(_QuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = '${widget.quantity}';
    if (!_focus.hasFocus && text != _controller.text) {
      _controller.text = text;
      _error = null;
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (_focus.hasFocus || !mounted) {
      return;
    }
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null || parsed < 1) {
      _controller.text = '${widget.quantity}';
      setState(() => _error = null);
      return;
    }
    _controller.text = '$parsed';
  }

  void _commit(String raw) {
    final parsed = int.tryParse(raw.trim());
    if (parsed == null || parsed < 1) {
      setState(() => _error = 'Min 1');
      return;
    }
    setState(() => _error = null);
    if (parsed != widget.quantity) {
      widget.onChanged(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Qty', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Row(
            children: [
              _StepButton(
                icon: Icons.remove,
                tooltip: 'Decrease quantity',
                onPressed: widget.quantity > 1
                    ? () => widget.onChanged(widget.quantity - 1)
                    : null,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: _commit,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              _StepButton(
                icon: Icons.add,
                tooltip: 'Increase quantity',
                onPressed: () => widget.onChanged(widget.quantity + 1),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.danger, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      visualDensity: VisualDensity.compact,
      color: AppColors.forest,
    );
  }
}
