import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:regalo_by_amna/utils/format.dart';

class SyncedTextField extends StatefulWidget {
  const SyncedTextField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? label;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<SyncedTextField> createState() => _SyncedTextFieldState();
}

class _SyncedTextFieldState extends State<SyncedTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focus = FocusNode()..addListener(_onFocus);
  }

  @override
  void didUpdateWidget(SyncedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (!_focus.hasFocus && mounted && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focus,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        isDense: true,
      ),
    );
  }
}

class MoneyField extends StatefulWidget {
  const MoneyField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String label;

  @override
  State<MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<MoneyField> {
  late final TextEditingController _controller;
  late final FocusNode _focus;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: formatEditableAmount(widget.value),
    );
    _focus = FocusNode()..addListener(_onFocus);
  }

  @override
  void didUpdateWidget(MoneyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = formatEditableAmount(widget.value);
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
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      widget.onChanged(0);
      _controller.text = '0';
      setState(() => _error = null);
      return;
    }
    final parsed = parseAmount(raw);
    if (parsed == null || parsed < 0) {
      setState(() => _error = 'Enter 0 or more');
      return;
    }
    _controller.text = formatEditableAmount(parsed);
    setState(() => _error = null);
  }

  void _commit(String raw) {
    final parsed = parseAmount(raw);
    if (raw.trim().isEmpty) {
      setState(() => _error = null);
      return;
    }
    if (parsed == null || parsed < 0) {
      setState(() => _error = 'Enter 0 or more');
      return;
    }
    setState(() => _error = null);
    if (parsed != widget.value) {
      widget.onChanged(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: _commit,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: _error,
        isDense: true,
      ),
    );
  }
}
