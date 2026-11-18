import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../app_state.dart';
import '../ui_kit.dart';

const _north = Color(0xFFFF4D5E);
const _good = Color(0xFF2EE6A8);
const _warn = Color(0xFFFFB020);

class CompassPainter extends CustomPainter {
  final double heading;
  final double? target;
  final Color accent;
  final Color text;
  final Color sub;
  final Color line;
  CompassPainter(
    this.heading,
    this.target,
    this.accent,
    this.text,
    this.sub,
    this.line,
  );

  void label(
    Canvas canvas,
    String t,
    Offset pos,
    TextStyle st,
    double counter,
  ) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: st),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(counter);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2 - 26;
    final rot = -heading * math.pi / 180;

    canvas.drawCircle(
      c,
      r + 4,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = line,
    );

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rot);

    for (var d = 0; d < 360; d += 5) {
      final a = (d - 90) * math.pi / 180;
      final major = d % 30 == 0;
      final len = major ? 18.0 : (d % 10 == 0 ? 11.0 : 6.0);
      final p = Paint()
        ..strokeWidth = major ? 3.0 : 1.6
        ..strokeCap = StrokeCap.round
        ..color = major ? text : sub;
      canvas.drawLine(
        Offset((r - len) * math.cos(a), (r - len) * math.sin(a)),
        Offset(r * math.cos(a), r * math.sin(a)),
        p,
      );
    }

    const cards = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
    for (final e in cards.entries) {
      final a = (e.key - 90) * math.pi / 180;
      final pos = Offset((r - 46) * math.cos(a), (r - 46) * math.sin(a));
      label(
        canvas,
        e.value,
        pos,
        TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: e.value == 'N' ? _north : text,
        ),
        -rot,
      );
    }
    for (var d = 30; d < 360; d += 30) {
      if (d % 90 == 0) continue;
      final a = (d - 90) * math.pi / 180;
      final pos = Offset((r - 40) * math.cos(a), (r - 40) * math.sin(a));
      label(canvas, '$d', pos, TextStyle(fontSize: 13, color: sub), -rot);
    }

    if (target != null) {
      final a = (target! - 90) * math.pi / 180;
      canvas.drawLine(
        Offset((r - 40) * math.cos(a), (r - 40) * math.sin(a)),
        Offset((r + 6) * math.cos(a), (r + 6) * math.sin(a)),
        Paint()
          ..color = accent
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();

    final path = Path()
      ..moveTo(c.dx, c.dy - r - 8)
      ..lineTo(c.dx - 11, c.dy - r - 26)
      ..lineTo(c.dx + 11, c.dy - r - 26)
      ..close();
    canvas.drawPath(path, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(CompassPainter old) =>
      old.heading != heading ||
      old.target != target ||
      old.accent != accent ||
      old.text != text;
}

class CompassTool extends StatefulWidget {
  const CompassTool({super.key});

  @override
  State<CompassTool> createState() => _CompassToolState();
}

class _CompassToolState extends State<CompassTool> {
  StreamSubscription<AccelerometerEvent>? accSub;
  StreamSubscription<MagnetometerEvent>? magSub;
  Timer? watchdog;
  List<double> a = [0, 0, 9.8];
  List<double> m = [0, 0, 0];
  bool gotA = false;
  bool gotM = false;
  bool smoothInit = false;
  bool noSensor = false;
  double heading = 0;
  double field = 0;
  double tilt = 0;
  double? target;

  static const dirs = [
    'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
    'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW',
  ];

  @override
  void initState() {
    super.initState();
    accSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 50),
    ).listen(
      (e) {
        if (!gotA) {
          a = [e.x, e.y, e.z];
          gotA = true;
        } else {
          a = [
            a[0] + 0.15 * (e.x - a[0]),
            a[1] + 0.15 * (e.y - a[1]),
            a[2] + 0.15 * (e.z - a[2]),
          ];
        }
      },
      onError: (_) {
        if (mounted) setState(() => noSensor = true);
      },
    );
    magSub = magnetometerEventStream(
      samplingPeriod: const Duration(milliseconds: 50),
    ).listen(
      (e) {
        if (!gotM) {
          m = [e.x, e.y, e.z];
          gotM = true;
        } else {
          m = [
            m[0] + 0.2 * (e.x - m[0]),
            m[1] + 0.2 * (e.y - m[1]),
            m[2] + 0.2 * (e.z - m[2]),
          ];
        }
        update();
      },
      onError: (_) {
        if (mounted) setState(() => noSensor = true);
      },
    );
    watchdog = Timer(const Duration(seconds: 3), () {
      if (mounted && !(gotA && gotM)) setState(() => noSensor = true);
    });
  }

  @override
  void dispose() {
    accSub?.cancel();
    magSub?.cancel();
    watchdog?.cancel();
    super.dispose();
  }

  void update() {
    if (!gotA || !gotM || !mounted) return;
    final ax = a[0];
    final ay = a[1];
    final az = a[2];
    final ex = m[0];
    final ey = m[1];
    final ez = m[2];
    var hx = ey * az - ez * ay;
    var hy = ez * ax - ex * az;
    var hz = ex * ay - ey * ax;
    final nh = math.sqrt(hx * hx + hy * hy + hz * hz);
    if (nh < 0.1) return;
    hx /= nh;
    hy /= nh;
    hz /= nh;
    final na = math.sqrt(ax * ax + ay * ay + az * az);
    final nax = ax / na;
    final naz = az / na;
    final my = naz * hx - nax * hz;
    var h = math.atan2(hy, my) * 180 / math.pi;
    if (h < 0) h += 360;
    var diff = h - heading;
    while (diff > 180) {
      diff -= 360;
    }
    while (diff < -180) {
      diff += 360;
    }
    heading = smoothInit ? (heading + diff * 0.25 + 360) % 360 : h;
    smoothInit = true;
    field = math.sqrt(ex * ex + ey * ey + ez * ez);
    tilt = math.acos(naz.clamp(-1.0, 1.0).toDouble()) * 180 / math.pi;
    setState(() {});
  }

  String get cardinal => dirs[((heading + 11.25) / 22.5).floor() % 16];

  String get signal {
    if (field >= 25 && field <= 65) return 'Good';
    if (field >= 15 && field <= 90) return 'Fair';
    return 'Poor';
  }

  Color get signalColor =>
      signal == 'Good' ? _good : (signal == 'Fair' ? _warn : _north);

  String get deltaText {
    final t = target;
    if (t == null) return 'Ek direction lock karo, phir wahi dhundo';
    var d = t - heading;
    while (d > 180) {
      d -= 360;
    }
    while (d < -180) {
      d += 360;
    }
    if (d.abs() < 3) return 'On target ✓';
    return 'Turn ${d.abs().round()}° ${d > 0 ? 'right' : 'left'}';
  }

  void toggleLock() {
    HapticFeedback.mediumImpact();
    setState(() => target = target == null ? heading : null);
  }

  Widget hero(AppState s) {
    return GlassCard(
      radius: 32,
      padding: const EdgeInsets.all(12),
      child: noSensor
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sensors_off, size: 54, color: s.subText),
                  const SizedBox(height: 12),
                  Text(
                    'Compass sensor nahi mila',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: s.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Is phone mein magnetometer nahi hai',
                    style: TextStyle(fontSize: 14, color: s.subText),
                  ),
                ],
              ),
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: CompassPainter(
                      heading,
                      target,
                      s.theme.accent,
                      s.text,
                      s.subText,
                      s.glassBorder,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'HEADING',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 3,
                        color: s.subText,
                      ),
                    ),
                    Text(
                      '${heading.round()}°',
                      style: TextStyle(
                        fontSize: 58,
                        fontWeight: FontWeight.w300,
                        color: s.text,
                      ),
                    ),
                    Text(
                      cardinal,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: s.theme.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget tile(AppState s, String label, String value, {Color? c}) {
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
                  color: c ?? s.text,
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

  Widget lockCard(AppState s) {
    final t = target;
    final onT = t != null && deltaText.startsWith('On');
    const white = Color(0xFFFFFFFF);
    return GlassCard(
      radius: 26,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t == null ? 'Bearing lock' : 'Locked at ${t.round()}°',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: s.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tilt > 25 ? 'Phone ko flat rakho' : deltaText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: onT ? FontWeight.w700 : FontWeight.w400,
                    color: onT ? _good : s.subText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 112,
            height: 50,
            child: KeyCap(
              radius: 25,
              color: s.theme.accent,
              onTap: toggleLock,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    t == null ? Icons.lock_outline : Icons.lock_open,
                    color: white,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t == null ? 'Lock' : 'Clear',
                    style: const TextStyle(
                      color: white,
                      fontWeight: FontWeight.w700,
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

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
      child: Column(
        children: [
          Expanded(flex: 6, child: FadeSlide(child: hero(s))),
          const SizedBox(height: 12),
          FadeSlide(
            delay: 100,
            child: Row(
              children: [
                tile(s, 'Field (µT)', field.toStringAsFixed(0)),
                const SizedBox(width: 10),
                tile(s, 'Signal', signal, c: signalColor),
                const SizedBox(width: 10),
                tile(s, 'Tilt', '${tilt.round()}°'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FadeSlide(delay: 170, child: lockCard(s)),
        ],
      ),
    );
  }
}
