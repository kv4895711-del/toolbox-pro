import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
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
        ..strokeWidth = 18
        ..color = cols[i];
      canvas.drawArc(rect, a0 + 0.015, sweep - 0.03, false, p);
    }
    final t = (bmi.clamp(10.0, 40.0).toDouble() - 10) / 30;
    final ang = math.pi + t * math.pi;
    final tip = Offset(
      c.dx + (r - 26) * math.cos(ang),
      c.dy + (r - 26) * math.sin(ang),
    );
    canvas.drawLine(
      c,
      tip,
      Paint()
        ..color = needle
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
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

  Widget sliderCard(AppState s, String label, String value, Widget slider) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 15, color: s.subText)),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: s.text,
                ),
              ),
            ],
          ),
          slider,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final hm = h / 100;
    final lo = 18.5 * hm * hm;
    final hi = 24.9 * hm * hm;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        FadeSlide(
          child: GlassCard(
            radius: 28,
            child: Column(
              children: [
                SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 10.0, end: bmi),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => CustomPaint(
                      painter: GaugePainter(v, s.text),
                    ),
                  ),
                ),
                AnimNum(
                  value: bmi,
                  decimals: 1,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: s.text,
                  ),
                ),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: catColor,
                  ),
                  child: Text(cat),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeSlide(
          delay: 100,
          child: sliderCard(
            s,
            'Height',
            '${h.round()} cm',
            CupertinoSlider(
              value: h,
              min: 120.0,
              max: 220.0,
              activeColor: s.theme.accent,
              onChanged: (v) => setState(() => h = v),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeSlide(
          delay: 180,
          child: sliderCard(
            s,
            'Weight',
            '${w.round()} kg',
            CupertinoSlider(
              value: w,
              min: 30.0,
              max: 200.0,
              activeColor: s.theme.accent,
              onChanged: (v) => setState(() => w = v),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeSlide(
          delay: 260,
          child: GlassCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Healthy weight for your height',
                    style: TextStyle(fontSize: 14, color: s.subText),
                  ),
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
          ),
        ),
      ],
    );
  }
}
