import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../chrome.dart';
import '../ui_kit.dart';
import 'calc_engine.dart';

class RingPainter extends CustomPainter {
  final double frac;
  final Color a;
  final Color b;
  final Color track;
  RingPainter(this.frac, this.a, this.b, this.track);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2 - 14;
    final rect = Rect.fromCircle(center: c, radius: r);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..color = track;
    canvas.drawCircle(c, r, trackPaint);
    if (frac <= 0) return;
    final sweep = frac * 2 * math.pi;
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26
      ..color = a.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, glow);
    final shader = SweepGradient(
      startAngle: 0.0,
      endAngle: 2 * math.pi,
      colors: [a, b],
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(rect);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..shader = shader;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(RingPainter old) =>
      old.frac != frac || old.a != a || old.b != b || old.track != track;
}

class PercentageTool extends StatefulWidget {
  const PercentageTool({super.key});

  @override
  State<PercentageTool> createState() => _PercentageToolState();
}

class _PercentageToolState extends State<PercentageTool> {
  int mode = 0;
  bool copied = false;
  final a = TextEditingController(text: '15');
  final b = TextEditingController(text: '200');

  static const modes = ['X% of Y', 'X is ?% of Y', '% change'];
  static const labels = [
    ['Percent', 'Of'],
    ['Value', 'Total'],
    ['From', 'To'],
  ];
  static const hints = [
    '',
    'Total ka kitna hissa hai',
    'Increase ya decrease kitna hua',
  ];

  @override
  void dispose() {
    a.dispose();
    b.dispose();
    super.dispose();
  }

  double? get av => double.tryParse(a.text.trim());
  double? get bv => double.tryParse(b.text.trim());

  double? get result {
    final x = av;
    final y = bv;
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

  double get ringPct {
    final r = result;
    if (r == null) return 0;
    return mode == 0 ? (av ?? 0) : r;
  }

  double get ringFrac => (ringPct.abs() / 100).clamp(0.0, 1.0).toDouble();

  String get sentence {
    final x = fmtNum(av ?? 0);
    final y = fmtNum(bv ?? 0);
    final r = fmtNum(result ?? 0);
    if (mode == 0) return '$x% of $y = $r';
    if (mode == 1) return '$x is $r% of $y';
    final up = (result ?? 0) >= 0 ? 'increase' : 'decrease';
    return '$x to $y is a $r% $up';
  }

  Widget bigField(
    AppState s,
    String label,
    String suffix,
    TextEditingController c,
    Widget bottom,
  ) {
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: s.subText)),
          Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: c,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  keyboardAppearance:
                      s.dark ? Brightness.dark : Brightness.light,
                  decoration: const BoxDecoration(),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  cursorColor: s.theme.accent,
                  placeholder: '0',
                  placeholderStyle: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w700,
                    color: s.subText,
                  ),
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w700,
                    color: s.text,
                  ),
                  onChanged: (_) => setState(() => copied = false),
                ),
              ),
              Text(suffix, style: TextStyle(fontSize: 30, color: s.subText)),
            ],
          ),
          const SizedBox(height: 6),
          Container(height: 1, color: s.glassBorder),
          const SizedBox(height: 10),
          bottom,
        ],
      ),
    );
  }

  Widget chips(AppState s) {
    return Row(
      children: [
        for (final v in [5, 10, 20, 25, 50])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    a.text = '$v';
                    copied = false;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: av == v.toDouble() ? s.theme.accent : s.glass,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: s.glassBorder),
                  ),
                  child: Text(
                    '$v%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: av == v.toDouble()
                          ? const Color(0xFFFFFFFF)
                          : s.text,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget slider(AppState s) {
    final v = (bv ?? 0).clamp(0.0, 1000.0).toDouble();
    return CupertinoSlider(
      value: v,
      min: 0.0,
      max: 1000.0,
      activeColor: s.theme.accent,
      onChanged: (x) => setState(() {
        b.text = x.round().toString();
        copied = false;
      }),
    );
  }

  Widget resultCard(AppState s) {
    final r = result;
    final suffix = mode == 0 ? '' : '%';
    final rs = r == null ? '' : '${fmtNum(r)}$suffix';
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        children: [
          Row(
            children: [
              Text('Result', style: TextStyle(fontSize: 16, color: s.subText)),
              const Spacer(),
              GestureDetector(
                onTap: r == null
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: rs));
                        HapticFeedback.mediumImpact();
                        setState(() => copied = true);
                      },
                child: Column(
                  children: [
                    Icon(
                      copied ? Icons.check : Icons.content_copy,
                      size: 20,
                      color: s.theme.accent,
                    ),
                    Text(
                      copied ? 'Copied' : 'Copy',
                      style: TextStyle(fontSize: 12, color: s.subText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: ringFrac),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) => CustomPaint(
                            painter: RingPainter(
                              v,
                              s.theme.accent,
                              s.theme.c2,
                              s.glass,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 86,
                        height: 86,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: s.glass,
                          border: Border.all(color: s.glassBorder),
                        ),
                        child: AnimNum(
                          value: ringPct,
                          decimals: ringPct % 1 == 0 ? 0 : 1,
                          suffix: '%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: s.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: r == null
                            ? Text(
                                '—',
                                style: TextStyle(
                                  fontSize: 64,
                                  color: s.subText,
                                ),
                              )
                            : ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (rect) => LinearGradient(
                                  colors: [s.theme.accent, s.theme.c2],
                                ).createShader(rect),
                                child: AnimNum(
                                  value: r,
                                  decimals: r % 1 == 0 ? 0 : 2,
                                  suffix: suffix,
                                  style: const TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                      ),
                      Text(
                        'Result',
                        style: TextStyle(fontSize: 16, color: s.text),
                      ),
                      if (r != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          sentence,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: s.subText),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return FillScroll(
      children: [
        FadeSlide(
          child: SegBar(
            labels: modes,
            index: mode,
            onChanged: (i) => setState(() => mode = i),
          ),
        ),
        const SizedBox(height: 14),
        FadeSlide(
          delay: 70,
          child: bigField(
            s,
            labels[mode][0],
            mode == 0 ? '%' : '',
            a,
            SizedBox(
              height: 38,
              child: mode == 0
                  ? chips(s)
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        hints[mode],
                        style: TextStyle(fontSize: 14, color: s.subText),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeSlide(
          delay: 140,
          child: bigField(s, labels[mode][1], '', b, slider(s)),
        ),
        const SizedBox(height: 14),
        Expanded(child: FadeSlide(delay: 210, child: resultCard(s))),
      ],
    );
  }
}
