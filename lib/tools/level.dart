import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../app_state.dart';
import '../ui_kit.dart';

const _green = Color(0xFF2EE6A8);

class VialPainter extends CustomPainter {
  final double x;
  final double y;
  final bool level;
  final Color accent;
  final Color line;
  final Color text;
  VialPainter(this.x, this.y, this.level, this.accent, this.line, this.text);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2 - 8;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [accent.withOpacity(0.2), accent.withOpacity(0.04)],
        ).createShader(rect),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = line,
    );
    final thin = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = line.withOpacity(0.6);
    for (var i = 1; i <= 3; i++) {
      canvas.drawCircle(c, r * i / 4, thin);
    }
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), thin);
    canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), thin);
    canvas.drawCircle(
      c,
      34,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = level ? _green : text.withOpacity(0.7),
    );

    final k = r / 12;
    var dx = x * k;
    var dy = -y * k;
    final dist = math.sqrt(dx * dx + dy * dy);
    final maxd = r - 30;
    if (dist > maxd) {
      dx *= maxd / dist;
      dy *= maxd / dist;
    }
    final bc = Offset(c.dx + dx, c.dy + dy);
    final col = level ? _green : accent;
    canvas.drawCircle(
      bc,
      36,
      Paint()
        ..color = col.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawCircle(bc, 28, Paint()..color = col.withOpacity(0.9));
    canvas.drawCircle(
      bc + const Offset(-8, -9),
      8,
      Paint()..color = const Color(0x73FFFFFF),
    );
  }

  @override
  bool shouldRepaint(VialPainter old) =>
      old.x != x || old.y != y || old.level != level || old.accent != accent;
}

class TubePainter extends CustomPainter {
  final double x;
  final bool level;
  final Color accent;
  final Color line;
  TubePainter(this.x, this.level, this.accent, this.line);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final w = size.width - 24;
    const h = 96.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: w, height: h),
      const Radius.circular(48),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withOpacity(0.28), accent.withOpacity(0.06)],
        ).createShader(rect.outerRect),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = line,
    );
    final mark = Paint()
      ..strokeWidth = 2.5
      ..color = level ? _green : line;
    canvas.drawLine(
      Offset(c.dx - 44, c.dy - h / 2),
      Offset(c.dx - 44, c.dy + h / 2),
      mark,
    );
    canvas.drawLine(
      Offset(c.dx + 44, c.dy - h / 2),
      Offset(c.dx + 44, c.dy + h / 2),
      mark,
    );
    final k = (w / 2 - 50) / 12;
    final maxd = w / 2 - 50;
    final dx = (x * k).clamp(-maxd, maxd).toDouble();
    final bc = Offset(c.dx + dx, c.dy);
    final col = level ? _green : accent;
    canvas.drawOval(
      Rect.fromCenter(center: bc, width: 96, height: 64),
      Paint()
        ..color = col.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawOval(
      Rect.fromCenter(center: bc, width: 76, height: 56),
      Paint()..color = col.withOpacity(0.9),
    );
    canvas.drawCircle(
      bc + const Offset(-14, -10),
      8,
      Paint()..color = const Color(0x73FFFFFF),
    );
  }

  @override
  bool shouldRepaint(TubePainter old) =>
      old.x != x || old.level != level || old.accent != accent;
}

class LevelTool extends StatefulWidget {
  const LevelTool({super.key});

  @override
  State<LevelTool> createState() => _LevelToolState();
}

class _LevelToolState extends State<LevelTool> {
  StreamSubscription<AccelerometerEvent>? sub;
  double ax = 0;
  double ay = 0;
  double az = 9.8;
  bool got = false;
  bool wasLevel = false;
  int mode = 0;
  double ox = 0;
  double oy = 0;
  double ux = 0;

  @override
  void initState() {
    super.initState();
    sub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 40),
    ).listen((e) {
      if (!got) {
        ax = e.x;
        ay = e.y;
        az = e.z;
        got = true;
      } else {
        ax += 0.2 * (e.x - ax);
        ay += 0.2 * (e.y - ay);
        az += 0.2 * (e.z - az);
      }
      final lv = isLevel;
      if (lv && !wasLevel) HapticFeedback.mediumImpact();
      wasLevel = lv;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  double get rawRoll =>
      math.atan2(ax, math.sqrt(ay * ay + az * az)) * 180 / math.pi;
  double get rawPitch =>
      math.atan2(ay, math.sqrt(ax * ax + az * az)) * 180 / math.pi;
  double get rawAngle => math.atan2(ax, ay) * 180 / math.pi;

  double get x => mode == 0 ? rawRoll - ox : rawAngle - ux;
  double get y => mode == 0 ? rawPitch - oy : 0.0;
  double get total => math.sqrt(x * x + y * y);
  bool get isLevel => mode == 0 ? total < 0.6 : x.abs() < 0.6;

  void calibrate() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (mode == 0) {
        ox = rawRoll;
        oy = rawPitch;
      } else {
        ux = rawAngle;
      }
    });
  }

  void resetCal() {
    HapticFeedback.lightImpact();
    setState(() {
      ox = 0;
      oy = 0;
      ux = 0;
    });
  }

  Widget hero(AppState s) {
    final lv = isLevel;
    final col = lv ? _green : s.theme.accent;
    return GlassCard(
      radius: 32,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Positioned.fill(
            child: mode == 0
                ? Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CustomPaint(
                        painter: VialPainter(
                          x,
                          y,
                          lv,
                          s.theme.accent,
                          s.glassBorder,
                          s.text,
                        ),
                      ),
                    ),
                  )
                : CustomPaint(
                    painter: TubePainter(
                      -x,
                      lv,
                      s.theme.accent,
                      s.glassBorder,
                    ),
                  ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                color: col.withOpacity(0.2),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: col),
              ),
              child: Text(
                lv ? 'LEVEL ✓' : 'Adjust karo',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: lv ? _green : s.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tile(AppState s, String label, String value) {
    return Expanded(
      child: GlassCard(
        radius: 22,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: s.text,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: s.subText)),
          ],
        ),
      ),
    );
  }

  Widget btn(AppState s, String label, Color bg, Color fg, VoidCallback f) {
    return Expanded(
      child: SizedBox(
        height: 54,
        child: KeyCap(
          radius: 27,
          color: bg,
          onTap: f,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final tiles = mode == 0
        ? [
            tile(s, 'Left–Right', '${x.toStringAsFixed(1)}°'),
            tile(s, 'Front–Back', '${y.toStringAsFixed(1)}°'),
            tile(s, 'Total', '${total.toStringAsFixed(1)}°'),
          ]
        : [
            tile(s, 'Angle', '${x.toStringAsFixed(1)}°'),
            tile(
              s,
              'Slope',
              '${(math.tan(x.abs() * math.pi / 180) * 100).toStringAsFixed(1)}%',
            ),
            tile(s, 'Status', isLevel ? 'Level' : 'Tilted'),
          ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
      child: Column(
        children: [
          FadeSlide(
            child: Row(
              children: [
                Pill(
                  label: 'Flat surface',
                  on: mode == 0,
                  onTap: () => setState(() => mode = 0),
                ),
                const SizedBox(width: 8),
                Pill(
                  label: 'Upright wall',
                  on: mode == 1,
                  onTap: () => setState(() => mode = 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: FadeSlide(delay: 70, child: hero(s))),
          const SizedBox(height: 12),
          FadeSlide(
            delay: 140,
            child: Row(
              children: [
                tiles[0],
                const SizedBox(width: 10),
                tiles[1],
                const SizedBox(width: 10),
                tiles[2],
              ],
            ),
          ),
          const SizedBox(height: 12),
          FadeSlide(
            delay: 200,
            child: Row(
              children: [
                btn(s, 'Calibrate', s.theme.accent, const Color(0xFFFFFFFF),
                    calibrate),
                const SizedBox(width: 12),
                btn(s, 'Reset', s.glass, s.text, resetCal),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
