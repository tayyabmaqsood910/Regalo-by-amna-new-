import 'package:flutter_test/flutter_test.dart';
import 'package:regalo_by_amna/utils/format.dart';

void main() {
  test('formats PKR with thousands separators', () {
    expect(formatMoney(0), 'Rs. 0.00');
    expect(formatMoney(999), 'Rs. 999.00');
    expect(formatMoney(1500.5), 'Rs. 1,500.50');
    expect(formatMoney(33400), 'Rs. 33,400.00');
    expect(formatMoney(1000000), 'Rs. 1,000,000.00');
    expect(formatMoney(-50), '-Rs. 50.00');
  });

  test('reads typed amounts', () {
    expect(parseAmount(''), isNull);
    expect(parseAmount('Rs. 1,500.50'), 1500.5);
    expect(parseAmount('-5'), -5);
    expect(formatEditableAmount(15), '15');
    expect(formatEditableAmount(15.5), '15.50');
  });

  test('formats the bill date and time', () {
    expect(
      formatDateTime(DateTime(2026, 10, 20, 14, 5)),
      '20 Oct 2026 · 2:05 PM',
    );
    expect(
      formatDateTime(DateTime(2026, 10, 20, 0, 5)),
      '20 Oct 2026 · 12:05 AM',
    );
    expect(
      formatDateTime(DateTime(2026, 1, 1, 12, 0)),
      '1 Jan 2026 · 12:00 PM',
    );
  });
}
