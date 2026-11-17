import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import '../app_state.dart';
import '../ui_kit.dart';
import 'calc_engine.dart';

const _cats = <String, Map<String, double>>{
  'Length': {
    'm': 1.0,
    'km': 1000.0,
    'cm': 0.01,
    'mm': 0.001,
    'mi': 1609.344,
    'yd': 0.9144,
    'ft': 0.3048,
    'in': 0.0254,
  },
  'Weight': {
    'kg': 1.0,
    'g': 0.001,
    'mg': 0.000001,
    'lb': 0.45359237,
    'oz': 0.028349523125,
    'ton': 1000.0,
  },
  'Volume': {
    'L': 1.0,
    'mL': 0.001,
    'gal': 3.785411784,
    'cup': 0.2365882365,
    'tbsp': 0.01478676478,
  },
  'Speed': {
    'm/s': 1.0,
    'km/h': 0.2777777778,
    'mph': 0.44704,
    'knot': 0.5144444444,
  },
  'Area': {
    'm²': 1.0,
    'km²': 1000000.0,
    'ha': 10000.0,
    'ft²': 0.09290304,
    'acre': 4046.8564224,
  },
  'Data': {
    'B': 1.0,
    'KB': 1024.0,
    'MB': 1048576.0,
    'GB': 1073741824.0,
    'TB': 1099511627776.0,
  },
};

class ConverterTool extends StatefulWidget {
  const ConverterTool({super.key});

  @override
  State<ConverterTool> createState() => _ConverterToolState();
}

class _ConverterToolState extends State<ConverterTool> {
  String cat = 'Length';
  String from = 'm';
  String to = 'km';
  double turns = 0;
  final input = TextEditingController(text: '1');

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  List<String> get cats => [..._cats.keys, 'Temp'];

  List<String> unitsOf(String c) =>
      c == 'Temp' ? ['°C', '°F', 'K'] : _cats[c]!.keys.toList();

  void setCat(String c) {
    setState(() {
      cat = c;
      final u = unitsOf(c);
      from = u[0];
      to = u[1];
    });
  }

  double convert(double v) {
    if (cat == 'Temp') {
      final c = from == '°C'
          ? v
          : from == '°F'
              ? (v - 32) * 5 / 9
              : v - 273.15;
      return to == '°C'
          ? c
          : to == '°F'
              ? c * 9 / 5 + 32
              : c + 273.15;
    }
    final m = _cats[cat]!;
    return v * m[from]! / m[to]!;
  }

  Widget unitRow(String sel, ValueChanged<String> pick) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final u in unitsOf(cat))
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Pill(label: u, on: sel == u, onTap: () => pick(u)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final v = double.tryParse(input.text.trim());
    final out = v == null ? '—' : fmtNum(convert(v));
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        FadeSlide(
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final c in cats)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: Pill(
                        label: c,
                        on: cat == c,
                        onTap: () => setCat(c),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FadeSlide(
          delay: 80,
          child: GlassCard(
            radius: 26,
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('From', style: TextStyle(color: s.subText)),
                  const SizedBox(height: 6),
                  unitRow(from, (u) => setState(() => from = u)),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: input,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    keyboardAppearance:
                        s.dark ? Brightness.dark : Brightness.light,
                    decoration: const BoxDecoration(),
                    padding: EdgeInsets.zero,
                    cursorColor: s.theme.accent,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      color: s.text,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              final t = from;
              from = to;
              to = t;
              turns += 0.5;
            }),
            child: AnimatedRotation(
              turns: turns,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: s.theme.accent,
                ),
                child: const Icon(
                  Icons.swap_vert,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeSlide(
          delay: 160,
          child: GlassCard(
            radius: 26,
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('To', style: TextStyle(color: s.subText)),
                  const SizedBox(height: 6),
                  unitRow(to, (u) => setState(() => to = u)),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      out,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: s.theme.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
