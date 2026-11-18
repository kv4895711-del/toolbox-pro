import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show FontFeature;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../round_btn.dart';
import '../ui_kit.dart';

class TickRing extends CustomPainter {
  final double frac;
  final Color on;
  final Color off;
  final double pulse;
  TickRing(this.frac, this.on, this.off, this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2 - 10;
    final lit = (frac * 60).ceil();
    if (pulse > 0) {
      canvas.drawCircle(
        c,
        r - 20,
        Paint()
          ..color = on.withOpacity(0.18 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
      );
    }
    for (var i = 0; i < 60; i++) {
      final ang = -math.pi / 2 + i * 2 * math.pi / 60;
      final big = i % 5 == 0;
      final inner = r - (big ? 24 : 15);
      final p = Paint()
        ..strokeWidth = big ? 4 : 2.6
        ..strokeCap = StrokeCap.round
        ..color = i < lit ? on : off;
      canvas.drawLine(
        Offset(c.dx + inner * math.cos(ang), c.dy + inner * math.sin(ang)),
        Offset(c.dx + r * math.cos(ang), c.dy + r * math.sin(ang)),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(TickRing old) =>
      old.frac != frac || old.on != on || old.off != off || old.pulse != pulse;
}

class TimerTool extends StatefulWidget {
  const TimerTool({super.key});

  @override
  State<TimerTool> createState() => _TimerToolState();
}

class _TimerToolState extends State<TimerTool>
    with SingleTickerProviderStateMixin {
  Duration total = const Duration(minutes: 5);
  Duration left = const Duration(minutes: 5);
  bool running = false;
  bool started = false;
  bool done = false;
  DateTime? end;
  Timer? tick;
  int pickerKey = 0;
  late final AnimationController pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    tick?.cancel();
    pulse.dispose();
    super.dispose();
  }

  void start() {
    if (total.inSeconds == 0) {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      if (!started) left = total;
      started = true;
      done = false;
      running = true;
      end = DateTime.now().add(left);
    });
    tick?.cancel();
    tick = Timer.periodic(const Duration(milliseconds: 100), (_) => update());
  }

  void update() {
    final rem = end!.difference(DateTime.now());
    if (rem <= Duration.zero) {
      tick?.cancel();
      setState(() {
        left = Duration.zero;
        running = false;
        done = true;
      });
      buzz();
      return;
    }
    setState(() => left = rem);
  }

  Future<void> buzz() async {
    for (var i = 0; i < 6; i++) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
    }
  }

  void pause() {
    tick?.cancel();
    HapticFeedback.lightImpact();
    setState(() => running = false);
  }

  void reset() {
    tick?.cancel();
    HapticFeedback.lightImpact();
    setState(() {
      running = false;
      started = false;
      done = false;
      left = total;
    });
  }

  void preset(int m) {
    HapticFeedback.selectionClick();
    setState(() {
      total = Duration(minutes: m);
      left = total;
      pickerKey++;
    });
  }

  String fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$sec' : '$m:$sec';
  }

  String endsAt() {
    final e = end ?? DateTime.now().add(left);
    final h12 = e.hour % 12 == 0 ? 12 : e.hour % 12;
    final mm = e.minute.toString().padLeft(2, '0');
    return '$h12:$mm ${e.hour >= 12 ? 'PM' : 'AM'}';
  }

  Widget idleCard(AppState s) {
    return Column(
      children: [
        Text(
          'SET YOUR TIMER',
          style: TextStyle(fontSize: 13, letterSpacing: 3, color: s.subText),
        ),
        Expanded(
          child: Center(
            child: CupertinoTimerPicker(
              key: ValueKey(pickerKey),
              mode: CupertinoTimerPickerMode.hms,
              initialTimerDuration: total,
              onTimerDurationChanged: (d) => setState(() {
                total = d;
                left = d;
              }),
            ),
          ),
        ),
        Text(
          total.inSeconds == 0
              ? 'Time chuno'
              : 'Timer ${fmt(total)} ka hoga',
          style: TextStyle(fontSize: 15, color: s.subText),
        ),
      ],
    );
  }

  Widget ringCard(AppState s) {
    final frac = total.inMilliseconds == 0
        ? 0.0
        : (left.inMilliseconds / total.inMilliseconds)
            .clamp(0.0, 1.0)
            .toDouble();
    final shown = Duration(seconds: (left.inMilliseconds / 1000).ceil());
    final col = done ? const Color(0xFFFF4D5E) : s.theme.accent;
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) => Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: TickRing(
                frac,
                col,
                s.glassBorder,
                (done || running) ? 0.4 + 0.6 * pulse.value : 0.0,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                done ? "TIME'S UP!" : (running ? 'REMAINING' : 'PAUSED'),
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 3,
                  color: done ? col : s.subText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                fmt(shown),
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w300,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: s.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'of ${fmt(total)}',
                style: TextStyle(fontSize: 15, color: s.subText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget hero(AppState s) {
    return GlassCard(
      radius: 32,
      padding: const EdgeInsets.all(16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        layoutBuilder: (current, previous) => Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [...previous, if (current != null) current],
        ),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.94, end: 1.0).animate(anim),
            child: child,
          ),
        ),
        child: (started || done)
            ? KeyedSubtree(key: const ValueKey('ring'), child: ringCard(s))
            : KeyedSubtree(key: const ValueKey('idle'), child: idleCard(s)),
      ),
    );
  }

  Widget infoRow(AppState s) {
    final active = started || done;
    return SizedBox(
      height: 44,
      child: active
          ? Center(
              child: Text(
                done
                    ? "Time's up! Restart dabao"
                    : (running ? 'Ends at ${endsAt()}' : 'Paused'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: done ? const Color(0xFFFF4D5E) : s.subText,
                ),
              ),
            )
          : ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final m in const [1, 5, 10, 15, 20, 30, 45, 60])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: Pill(
                        label: '${m}m',
                        on: total == Duration(minutes: m),
                        onTap: () => preset(m),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget buttons(AppState s) {
    const white = Color(0xFFFFFFFF);
    final active = started || done;
    final Widget main;
    if (done) {
      main = RoundBtn(
        icon: Icons.refresh,
        label: 'Restart',
        bg: s.theme.accent,
        fg: white,
        onTap: reset,
      );
    } else if (running) {
      main = RoundBtn(
        icon: Icons.pause,
        label: 'Pause',
        bg: const Color(0x66FFB020),
        fg: s.text,
        onTap: pause,
      );
    } else {
      main = RoundBtn(
        icon: Icons.play_arrow,
        label: started ? 'Resume' : 'Start',
        bg: s.theme.accent,
        fg: white,
        onTap: start,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RoundBtn(
            icon: Icons.close,
            label: 'Cancel',
            bg: s.glass,
            fg: s.text,
            onTap: active ? reset : null,
          ),
          main,
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
          FadeSlide(delay: 80, child: infoRow(s)),
          const SizedBox(height: 12),
          FadeSlide(delay: 140, child: buttons(s)),
        ],
      ),
    );
  }
}
