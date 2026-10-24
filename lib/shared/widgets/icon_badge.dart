import 'package:flutter/material.dart';

class IconBadge extends StatelessWidget {
  final IconData icon;
  final double size;

  const IconBadge({super.key, required this.icon, this.size = 46});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: cs.onPrimaryContainer, size: size * 0.52),
    );
  }
}
