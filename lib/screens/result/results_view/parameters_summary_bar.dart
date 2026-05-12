import 'package:flutter/material.dart';
import '../param_chip.dart';
import '../result_screen/result_screen.dart';

class ParametersSummaryBar extends StatelessWidget {
  const ParametersSummaryBar({super.key, required this.widget});

  final ResultScreen widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: .circular(12),
        border: .all(color: Colors.blueGrey.shade100),
      ),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          ParamChip(icon: Icons.calendar_month, label: "${widget.age} DAT"),
          ParamChip(icon: Icons.scale, label: "${widget.yield} T/Ha"),
          ParamChip(icon: Icons.map, label: "${widget.area} Ha"),
        ],
      ),
    );
  }
}
