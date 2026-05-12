import 'package:flutter/material.dart';

class CollapsibleLogicPanel extends StatelessWidget {
  const CollapsibleLogicPanel({super.key, required this.advice});

  final Map<String, String> advice;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      Padding(
        padding: const .only(left: 16.0, right: 16.0, bottom: 16.0),
        child: Text(
          advice['rule']!,
          style: const TextStyle(
            fontSize: 13,
            fontStyle: .italic,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ),
    ];

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: _SystemExpansionTile(mainContent: mainContent),
    );
  }
}

class _SystemExpansionTile extends StatelessWidget {
  const _SystemExpansionTile({required this.mainContent});

  final List<Padding> mainContent;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      collapsedBackgroundColor: Colors.blueGrey.shade50,
      backgroundColor: Colors.blueGrey.shade50,
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      collapsedShape: RoundedRectangleBorder(borderRadius: .circular(12)),
      leading: const Icon(Icons.psychology, color: Colors.blueGrey),
      title: const Text(
        "View System Inference Logic",
        style: TextStyle(
          fontSize: 14,
          fontWeight: .bold,
          color: Colors.blueGrey,
        ),
      ),
      children: mainContent,
    );
  }
}
