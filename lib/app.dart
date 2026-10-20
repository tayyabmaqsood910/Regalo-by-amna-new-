import 'package:flutter/material.dart';
import 'package:regalo_by_amna/app_scope.dart';
import 'package:regalo_by_amna/screens/shell/app_shell.dart';
import 'package:regalo_by_amna/services/demo_store.dart';
import 'package:regalo_by_amna/theme/app_theme.dart';

class RegaloApp extends StatefulWidget {
  const RegaloApp({super.key, this.store});

  final DemoStore? store;

  @override
  State<RegaloApp> createState() => _RegaloAppState();
}

class _RegaloAppState extends State<RegaloApp> {
  late final DemoStore _store;
  late final bool _ownsStore;

  @override
  void initState() {
    super.initState();
    _ownsStore = widget.store == null;
    _store = widget.store ?? DemoStore();
  }

  @override
  void dispose() {
    if (_ownsStore) {
      _store.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: _store,
      child: MaterialApp(
        title: 'Regalo by Amna',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AppShell(),
      ),
    );
  }
}
