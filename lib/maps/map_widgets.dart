import 'package:flutter/cupertino.dart';
import '../app_state.dart';

class MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool on;
  const MapBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.on = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 48,
        child: GlassCard(
          blur: true,
          radius: 24,
          padding: EdgeInsets.zero,
          child: Center(
            child: Icon(icon, size: 22, color: on ? s.theme.accent : s.text),
          ),
        ),
      ),
    );
  }
}

class MeDot extends StatelessWidget {
  const MeDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A84FF),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFFFFF), width: 3),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 6)],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final VoidCallback? onClose;
  const InfoCard({super.key, required this.text, this.onClose});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return GlassCard(
      blur: true,
      radius: 22,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: s.text),
            ),
          ),
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              child: Icon(CupertinoIcons.xmark_circle_fill, color: s.subText),
            ),
        ],
      ),
    );
  }
}

class ResultsCard extends StatelessWidget {
  final List<String> names;
  final ValueChanged<int> onPick;
  const ResultsCard({super.key, required this.names, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return GlassCard(
      blur: true,
      radius: 22,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < names.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onPick(i),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.location, size: 18, color: s.subText),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        names[i],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: s.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
