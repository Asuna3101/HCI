import 'package:flutter/material.dart';
import 'package:mimedicapp/models/status.dart';

class StatusBadge extends StatelessWidget {
  final Status status;
  final bool compact;
  final VoidCallback? onTap;
  const StatusBadge({super.key, required this.status, this.compact = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = status.color(context);
    final child = Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        border: Border.all(color: c, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: compact ? 12 : 13),
      ),
    );

    if (onTap == null) return child;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap, child: child),
    );
  }
}
