import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final TextAlign textAlign;
  final double bottomSpacing;

  const SectionHeader({
    super.key,
    required this.title,
    this.textAlign = TextAlign.center,
    this.bottomSpacing = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: textAlign,
        ),
        const SizedBox(height: 16),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: bottomSpacing),
      ],
    );
  }
}
