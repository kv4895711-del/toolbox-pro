import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import '../app_state.dart';
import '../ui_kit.dart';
import 'calc_engine.dart';

class ScientificTool extends StatefulWidget {
  const ScientificTool({super.key});

  @override
  State<ScientificTool> createState() => _ScientificToolState();
}

class _ScientificToolState extends State<ScientificTool> {
  String expr = '';
  String result = '';
  bool deg = true;
  bool done = false;

  static const rows = [
    ['sin', 'cos', 'tan', 'log', 'ln'],
    ['√', 'π', 'e', '^', '⌫'],
    ['7', '8', '9', '×', '÷'],
    ['4', '5', '6', '−', '+'],
    ['1', '2', '3', '(', ')'],
    ['0', '.', '%', 'AC', '='],
  ];
  static const funcs = {
    'sin': 'sin(',
    'cos': 'cos(',
    'tan': 'tan(',
    'log': 'log(',
    'ln': 'ln(',
    '√': 'sqrt(',
    'π': 'pi',
  };

  void calc() {
    if (expr.isEmpty) {
      result = '';
      return;
    }
    final v = CalcEngine.eval(expr.replaceAll('−', '-'), deg: deg);
    final t = v == null ? '' : fmtNum(v);
    result = t == 'Error' ? '' : t;
  }

  void press(String k) {
    setState(() {
      final starts = RegExp(r'[0-9.]').hasMatch(k) ||
          funcs.containsKey(k) ||
          k == 'e' ||
          k == '(';
      if (done && starts) expr = '';
      if (k != '=') done = false;
      if (k == 'AC') {
        expr = '';
      } else if (k == '⌫') {
        final m = RegExp(r'(sin\(|cos\(|tan\(|log\(|ln\(|sqrt\(|pi|e)$')
            .firstMatch(expr);
        if (m != null) {
          expr = expr.substring(0, m.start);
        } else if (expr.isNotEmpty) {
          expr = expr.substring(0, expr.length - 1);
        }
      } else if (k == '=') {
        if (result.isNotEmpty) {
          expr = result.replaceAll('-', '−');
          result = '';
          done = true;
        }
        return;
      } else {
        expr += funcs[k] ?? k;
      }
      calc();
    });
  }

  Widget keyFor(AppState s, String k) {
    const ops = ['×', '÷', '−', '+', '^', '%'];
    Color bg = s.glass;
    Color fg = s.text;
    if (k == '=') {
      bg = s.theme.accent;
      fg = const Color(0xFFFFFFFF);
    } else if (k == 'AC') {
      bg = const Color(0x55FF4D5E);
    } else if (rows[0].contains(k) || rows[1].contains(k)) {
      bg = s.theme.accent.withOpacity(0.22);
    } else if (ops.contains(k)) {
      bg = s.theme.accent.withOpacity(0.38);
    }
    final Widget label = k == '⌫'
        ? Icon(Icons.backspace_outlined, size: 22, color: fg)
        : Text(
            k,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: fg),
          );
    return Padding(
      padding: const EdgeInsets.all(3.5),
      child: KeyCap(color: bg, onTap: () => press(k), child: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final shown = expr.replaceAll('sqrt(', '√(').replaceAll('pi', 'π');
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Pill(
                label: 'DEG',
                on: deg,
                onTap: () => setState(() {
                  deg = true;
                  calc();
                }),
              ),
              const SizedBox(width: 8),
              Pill(
                label: 'RAD',
                on: !deg,
                onTap: () => setState(() {
                  deg = false;
                  calc();
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            flex: 2,
            child: FadeSlide(
              child: SizedBox(
                width: double.infinity,
                child: GlassCard(
                  radius: 26,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          shown.isEmpty ? '0' : shown,
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w300,
                            color: s.text,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result.isEmpty ? ' ' : '= $result',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: s.theme.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 6,
            child: FadeSlide(
              delay: 120,
              child: Column(
                children: [
                  for (final r in rows)
                    Expanded(
                      child: Row(
                        children: [
                          for (final k in r) Expanded(child: keyFor(s, k)),
                        ],
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
}
