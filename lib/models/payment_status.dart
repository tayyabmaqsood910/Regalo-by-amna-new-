enum PaymentStatus {
  paid('Paid'),
  partial('Partial'),
  unpaid('Unpaid');

  const PaymentStatus(this.label);

  final String label;
}
