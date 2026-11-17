import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import '../app_state.dart';
import '../ui_kit.dart';
import 'fmt.dart';

const _orange = Color(0xFFFFB020);

class DonutPainter extends CustomPainter {
  final double frac;
  final Color a;
  final Color b;
  DonutPainter(this.frac, this.a, this.b);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2 - 12;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..color = b,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      frac * 2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round
        ..color = a,
    );
  }

  @override
  bool shouldRepaint(DonutPainter old) =>
      old.frac != frac || old.a != a || old.b != b;
}

class EmiTool extends StatefulWidget {
  const EmiTool({super.key});

  @override
  State<EmiTool> createState() => _EmiToolState();
}

class _EmiToolState extends State<EmiTool> {
  final loan = TextEditingController();
  final rate = TextEditingController();
  final ten = TextEditingController();
  bool years = true;

  @override
  void dispose() {
    loan.dispose();
    rate.dispose();
    ten.dispose();
    super.dispose();
  }

  double val(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;
  double get pr => val(loan);
  double get nm => years ? val(ten) * 12 : val(ten);

  double get emi {
    if (pr <= 0 || nm <= 0) return 0;
    final r = val(rate) / 12 / 100;
    if (r == 0) return pr / nm;
    final f = math.pow(1 + r, nm).toDouble();
    return pr * r * f / (f - 1);
  }

  double get total => emi * nm;
  double get interest => total - pr;

  Widget dot(Color c) => Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );

  Widget miniCard(AppState s, String label, double v) {
    return Expanded(
      child: GlassCard(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: s.subText)),
              const SizedBox(height: 4),
              AnimMoney(
                value: v,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: s.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget donut(AppState s) {
    final frac = total <= 0 ? 0.0 : (pr / total).clamp(0.0, 1.0).toDouble();
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: frac),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => CustomPaint(
                      painter: DonutPainter(v, s.theme.accent, _orange),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Monthly EMI',
                      style: TextStyle(fontSize: 13, color: s.subText),
                    ),
                    AnimMoney(
                      value: emi,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: s.text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              dot(s.theme.accent),
              Text('Principal    ', style: TextStyle(color: s.subText)),
              dot(_orange),
              Text('Interest', style: TextStyle(color: s.subText)),
            ],
          ),
        ],
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
          child: NumField(
            label: 'Loan amount',
            suffix: '₹',
            controller: loan,
            onChanged: () => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        FadeSlide(
          delay: 80,
          child: Row(
            children: [
              Expanded(
                child: NumField(
                  label: 'Interest / year',
                  suffix: '%',
                  controller: rate,
                  onChanged: () => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NumField(
                  label: 'Tenure',
                  controller: ten,
                  onChanged: () => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FadeSlide(
          delay: 140,
          child: Row(
            children: [
              Pill(
                label: 'Years',
                on: years,
                onTap: () => setState(() => years = true),
              ),
              const SizedBox(width: 8),
              Pill(
                label: 'Months',
                on: !years,
                onTap: () => setState(() => years = false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (emi > 0) ...[
          FadeSlide(delay: 200, child: donut(s)),
          const SizedBox(height: 12),
          FadeSlide(
            delay: 260,
            child: Row(
              children: [
                miniCard(s, 'Total interest', interest),
                const SizedBox(width: 12),
                miniCard(s, 'Total payment', total),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
