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

  Widget stat(AppState s, String label, int v) {
    return Expanded(
      child: Column(
        children: [
          AnimNum(
            value: v.toDouble(),
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w700,
              color: s.theme.accent,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 14, color: s.subText)),
        ],
      ),
    );
  }

  Widget info(AppState s, String label, String value) {
    return GlassCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: s.subText)),
            const SizedBox(height: 4),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = parts;
    final left = daysToBirthday;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        FadeSlide(
          child: GlassCard(
            radius: 28,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 180,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: dob,
                minimumYear: 1900,
                maximumDate: DateTime.now(),
                onDateTimeChanged: (d) => setState(() => dob = d),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeSlide(
          delay: 100,
          child: GlassCard(
            radius: 28,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              children: [
                stat(s, 'Years', p[0]),
                stat(s, 'Months', p[1]),
                stat(s, 'Days', p[2]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeSlide(
          delay: 180,
          child: Row(
            children: [
              Expanded(child: info(s, 'Days lived', inr(daysLived))),
              const SizedBox(width: 12),
              Expanded(
                child: info(
                  s,
                  'Next birthday',
                  left == 0 ? 'Today!' : 'in $left days',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
