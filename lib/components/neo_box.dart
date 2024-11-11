import 'package:flutter/material.dart';

class NeoBox extends StatelessWidget {
  final Widget? child;
  const NeoBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            offset: const Offset(4, 4),
            blurRadius: 15,
          ),
          BoxShadow(
            color:
                Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
            offset: const Offset(-4, -4),
            blurRadius: 15,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}
