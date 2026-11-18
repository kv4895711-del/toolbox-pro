import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import '../app_state.dart';
import '../ui_kit.dart';

class GaugePainter extends CustomPainter {
  final double bmi;
  final Color needle;
  GaugePainter(this.bmi, this.needle);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height - 10);
    final r = math.min(size.width / 2 - 16, size.height - 30);
    final rect = Rect.fromCircle(center: c, radius: r);
    const stops = [10.0, 18.5, 25.0, 30.0, 40.0];
    const cols = [
      Color(0xFF4DA3FF),
      Color(0xFF2EE6A8),
      Color(0xFFFFB020),
      Color(0xFFFF4D5E),
    ];
    for (var i = 0; i < 4; i++) {
      final a0 = math.pi + (stops[i] - 10) / 30 * math.pi;
      final sweep = (stops[i + 1] - stops[i]) / 30 * math.pi;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..color = cols[i];
      canvas.drawArc(rect, a0 + 0.015, sweep - 0.03, false, p);
    }
    final t = (bmi.clamp(10.0, 40.0).toDouble() - 10) / 30;
    final ang = math.pi + t * math.pi;
    final tip = Offset(
      c.dx + (r - 28) * math.cos(ang),
      c.dy + (r - 28) * math.sin(ang),
    );
    final line = Paint()
      ..color = needle
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c, tip, line);
    canvas.drawCircle(c, 9, Paint()..color = needle);
  }

  @override
  bool shouldRepaint(GaugePainter old) =>
      old.bmi != bmi || old.needle != needle;
}

class BmiTool extends StatefulWidget {
  const BmiTool({super.key});

  @override
  State<BmiTool> createState() => _BmiToolState();
}

class _BmiToolState extends State<BmiTool> {
  double h = 170;
  double w = 65;

  double get bmi => w / ((h / 100) * (h / 100));

  String get cat {
    final b = bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25) return 'Normal';
    if (b < 30) return 'Overweight';
    return 'Obese';
  }

  Color get catColor {
    final b = bmi;
    if (b < 18.5) return const Color(0xFF4DA3FF);
    if (b < 25) return const Color(0xFF2EE6A8);
    if (b < 30) return const Color(0xFFFFB020);
    return const Color(0xFFFF4D5E);
  }

  Widget hero(AppState s) {
    return GlassCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        children: [
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 10.0, end: bmi),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => SizedBox.expand(
                child: CustomPaint(painter: GaugePainter(v, s.text)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Your BMI', style: TextStyle(fontSize: 14, color: s.subText)),
          AnimNum(
            value: bmi,
            decimals: 1,
            style: TextStyle(
              fontSize: 58,
              fontWeight: FontWeight.w800,
              color: s.text,
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: catColor,
            ),
            child: Text(cat),
          ),
        ],
      ),
    );
  }

  Widget stepper(
    AppState s,
    String label,
    double v,
    String unit,
    double min,
    double max,
    ValueChanged<double> set,
  ) {
    return Expanded(
      child: GlassCard(
        radius: 26,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: s.subText)),
            const SizedBox(height: 4),
            AnimNum(
              value: v,
              suffix: ' $unit',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: s.text,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: KeyCap(
                      radius: 21,
                      color: s.glass,
                      onTap: () => set((v - 1).clamp(min, max).toDouble()),
                      child: Icon(Icons.remove, color: s.text),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: KeyCap(
                      radius: 21,
                      color: s.theme.accent,
                      onTap: () => set((v + 1).clamp(min, max).toDouble()),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            CupertinoSlider(
              value: v,
              min: min,
              max: max,
              activeColor: s.theme.accent,
              onChanged: (x) => set(x.roundToDouble()),
            ),
          ],
        ),
      ),
    );
  }

  Widget rangeCard(AppState s) {
    final hm = h / 100;
    final lo = 18.5 * hm * hm;
    final hi = 24.9 * hm * hm;
    final String tip;
    if (w < lo) {
      tip = '+${(lo - w).toStringAsFixed(1)} kg to reach healthy range';
    } else if (w > hi) {
      tip = '−${(w - hi).toStringAsFixed(1)} kg to reach healthy range';
    } else {
      tip = 'Aap healthy range mein ho 🎉';
    }
    final frac = ((w - 30) / 130).clamp(0.0, 1.0).toDouble();
    int fl(double x) => math.max(1, (x * 10).round());
    return GlassCard(
      radius: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Healthy weight range',
                style: TextStyle(fontSize: 14, color: s.subText),
              ),
              Text(
                '${lo.toStringAsFixed(1)} – ${hi.toStringAsFixed(1)} kg',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: s.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 22,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: fl(lo - 30),
                        child: Container(
                          height: 12,
                          color: const Color(0xFF4DA3FF),
                        ),
                      ),
                      Expanded(
                        flex: fl(hi - lo),
                        child: Container(
                          height: 12,
                          color: const Color(0xFF2EE6A8),
                        ),
                      ),
                      Expanded(
                        flex: fl(160 - hi),
                        child: Container(
                          height: 12,
                          color: const Color(0xFFFFB020),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment(2 * frac - 1, 0),
                  child: Container(
                    width: 8,
                    height: 22,
                    decoration: BoxDecoration(
                      color: s.text,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(tip, style: TextStyle(fontSize: 14, color: s.subText)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
      child: Column(
        children: [
          Expanded(child: FadeSlide(child: hero(s))),
          const SizedBox(height: 12),
          FadeSlide(
            delay: 100,
            child: Row(
              children: [
                stepper(s, 'Height', h, 'cm', 120, 220,
                    (v) => setState(() => h = v)),
                const SizedBox(width: 12),
                stepper(s, 'Weight', w, 'kg', 30, 200,
                    (v) => setState(() => w = v)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FadeSlide(delay: 180, child: rangeCard(s)),
        ],
      ),
    );
  }
}
