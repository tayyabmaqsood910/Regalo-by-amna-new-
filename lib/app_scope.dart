import 'package:flutter/material.dart';
import 'package:regalo_by_amna/services/demo_store.dart';

class AppScope extends InheritedNotifier<DemoStore> {
  const AppScope({super.key, required DemoStore store, required super.child})
    : super(notifier: store);

  static DemoStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope was not found above this widget.');
    return scope!.notifier!;
  }
}
