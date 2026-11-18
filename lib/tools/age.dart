import 'package:flutter/cupertino.dart';
import '../app_state.dart';
import '../ui_kit.dart';
import 'fmt.dart';

class AgeTool extends StatefulWidget {
  const AgeTool({super.key});

  @override
  State<AgeTool> createState() => _AgeToolState();
}

class _AgeToolState extends State<AgeTool> {
  DateTime dob = DateTime(2000, 1, 1);

  static const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  DateTime u(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  List<int> get parts {
    final n = DateTime.now();
    var y = n.year - dob.year;
    var m = n.month - dob.month;
    var d = n.day - dob.day;
    if (d < 0) {
      m -= 1;
      d += DateTime(n.year, n.month, 0).day;
    }
    if (m < 0) {
      y -= 1;
      m += 12;
    }
    return [y, m, d];
  }

  int get daysLived => u(DateTime.now()).difference(u(dob)).inDays;

  int get daysToBirthday {
    final n = DateTime.now();
    final today = u(n);
    var next = DateTime.utc(n.year, dob.month, dob.day);
    if (next.isBefore(today)) {
      next = DateTime.utc(n.year + 1, dob.month, dob.day);
    }
    return next.difference(today).inDays;
  }

  Widget hero(AppState s) {
    final p = parts;
    final m = p[1];
    final left = daysToBirthday;
    return GlassCard(
      radius: 30,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('You are',
                    style: TextStyle(fontSize: 16, color: s.subText)),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (r) => LinearGradient(
                    colors: [s.theme.accent, s.theme.c2],
                  ).createShader(r),
                  child: AnimNum(
                    value: p[0].toDouble(),
                    style: const TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                Text(
                  'years old',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: s.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Born on ${days[dob.weekday - 1]}',
                  style: TextStyle(fontSize: 14, color: s.subText),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    for (var i = 0; i < 12; i++)
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 10,
                          decoration: BoxDecoration(
                            color: i < m
                                ? s.theme.accent
                                : (i == m
                                    ? s.theme.accent.withOpacity(0.45)
                                    : s.glass),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$m months ${p[2]} days into this year of life',
                  style: TextStyle(fontSize: 13, color: s.subText),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: s.theme.accent.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: s.theme.accent),
                  ),
                  child: Text(
                    left == 0
                        ? 'Happy Birthday! 🎂'
                        : 'Next birthday in $left days 🎂',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: s.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Widget pickerCard() {
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        height: 150,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: dob,
          minimumYear: 1900,
          maximumDate: DateTime.now(),
          onDateTimeChanged: (d) => setState(() => dob = d),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = parts;
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
                tile(s, 'Months lived', inr(p[0] * 12 + p[1])),
                const SizedBox(width: 10),
                tile(s, 'Days lived', inr(daysLived)),
                const SizedBox(width: 10),
                tile(s, 'Hours lived', inr(daysLived * 24)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FadeSlide(delay: 180, child: pickerCard()),
        ],
      ),
    );
  }
}
