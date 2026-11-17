import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../ui_kit.dart';

class PasswordTool extends StatefulWidget {
  const PasswordTool({super.key});

  @override
  State<PasswordTool> createState() => _PasswordToolState();
}

class _PasswordToolState extends State<PasswordTool> {
  double len = 16;
  final on = [true, true, true, true];
  static const names = ['A–Z', 'a–z', '0–9', '#@!'];
  static const sets = [
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    'abcdefghijklmnopqrstuvwxyz',
    '0123456789',
    '!@#\$%^&*()-_=+[]{};:,.?',
  ];
  String pw = '';
  bool copied = false;

  @override
  void initState() {
    super.initState();
    pw = gen();
  }

  List<String> get chosen => [
        for (var i = 0; i < 4; i++)
          if (on[i]) sets[i],
      ];

  String gen() {
    final r = math.Random.secure();
    final ch = chosen;
    final pool = ch.join();
    final out = <String>[for (final c in ch) c[r.nextInt(c.length)]];
    while (out.length < len.round()) {
      out.add(pool[r.nextInt(pool.length)]);
    }
    out.shuffle(r);
    return out.join();
  }

  double get bits => len.round() * math.log(chosen.join().length) / math.ln2;

  String get label {
    if (bits < 40) return 'Weak';
    if (bits < 60) return 'Fair';
    if (bits < 80) return 'Strong';
    return 'Very strong';
  }

  Color get color {
    if (bits < 40) return const Color(0xFFFF4D5E);
    if (bits < 60) return const Color(0xFFFFB020);
    if (bits < 80) return const Color(0xFF2EE6A8);
    return const Color(0xFF4DA3FF);
  }

  void regen() => setState(() {
        pw = gen();
        copied = false;
      });

  void toggle(int i) {
    on[i] = !on[i];
    if (!on.contains(true)) on[i] = true;
    regen();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final frac = (bits / 100).clamp(0.0, 1.0).toDouble();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        FadeSlide(
          child: GlassCard(
            radius: 28,
            padding: const EdgeInsets.all(22),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      pw,
                      key: ValueKey(pw),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 22,
                        letterSpacing: 1,
                        color: s.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Pill(
                        label: copied ? 'Copied ✓' : 'Copy',
                        on: copied,
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: pw));
                          setState(() => copied = true);
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) setState(() => copied = false);
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Pill(label: 'Regenerate', on: false, onTap: regen),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeSlide(
          delay: 80,
          child: GlassCard(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Strength',
                          style: TextStyle(fontSize: 14, color: s.subText)),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: frac),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => Container(
                      height: 10,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: s.glass,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: v,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeSlide(
          delay: 160,
          child: GlassCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Length',
                        style: TextStyle(fontSize: 15, color: s.subText)),
                    Text(
                      '${len.round()}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: s.text,
                      ),
                    ),
                  ],
                ),
                CupertinoSlider(
                  value: len,
                  min: 6.0,
                  max: 40.0,
                  divisions: 34,
                  activeColor: s.theme.accent,
                  onChanged: (v) {
                    len = v;
                    regen();
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeSlide(
          delay: 220,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < 4; i++)
                Pill(label: names[i], on: on[i], onTap: () => toggle(i)),
            ],
          ),
        ),
      ],
    );
  }
}
