import 'package:flutter/cupertino.dart';
import 'app_state.dart';
import 'ui_kit.dart';

class RoundBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;
  const RoundBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Opacity(
      opacity: onTap == null ? 0.4 : 1.0,
      child: Column(
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child: KeyCap(
              radius: 39,
              color: bg,
              onTap: onTap ?? () {},
              child: Icon(icon, size: 34, color: fg),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 13, color: s.subText)),
        ],
      ),
    );
  }
}
