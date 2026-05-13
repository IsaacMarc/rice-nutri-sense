import 'package:flutter/material.dart';

class FormattedText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;

  const FormattedText({super.key, required this.text, this.baseStyle});

  @override
  Widget build(BuildContext context) {
    // Fallback to the theme's body medium style if none is provided
    final defaultStyle = baseStyle ?? Theme.of(context).textTheme.bodyMedium!;
    final boldStyle = defaultStyle.copyWith(fontWeight: .bold);

    final List<TextSpan> spans = [];
    // This regex looks for text wrapped in ** **
    final RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    int start = 0;

    for (final Match match in exp.allMatches(text)) {
      // Add standard text before the bold match
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: defaultStyle,
          ),
        );
      }
      // Add the matched text (without the ** asterisks) with bold style
      spans.add(TextSpan(text: match.group(1), style: boldStyle));
      start = match.end;
    }

    // Add any remaining trailing text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: defaultStyle));
    }

    return RichText(text: TextSpan(children: spans));
  }
}
