import 'package:flutter/material.dart';

class FinanceRow extends StatelessWidget {
  const FinanceRow({
    super.key,
    required this.label,
    required this.amount,
    required this.amountColor,
    this.isBold = false,
  });

  final String label;
  final String amount;
  final Color amountColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? .bold : .normal,
            color: isBold ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: .bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
