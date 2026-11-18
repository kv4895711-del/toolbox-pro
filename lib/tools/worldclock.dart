import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show FontFeature;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../store.dart';
import '../ui_kit.dart';

enum Dst { none, us, eu, au, nz }

class City {
  final String name;
  final String country;
  final int std;
  final Dst rule;
  const City(this.name, this.country, this.std, [this.rule = Dst.none]);
}

const allCities = [
  City('Mumbai', 'India', 330),
  City('Delhi', 'India', 330),
  City('Dubai', 'UAE', 240),
  City('Karachi', 'Pakistan', 300),
  City('Dhaka', 'Bangladesh', 360),
  City('Kathmandu', 'Nepal', 345),
  City('Colombo', 'Sri Lanka', 330),
  City('Bangkok', 'Thailand', 420),
  City('Jakarta', 'Indonesia', 420),
  City('Singapore', 'Singapore', 480),
  City('Hong Kong', 'China', 480),
  City('Shanghai', 'China', 480),
  City('Manila', 'Philippines', 480),
  City('Tokyo', 'Japan', 540),
  City('Seoul', 'South Korea', 540),
  City('Sydney', 'Australia', 600, Dst.au),
  City('Auckland', 'New Zealand', 720, Dst.nz),
  City('Moscow', 'Russia', 180),
  City('Istanbul', 'Turkey', 180),
  City('Riyadh', 'Saudi Arabia', 180),
  City('Nairobi', 'Kenya', 180),
  City('Johannesburg', 'South Africa', 120),
  City('Lagos', 'Nigeria', 60),
  City('London', 'United Kingdom', 0, Dst.eu),
  City('Dublin', 'Ireland', 0, Dst.eu),
  City('Lisbon', 'Portugal', 0, Dst.eu),
  City('Paris', 'France', 60, Dst.eu),
  City('Berlin', 'Germany', 60, Dst.eu),
  City('Madrid', 'Spain', 60, Dst.eu),
  City('Rome', 'Italy', 60, Dst.eu),
  City('Amsterdam', 'Netherlands', 60, Dst.eu),
  City('Sao Paulo', 'Brazil', -180),
  City('Buenos Aires', 'Argentina', -180),
  City('New York', 'USA', -300, Dst.us),
  City('Toronto', 'Canada', -300, Dst.us),
  City('Chicago', 'USA', -360, Dst.us),
  City('Mexico City', 'Mexico', -360),
  City('Denver', 'USA', -420, Dst.us),
  City('Los Angeles', 'USA', -480, Dst.us),
  City('Honolulu', 'USA', -600),
];

City? byName(String n) {
  for (final c in allCities) {
    if (c.name == n) return c;
  }
  return null;
}

DateTime nthSunday(int y, int m, int n) {
  if (n > 0) {
    final first = DateTime.utc(y, m, 1);
    final add = (7 - first.weekday) % 7;
    return DateTime.utc(y, m, 1 + add + (n - 1) * 7);
  }
  final last = DateTime.utc(y, m + 1, 0);
  return DateTime.utc(y, m, last.day - last.weekday % 7);
}

bool isDst(Dst rule, int stdMin, DateTime nowUtc) {
  final y = nowUtc.year;
  final std = Duration(minutes: stdMin);
  const h1 = Duration(hours: 1);
  const h2 = Duration(hours: 2);
  if (rule == Dst.us) {
    final start = nthSunday(y, 3, 2).add(h2).subtract(std);
    final end = nthSunday(y, 11, 1).add(h1).subtract(std);
    return !nowUtc.isBefore(start) && nowUtc.isBefore(end);
  }
  if (rule == Dst.eu) {
    final start = nthSunday(y, 3, -1).add(h1);
    final end = nthSunday(y, 10, -1).add(h1);
    return !nowUtc.isBefore(start) && nowUtc.isBefore(end);
  }
  if (rule == Dst.au) {
    final start = nthSunday(y, 10, 1).add(h2).subtract(std);
    final end = nthSunday(y, 4, 1).add(h2).subtract(std);
    return !nowUtc.isBefore(start) || nowUtc.isBefore(end);
  }
  if (rule == Dst.nz) {
    final start = nthSunday(y, 9, -1).add(h2).subtract(std);
    final end = nthSunday(y, 4, 1).add(h2).subtract(std);
    return !nowUtc.isBefore(start) || nowUtc.isBefore(end);
  }
  return false;
}

String two(int n) => n.toString().padLeft(2, '0');

String hm(DateTime t, bool h24) {
  if (h24) return '${two(t.hour)}:${two(t.minute)}';
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$h:${two(t.minute)}';
}

String ampm(DateTime t) => t.hour >= 12 ? 'PM' : 'AM';

String dayLabel(DateTime t) {
  final now = DateTime.now();
  final a = DateTime.utc(t.year, t.month, t.day);
  final b = DateTime.utc(now.year, now.month, now.day);
  final d = a.difference(b).inDays;
  if (d == 0) return 'Today';
  if (d == 1) return 'Tomorrow';
  if (d == -1) return 'Yesterday';
  return d > 0 ? '+$d days' : '$d days';
}

String dateLine(DateTime t) {
  const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const mo = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${wd[t.weekday - 1]}, ${t.day} ${mo[t.month - 1]}';
}

String utcLabel(int min) {
  final sign = min < 0 ? '-' : '+';
  final a = min.abs();
  final h = a ~/ 60;
  final m = a % 60;
  return 'UTC$sign$h${m == 0 ? '' : ':${two(m)}'}';
}

String diffLabel(int d) {
  if (d == 0) return 'Same as your time';
  final a = d.abs();
  final h = a ~/ 60;
  final m = a % 60;
  final t = m == 0 ? '${h}h' : '${h}h ${m}m';
  return d > 0 ? '$t ahead' : '$t behind';
}

class _Clock {
  final String name;
  final String sub;
  final int offset;
  final bool local;
  _Clock(this.name, this.sub, this.offset, this.local);
}

class ClockPainter extends CustomPainter {
  final DateTime t;
  final Color accent;
  final Color text;
  final Color sub;
  final Color line;
  final bool day;
  ClockPainter(this.t, this.accent, this.text, this.sub, this.line, this.day);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2 - 4;
    Offset pt(double th, double len) =>
        Offset(c.dx + len * math.sin(th), c.dy - len * math.cos(th));
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withOpacity(day ? 0.3 : 0.1),
            accent.withOpacity(0.03),
          ],
        ).createShader(rect),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = line,
    );
    for (var i = 0; i < 60; i++) {
      final th = i * math.pi / 30;
      final big = i % 5 == 0;
      canvas.drawLine(
        pt(th, r - (big ? 16 : 8)),
        pt(th, r - 2),
        Paint()
          ..strokeWidth = big ? 3.0 : 1.4
          ..strokeCap = StrokeCap.round
          ..color = big ? text : sub,
      );
    }
    for (final e in const {0: '12', 3: '3', 6: '6', 9: '9'}.entries) {
      final p = pt(e.key * math.pi / 6, r - 34);
      final tp = TextPainter(
        text: TextSpan(
          text: e.value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: text,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2));
    }
    final sec = t.second + t.millisecond / 1000;
    final hTh = ((t.hour % 12) + t.minute / 60) / 12 * 2 * math.pi;
    final mTh = (t.minute + sec / 60) / 60 * 2 * math.pi;
    final sTh = sec / 60 * 2 * math.pi;
    canvas.drawLine(
      c,
      pt(hTh, r * 0.5),
      Paint()
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = text,
    );
    canvas.drawLine(
      c,
      pt(mTh, r * 0.74),
      Paint()
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..color = text,
    );
    canvas.drawLine(
      pt(sTh + math.pi, r * 0.14),
      pt(sTh, r * 0.86),
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = accent,
    );
    canvas.drawCircle(c, 7, Paint()..color = accent);
    canvas.drawCircle(c, 3, Paint()..color = text);
  }

  @override
  bool shouldRepaint(ClockPainter old) => true;
}

class WorldClockTool extends StatefulWidget {
  const WorldClockTool({super.key});

  @override
  State<WorldClockTool> createState() => _WorldClockToolState();
}

class _WorldClockToolState extends State<WorldClockTool> {
  List<String> names = ['New York', 'London', 'Dubai', 'Tokyo', 'Sydney'];
  int sel = 0;
  bool h24 = false;
  Timer? ticker;

  @override
  void initState() {
    super.initState();
    load();
    ticker = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    final raw = await Store.read('worldclock');
    if (raw != null) {
      try {
        final l = (jsonDecode(raw) as List).map((e) => e as String).toList();
        if (mounted) setState(() => names = l);
      } catch (_) {}
    }
  }

  Future<void> save() => Store.write('worldclock', jsonEncode(names));

  List<_Clock> clocks(DateTime nowUtc) {
    final loc = DateTime.now().timeZoneOffset.inMinutes;
    final list = <_Clock>[
      _Clock('Your time', 'Local · ${DateTime.now().timeZoneName}', loc, true),
    ];
    for (final n in names) {
      final c = byName(n);
      if (c != null) {
        final off = c.std + (isDst(c.rule, c.std, nowUtc) ? 60 : 0);
        list.add(_Clock(c.name, c.country, off, false));
      }
    }
    return list;
  }

  void addCity() {
    HapticFeedback.lightImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _CitySheet(
        taken: names,
        onPick: (n) {
          setState(() => names.add(n));
          save();
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Widget dayBar(double frac) {
    return SizedBox(
      height: 12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1B1F4B),
                  Color(0xFF1B1F4B),
                  Color(0xFFFF9A5A),
                  Color(0xFF4DA3FF),
                  Color(0xFF4DA3FF),
                  Color(0xFFFF7A8A),
                  Color(0xFF1B1F4B),
                  Color(0xFF1B1F4B),
                ],
                stops: [0.0, 0.22, 0.3, 0.4, 0.65, 0.76, 0.86, 1.0],
              ),
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment(2 * frac - 1, 0),
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget hero(AppState s, _Clock c, DateTime nowUtc, int loc) {
    final t = nowUtc.add(Duration(minutes: c.offset));
    final day = t.hour >= 6 && t.hour < 18;
    return GlassCard(
      radius: 32,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: s.text,
                      ),
                    ),
                    Text(
                      '${c.sub} · ${utcLabel(c.offset)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: s.subText),
                    ),
                  ],
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: s.theme.accent.withOpacity(0.2),
                ),
                child: Icon(
                  day ? Icons.wb_sunny : Icons.nightlight_round,
                  color: day
                      ? const Color(0xFFFFB020)
                      : const Color(0xFFB8B0FF),
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: ClockPainter(
                    t,
                    s.theme.accent,
                    s.text,
                    s.subText,
                    s.glassBorder,
                    day,
                  ),
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hm(t, h24),
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w300,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: s.text,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  h24 ? ':${two(t.second)}' : ampm(t),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: s.theme.accent,
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${dateLine(t)} · ${dayLabel(t)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: s.text),
                    ),
                    Text(
                      diffLabel(c.offset - loc),
                      style: TextStyle(fontSize: 13, color: s.subText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget item(AppState s, _Clock c, int i, DateTime nowUtc, int loc) {
    final t = nowUtc.add(Duration(minutes: c.offset));
    final on = i == sel;
    final card = GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => sel = i);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: on ? s.theme.accent.withOpacity(0.22) : s.glass,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: on ? s.theme.accent : s.glassBorder,
            width: on ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: s.text,
                        ),
                      ),
                      Text(
                        '${dayLabel(t)} · ${diffLabel(c.offset - loc)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: s.subText),
                      ),
                    ],
                  ),
                ),
                Text(
                  hm(t, h24),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: s.text,
                  ),
                ),
                if (!h24)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 6),
                    child: Text(
                      ampm(t),
                      style: TextStyle(fontSize: 12, color: s.subText),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            dayBar((t.hour * 60 + t.minute) / 1440),
          ],
        ),
      ),
    );
    if (c.local) return card;
    return Dismissible(
      key: ValueKey(c.name),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0x66FF4D5E),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_outline, color: Color(0xFFFFFFFF)),
      ),
      onDismissed: (_) {
        setState(() {
          names.remove(c.name);
          sel = 0;
        });
        save();
      },
      child: card,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final nowUtc = DateTime.now().toUtc();
    final loc = DateTime.now().timeZoneOffset.inMinutes;
    final list = clocks(nowUtc);
    final cur = list[math.min(sel, list.length - 1)];
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: FadeSlide(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                layoutBuilder: (current, previous) => Stack(
                  fit: StackFit.expand,
                  children: [...previous, if (current != null) current],
                ),
                child: KeyedSubtree(
                  key: ValueKey(cur.name),
                  child: hero(s, cur, nowUtc, loc),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeSlide(
            delay: 100,
            child: Row(
              children: [
                Text(
                  'Cities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: s.text,
                  ),
                ),
                const Spacer(),
                Pill(
                  label: h24 ? '24h' : '12h',
                  on: false,
                  onTap: () => setState(() => h24 = !h24),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: addCity,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [s.theme.accent, s.theme.c2],
                      ),
                    ),
                    child: const Icon(Icons.add, color: Color(0xFFFFFFFF)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            flex: 5,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: list.length,
              itemBuilder: (context, i) => item(s, list[i], i, nowUtc, loc),
            ),
          ),
        ],
      ),
    );
  }
}

class _CitySheet extends StatelessWidget {
  final List<String> taken;
  final ValueChanged<String> onPick;
  const _CityS
