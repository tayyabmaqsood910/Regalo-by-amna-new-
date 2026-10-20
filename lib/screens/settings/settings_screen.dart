import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:regalo_by_amna/app_scope.dart';
import 'package:regalo_by_amna/services/shop_backup.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';
import 'package:regalo_by_amna/utils/format.dart';
import 'package:regalo_by_amna/widgets/confirm_dialog.dart';
import 'package:regalo_by_amna/widgets/page_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onCustomize});

  final VoidCallback onCustomize;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final settings = store.settings;

    return PageBody(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              title: 'Settings',
              subtitle: 'Shop details, backups, and this session stay on this device.',
            ),
            const SizedBox(height: 20),
            _Group(
              title: 'Invoice',
              children: [
                _Row(
                  icon: Icons.brush_outlined,
                  tint: AppColors.blush,
                  title: 'Customize invoice',
                  titleKey: const Key('open-invoice-customization'),
                  detail:
                      'Shop name, logo, colors, and the 58 mm, 80 mm, and A4 preview.',
                  onTap: onCustomize,
                ),
                _Row(
                  icon: Icons.storefront_outlined,
                  tint: AppColors.sageLight,
                  title: settings.shopName,
                  titleKey: const Key('open-shop-profile'),
                  detail:
                      '${settings.address}\n${settings.phone}  ·  ${settings.email}\n${settings.currencyCode} (${settings.currencySymbol})',
                  onTap: onCustomize,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Group(
              title: 'Backup',
              children: [
                _Row(
                  icon: Icons.file_upload_outlined,
                  tint: AppColors.sageLight,
                  title: 'Export backup',
                  titleKey: const Key('export-backup'),
                  detail: 'Save products, bills, and invoice settings to a file.',
                  onTap: () => _export(context),
                ),
                _Row(
                  icon: Icons.file_download_outlined,
                  tint: AppColors.sageLight,
                  title: 'Import backup',
                  titleKey: const Key('import-backup'),
                  detail: 'Replace this session with a Regalo backup file.',
                  onTap: () => _import(context),
                ),
                _Row(
                  icon: Icons.restart_alt,
                  tint: const Color(0xFFF6D6D6),
                  iconColor: AppColors.danger,
                  title: 'Factory reset',
                  titleKey: const Key('factory-reset'),
                  detail:
                      'Clear every bill and restore the original flowers and invoice settings.',
                  onTap: () => _factoryReset(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Group(
              title: 'This session',
              children: [
                _Row(
                  icon: Icons.receipt_long_outlined,
                  tint: AppColors.sageLight,
                  title: '${store.billCount} bills',
                  titleKey: const Key('settings-bill-count'),
                  detail: formatMoney(
                    store.totalSales,
                    symbol: settings.currencySymbol,
                  ),
                  detailKey: const Key('settings-sales'),
                ),
                _Row(
                  icon: Icons.delete_outline,
                  tint: const Color(0xFFF6D6D6),
                  iconColor: AppColors.danger,
                  title: 'Clear session bills',
                  titleKey: const Key('clear-session'),
                  detail: 'Remove the bills saved in this session.',
                  enabled: store.billCount > 0,
                  onTap: store.billCount == 0 ? null : () => _clear(context),
                ),
                _Row(
                  icon: Icons.history,
                  tint: AppColors.sageLight,
                  title: 'Restore sample bills',
                  titleKey: const Key('restore-session'),
                  detail: 'Put the original sample invoices back.',
                  onTap: () => _restore(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    final store = AppScope.of(context);
    final bytes = Uint8List.fromList(utf8.encode(store.exportBackup()));
    final location = await getSaveLocation(
      suggestedName: 'regalo-backup.json',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'JSON', extensions: ['json']),
      ],
    );
    if (location == null || !context.mounted) {
      return;
    }
    try {
      await XFile.fromData(
        bytes,
        mimeType: 'application/json',
        name: 'regalo-backup.json',
      ).saveTo(location.path);
      if (!context.mounted) {
        return;
      }
      _message(context, 'Backup saved.');
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      _message(context, 'The backup could not be saved. $error');
    }
  }

  Future<void> _import(BuildContext context) async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'JSON', extensions: ['json']),
      ],
    );
    if (file == null || !context.mounted) {
      return;
    }
    final ShopSnapshot snapshot;
    try {
      snapshot = ShopBackup.decode(await file.readAsString());
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      _message(context, 'That file could not be imported. $error');
      return;
    }
    if (!context.mounted) {
      return;
    }
    final confirmed = await showConfirmDialog(
      context,
      title: 'Import this backup?',
      message:
          'This replaces the current products, invoice settings, open bill, and saved bills.',
      confirmLabel: 'Import backup',
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    AppScope.of(context).applySnapshot(snapshot);
    _message(context, 'Backup imported.');
  }

  Future<void> _factoryReset(BuildContext context) async {
    final store = AppScope.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: 'Reset to factory settings?',
      message:
          'This clears every bill and the open sale, then restores the original flower list and invoice settings.',
      confirmLabel: 'Factory reset',
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    store.factoryReset();
    _message(
      context,
      'Reset complete. Bills were cleared and the original shop was restored.',
    );
  }

  Future<void> _clear(BuildContext context) async {
    final store = AppScope.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: 'Clear this session?',
      message:
          'This removes the bills saved in the current session from the dashboard and bill history.',
      confirmLabel: 'Clear bills',
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    store.clearSessionBills();
    _message(context, 'Session bills cleared.');
  }

  Future<void> _restore(BuildContext context) async {
    final store = AppScope.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: 'Restore sample bills?',
      message:
          'This replaces the current session with the sample flower-shop bills.',
      confirmLabel: 'Restore bills',
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    store.restoreSampleBills();
    _message(context, 'Sample bills restored.');
  }

  void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: AppColors.line),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.tint,
    required this.title,
    required this.detail,
    this.titleKey,
    this.detailKey,
    this.onTap,
    this.enabled = true,
    this.iconColor = AppColors.forest,
  });

  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String title;
  final String detail;
  final Key? titleKey;
  final Key? detailKey;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  key: titleKey,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: enabled ? AppColors.ink : AppColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  key: detailKey,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.chevron_right, color: AppColors.muted),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: content,
      ),
    );
  }
}
