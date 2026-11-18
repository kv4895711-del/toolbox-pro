import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show FontFeature;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../round_btn.dart';
import '../ui_kit.dart';

class DialPainter extends CustomPainter {
  final double sec;
  final Color accent;
  final Color off;
  DialPainter(this.sec, this.accent, this.off);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2 - 8;
    for (var i = 0; i < 60; i++) {
      final ang = -math.pi / 2 + i * 2 * math.pi / 60;
      final big = i % 5 == 0;
      final inner = r - (big ? 22 : 13);
      final p = Paint()
        ..strokeWidth = big ? 3.6 : 2.2
        ..strokeCap = StrokeCap.round
        ..color = i <= sec ? accent.withOpacity(big ? 1.0 : 0.75) : off;
      canvas.drawLine(
        Offset(c.dx + inner * math.cos(ang), c.dy + inner * math.sin(ang)),
        Offset(c.dx + r * math.cos(ang), c.dy + r * math.sin(ang)),
        p,
      );
    }
    final a = -math.pi / 2 + sec / 60 * 2 * math.pi;
    final tip = Offset(
      c.dx + (r - 4) * math.cos(a),
      c.dy + (r - 4) * math.sin(a),
    );
    canvas.drawCircle(
      tip,
      16,
      Paint()
        ..color = accent.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(tip, 6, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(DialPainter old) =>
      old.sec != sec || old.accent != accent || old.off != off;
}

class StopwatchTool extends StatefulWidget {
  const StopwatchTool({super.key});

  @override
  State<StopwatchTool> createState() => _StopwatchToolState();
}

class _StopwatchToolState extends State<StopwatchTool> {
  final sw = Stopwatch();
  Timer? tick;
  final List<Duration> laps = [];

  static const green = Color(0xFF2EE6A8);
  static const red = Color(0xFFFF4D5E);

  @override
  void dispose() {
    tick?.cancel();
    super.dispose();
  }

  void toggle() {
    HapticFeedback.mediumImpact();
    if (sw.isRunning) {
      sw.stop();
      tick?.cancel();
      setState(() {});
    } else {
      sw.start();
      tick = Timer.periodic(
        const Duration(milliseconds: 33),
        (_) => setState(() {}),
      );
      setState(() {});
    }
  }

  void lapOrReset() {
    HapticFeedback.lightImpact();
    if (sw.isRunning) {
      setState(() => laps.add(sw.elapsed));
    } else {
      sw.reset();
      setState(() => laps.clear());
    }
  }

  String fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final c = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$m:$s.$c';
  }

  List<Duration> get lapTimes => [
        for (var i = 0; i < laps.length; i++)
          i == 0 ? laps[0] : laps[i] - laps[i - 1],
      ];

  Widget hero(AppState s) {
    final el = sw.elapsed;
    final sec = (el.inMilliseconds % 60000) / 1000;
    final state = sw.isRunning
        ? 'RUNNING'
        : (el > Duration.zero ? 'PAUSED' : 'READY');
    return GlassCard(
      radius: 32,
      padding: const EdgeInsets.all(14),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: DialPainter(sec, s.theme.accent, s.glassBorder),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state,
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 3,
                      color: s.subText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fmt(el),
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w300,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: s.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    laps.isEmpty
                        ? 'Start dabao'
                        : 'Last lap ${fmt(lapTimes.last)}',
                    style: TextStyle(fontSize: 14, color: s.subText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget lapsCard(AppState s) {
    final lt = lapTimes;
    Duration? best;
    Duration? worst;
    if (lt.length >= 2) {
      best = lt.reduce((a, b) => a < b ? a : b);
      worst = lt.reduce((a, b) => a > b ? a : b);
    }
    const tab = [FontFeature.tabularFigures()];
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Laps',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: s.text,
                ),
              ),
              Text('${lt.length}',
                  style: TextStyle(fontSize: 15, color: s.subText)),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: s.glassBorder),
          Expanded(
            child: lt.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag_outlined, size: 40, color: s.subText),
                        const SizedBox(height: 8),
                        Text(
                          'Chalte time Lap dabao,\nsplits yahan dikhenge',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: s.subText),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: lt.length,
                    itemBuilder: (context, k) {
                      final i = lt.length - 1 - k;
                      final c = lt[i] == best
                          ? green
                          : (lt[i] == worst ? red : s.text);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 70,
                              child: Text(
                                'Lap ${i + 1}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: s.subText,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                fmt(lt[i]),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: tab,
                                  color: c,
                                ),
                              ),
                            ),
                            Text(
                              fmt(laps[i]),
                              style: TextStyle(
                                fontSize: 14,
                                fontFeatures: tab,
                                color: s.subText,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget buttons(AppState s) {
    const white = Color(0xFFFFFFFF);
    final running = sw.isRunning;
    final el = sw.elapsed;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          running
              ? RoundBtn(
                  icon: Icons.flag,
                  label: 'Lap',
                  bg: s.glass,
                  fg: s.text,
                  onTap: lapOrReset,
                )
              : RoundBtn(
                  icon: Icons.refresh,
                  label: 'Reset',
                  bg: s.glass,
                  fg: s.text,
                  onTap: el > Duration.zero ? lapOrReset : null,
                ),
          RoundBtn(
            icon: running ? Icons.pause : Icons.play_arrow,
            label: running ? 'Stop' : (el > Duration.zero ? 'Resume' : 'Start'),
            bg: running ? const Color(0x66FF4D5E) : s.theme.accent,
            fg: running ? s.text : white,
            onTap: toggle,
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
          Expanded(flex: 5, child: FadeSlide(child: hero(s))),
          const SizedBox(height: 12),
          Expanded(flex: 4, child: FadeSlide(delay: 100, child: lapsCard(s))),
          const SizedBox(height: 12),
          FadeSlide(delay: 180, child: buttons(s)),
        ],
      ),
    );
  }
}
