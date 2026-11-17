import 'package:flutter/cupertino.dart';
import '../app_state.dart';
import '../ui_kit.dart';
import 'calc_engine.dart';

class PercentageTool extends StatefulWidget {
  const PercentageTool({super.key});

  @override
  State<PercentageTool> createState() => _PercentageToolState();
}

class _PercentageToolState extends State<PercentageTool> {
  int mode = 0;
  final a = TextEditingController();
  final b = TextEditingController();

  static const modes = ['X% of Y', 'X is ?% of Y', '% change'];
  static const labels = [
    ['Percent', 'Of'],
    ['Value', 'Total'],
    ['From', 'To'],
  ];

  @override
  void dispose() {
    a.dispose();
    b.dispose();
    super.dispose();
  }

  double? get result {
    final x = double.tryParse(a.text.trim());
    final y = double.tryParse(b.text.trim());
    if (x == null || y == null) return null;
    switch (mode) {
      case 0:
        return x / 100 * y;
      case 1:
        return y == 0 ? null : x / y * 100;
      default:
        return x == 0 ? null : (y - x) / x * 100;
    }
  }

  String get sentence {
    final x = fmtNum(double.tryParse(a.text.trim()) ?? 0);
    final y = fmtNum(double.tryParse(b.text.trim()) ?? 0);
    final r = fmtNum(result ?? 0);
    if (mode == 0) return '$x% of $y = $r';
    if (mode == 1) return '$x is $r% of $y';
    final up = (result ?? 0) >= 0 ? 'increase' : 'decrease';
    return '$x to $y is a $r% $up';
  }

  Widget resultCard(AppState s) {
    final r = result;
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.all(22),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Result', style: TextStyle(fontSize: 14, color: s.subText)),
            const SizedBox(height: 6),
            r == null
                ? Text(
                    '—',
                    style: TextStyle(fontSize: 54, color: s.subText),
                  )
                : AnimNum(
                    value: r,
                    decimals: 2,
                    suffix: mode == 0 ? '' : '%',
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w700,
                      color: s.theme.accent,
                    ),
                  ),
            if (mode == 1 && r != null) ...[
              const SizedBox(height: 14),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: (r / 100).clamp(0.0, 1.0).toDouble()),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Container(
                  height: 10,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: s.glass,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: v,
                    child: Container(
                      decoration: BoxDecoration(
                        color: s.theme.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (r != null) ...[
              const SizedBox(height: 14),
              Text(sentence, style: TextStyle(fontSize: 15, color: s.subText)),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        FadeSlide(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < 3; i++)
                Pill(
                  label: modes[i],
                  on: mode == i,
                  onTap: () => setState(() => mode = i),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FadeSlide(
          delay: 80,
          child: NumField(
            label: labels[mode][0],
            suffix: mode == 0 ? '%' : '',
            controller: a,
            onChanged: () => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        FadeSlide(
          delay: 160,
          child: NumField(
            label: labels[mode][1],
            controller: b,
            onChanged: () => setState(() {}),
          ),
        ),
        const SizedBox(height: 18),
        FadeSlide(delay: 240, child: resultCard(s)),
      ],
    );
  }
}
