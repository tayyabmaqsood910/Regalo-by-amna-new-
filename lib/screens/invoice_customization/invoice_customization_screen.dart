import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:regalo_by_amna/app_scope.dart';
import 'package:regalo_by_amna/models/invoice_settings.dart';
import 'package:regalo_by_amna/services/demo_store.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';
import 'package:regalo_by_amna/utils/format.dart';
import 'package:regalo_by_amna/widgets/app_button.dart';
import 'package:regalo_by_amna/widgets/app_card.dart';
import 'package:regalo_by_amna/widgets/invoice_preview.dart';
import 'package:regalo_by_amna/widgets/page_header.dart';
import 'package:regalo_by_amna/widgets/synced_text_field.dart';

class InvoiceCustomizationScreen extends StatefulWidget {
  const InvoiceCustomizationScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<InvoiceCustomizationScreen> createState() =>
      _InvoiceCustomizationScreenState();
}

class _InvoiceCustomizationScreenState
    extends State<InvoiceCustomizationScreen> {
  InvoicePaper _paper = InvoicePaper.a4;
  var _pickingLogo = false;
  var _showMore = false;

  void _update(InvoiceSettings next) {
    AppScope.of(context).updateSettings(next);
  }

  Future<void> _pickLogo(DemoStore store) async {
    setState(() => _pickingLogo = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 75,
      );
      if (file == null || !mounted) {
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) {
        return;
      }
      _update(store.settings.copyWith(logoBytes: bytes));
    } finally {
      if (mounted) {
        setState(() => _pickingLogo = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final settings = store.settings;

    return PageBody(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.onBack != null) ...[
              TextButton.icon(
                key: const Key('back-to-settings'),
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Settings'),
              ),
              const SizedBox(height: 8),
            ],
            const PageHeader(
              title: 'Invoice',
              subtitle: 'Change the shop details. The preview updates as you type.',
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final form = _SettingsForm(
                  settings: settings,
                  pickingLogo: _pickingLogo,
                  showMore: _showMore,
                  onShowMore: () => setState(() => _showMore = !_showMore),
                  onChanged: _update,
                  onPickLogo: () => _pickLogo(store),
                  onClearLogo: () =>
                      _update(settings.copyWith(clearLogo: true)),
                );
                final preview = _PreviewPanel(
                  settings: settings,
                  paper: _paper,
                  onPaper: (paper) => setState(() => _paper = paper),
                );
                if (constraints.maxWidth < 860) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      form,
                      const SizedBox(height: 20),
                      preview,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: form),
                    const SizedBox(width: 20),
                    Expanded(flex: 5, child: preview),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsForm extends StatelessWidget {
  const _SettingsForm({
    required this.settings,
    required this.pickingLogo,
    required this.showMore,
    required this.onShowMore,
    required this.onChanged,
    required this.onPickLogo,
    required this.onClearLogo,
  });

  final InvoiceSettings settings;
  final bool pickingLogo;
  final bool showMore;
  final VoidCallback onShowMore;
  final ValueChanged<InvoiceSettings> onChanged;
  final VoidCallback onPickLogo;
  final VoidCallback onClearLogo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(
          title: 'Your shop',
          child: Column(
            children: [
              _field(
                key: const Key('invoice-shop-name'),
                label: 'Shop name',
                value: settings.shopName,
                onChanged: (value) =>
                    onChanged(settings.copyWith(shopName: value)),
              ),
              const SizedBox(height: 12),
              _field(
                key: const Key('invoice-phone'),
                label: 'Phone',
                value: settings.phone,
                onChanged: (value) => onChanged(settings.copyWith(phone: value)),
              ),
              const SizedBox(height: 12),
              _field(
                key: const Key('invoice-address'),
                label: 'Address',
                value: settings.address,
                maxLines: 2,
                onChanged: (value) =>
                    onChanged(settings.copyWith(address: value)),
              ),
              const SizedBox(height: 12),
              _LogoRow(
                bytes: settings.logoBytes,
                busy: pickingLogo,
                onPick: onPickLogo,
                onClear: settings.logoBytes == null ? null : onClearLogo,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const Key('invoice-more'),
            onPressed: onShowMore,
            icon: Icon(showMore ? Icons.expand_less : Icons.tune),
            label: Text(showMore ? 'Hide extra options' : 'More options'),
          ),
        ),
        if (showMore) ...[
        const SizedBox(height: 8),
        _Section(
          title: 'Invoice text',
          child: Column(
            children: [
              _field(
                key: const Key('invoice-email'),
                label: 'Email',
                value: settings.email,
                onChanged: (value) => onChanged(settings.copyWith(email: value)),
              ),
              const SizedBox(height: 12),
              _field(
                key: const Key('invoice-title'),
                label: 'Invoice title',
                value: settings.invoiceTitle,
                onChanged: (value) =>
                    onChanged(settings.copyWith(invoiceTitle: value)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      key: const Key('invoice-prefix'),
                      label: 'Number prefix',
                      value: settings.numberPrefix,
                      onChanged: (value) =>
                          onChanged(settings.copyWith(numberPrefix: value)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      key: const Key('invoice-next-number'),
                      label: 'Next number',
                      value: '${settings.nextNumber}',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        final number = int.tryParse(value);
                        if (number == null || number < 1) {
                          return;
                        }
                        onChanged(settings.copyWith(nextNumber: number));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Next invoice ${settings.nextInvoiceNumber}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 12),
              _field(
                key: const Key('invoice-thanks'),
                label: 'Thank-you message',
                value: settings.thankYouMessage,
                maxLines: 2,
                onChanged: (value) =>
                    onChanged(settings.copyWith(thankYouMessage: value)),
              ),
              const SizedBox(height: 12),
              _field(
                key: const Key('invoice-footer'),
                label: 'Footer',
                value: settings.footerText,
                onChanged: (value) =>
                    onChanged(settings.copyWith(footerText: value)),
              ),
              const SizedBox(height: 12),
              _field(
                key: const Key('invoice-terms'),
                label: 'Terms and conditions',
                value: settings.terms,
                maxLines: 3,
                onChanged: (value) => onChanged(settings.copyWith(terms: value)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'Currency and date',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _field(
                      key: const Key('invoice-currency'),
                      label: 'Currency',
                      value: settings.currencyCode,
                      onChanged: (value) =>
                          onChanged(settings.copyWith(currencyCode: value)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      key: const Key('invoice-symbol'),
                      label: 'Symbol',
                      value: settings.currencySymbol,
                      onChanged: (value) =>
                          onChanged(settings.copyWith(currencySymbol: value)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('invoice-date-format'),
                initialValue: invoiceDatePatterns.containsKey(settings.dateFormat)
                    ? settings.dateFormat
                    : 'd MMM yyyy',
                decoration: const InputDecoration(
                  labelText: 'Date format',
                  isDense: true,
                ),
                items: [
                  for (final entry in invoiceDatePatterns.entries)
                    DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onChanged(settings.copyWith(dateFormat: value));
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'Show on the invoice',
          child: Column(
            children: [
              _Toggle(
                label: 'Customer information',
                value: settings.showCustomer,
                onChanged: (value) =>
                    onChanged(settings.copyWith(showCustomer: value)),
              ),
              _Toggle(
                label: 'Item discounts',
                value: settings.showItemDiscounts,
                onChanged: (value) =>
                    onChanged(settings.copyWith(showItemDiscounts: value)),
              ),
              _Toggle(
                label: 'Tax',
                value: settings.showTax,
                onChanged: (value) => onChanged(settings.copyWith(showTax: value)),
              ),
              _Toggle(
                label: 'Delivery charges',
                value: settings.showDelivery,
                onChanged: (value) =>
                    onChanged(settings.copyWith(showDelivery: value)),
              ),
              _Toggle(
                label: 'Payment details',
                value: settings.showPayment,
                onChanged: (value) =>
                    onChanged(settings.copyWith(showPayment: value)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'Accent color',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final color in _accentColors)
                _ColorDot(
                  color: color,
                  selected: settings.accentColorValue == color.toARGB32(),
                  onTap: () => onChanged(
                    settings.copyWith(accentColorValue: color.toARGB32()),
                  ),
                ),
            ],
          ),
        ),
        ],
      ],
    );
  }

  Widget _field({
    required Key key,
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return SyncedTextField(
      key: key,
      label: label,
      value: value,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.settings,
    required this.paper,
    required this.onPaper,
  });

  final InvoiceSettings settings;
  final InvoicePaper paper;
  final ValueChanged<InvoicePaper> onPaper;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Preview', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PaperChip(
                key: const Key('layout-58'),
                label: '58 mm',
                selected: paper == InvoicePaper.thermal58,
                onTap: () => onPaper(InvoicePaper.thermal58),
              ),
              _PaperChip(
                key: const Key('layout-80'),
                label: '80 mm',
                selected: paper == InvoicePaper.thermal80,
                onTap: () => onPaper(InvoicePaper.thermal80),
              ),
              _PaperChip(
                key: const Key('layout-a4'),
                label: 'A4',
                selected: paper == InvoicePaper.a4,
                onTap: () => onPaper(InvoicePaper.a4),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ColoredBox(
            color: const Color(0xFFF3EBE3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: InvoicePreview(
                key: const Key('invoice-preview'),
                settings: settings,
                paper: paper,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _LogoRow extends StatelessWidget {
  const _LogoRow({
    required this.bytes,
    required this.busy,
    required this.onPick,
    required this.onClear,
  });

  final Uint8List? bytes;
  final bool busy;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.sageLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 56,
            height: 56,
            child: bytes == null
                ? const Icon(Icons.local_florist, color: AppColors.forest)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(bytes!, fit: BoxFit.cover),
                  ),
          ),
        ),
        AppButton(
          key: const Key('invoice-logo'),
          label: busy ? 'Opening…' : 'Choose logo',
          icon: Icons.image_outlined,
          onPressed: busy ? null : onPick,
        ),
        if (onClear != null)
          AppButton(
            label: 'Remove',
            icon: Icons.close,
            onPressed: onClear,
          ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      key: Key('toggle-${label.toLowerCase().replaceAll(' ', '-')}'),
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: GoogleFonts.outfit(fontSize: 14)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.ink : Colors.transparent,
            width: 2,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}

class _PaperChip extends StatelessWidget {
  const _PaperChip({
    super.key,
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
      onSelected: (_) => onTap(),
      showCheckmark: false,
    );
  }
}

const _accentColors = <Color>[
  Color(0xFF1E3A2F),
  Color(0xFF6B2A3A),
  Color(0xFFB76E78),
  Color(0xFF8A6A3B),
  Color(0xFF24302A),
];
