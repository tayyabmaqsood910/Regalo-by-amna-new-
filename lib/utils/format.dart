String formatEditableAmount(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}

double? parseAmount(String raw) {
  final cleaned = raw
      .trim()
      .replaceAll(',', '')
      .replaceAll('Rs.', '')
      .replaceAll('Rs', '')
      .trim();
  if (cleaned.isEmpty) {
    return null;
  }
  return double.tryParse(cleaned);
}

String formatMoney(double amount, {String symbol = 'Rs.'}) {
  final negative = amount.isNegative;
  final parts = amount.abs().toStringAsFixed(2).split('.');
  final whole = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    final remaining = whole.length - i;
    if (i > 0 && remaining % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(whole[i]);
  }
  final sign = negative ? '-' : '';
  return '$sign$symbol ${buffer.toString()}.${parts[1]}';
}

String formatDateTime(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour24 = date.hour;
  final hour = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = hour24 >= 12 ? 'PM' : 'AM';
  return '${date.day} ${months[date.month - 1]} ${date.year} · $hour:$minute $period';
}

const invoiceDatePatterns = <String, String>{
  'd MMM yyyy': '20 Oct 2026 · 1:15 PM',
  'dd/MM/yyyy': '20/10/2026 13:15',
  'MMMM d, yyyy': 'October 20, 2026',
};

String formatInvoiceDate(DateTime date, String pattern) {
  const longMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  return switch (pattern) {
    'dd/MM/yyyy' => '$day/$month/${date.year} $hour:$minute',
    'MMMM d, yyyy' => '${longMonths[date.month - 1]} ${date.day}, ${date.year}',
    _ => formatDateTime(date),
  };
}
