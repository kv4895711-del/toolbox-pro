import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../app_state.dart';

class CalculatorTool extends StatefulWidget {
  const CalculatorTool({super.key});
  @override
  State<CalculatorTool> createState() => _CalculatorToolState();
}

class _CalculatorToolState extends State<CalculatorTool> {
  String display = '0';
  double? first;
  String? op;
  bool fresh = true;

  static const rows = [
    ['AC', '±', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['⌫', '0', '.', '='],
  ];

  double get cur => double.tryParse(display) ?? 0;

  String fmtNum(double v) {
    if (v.isNaN || v.isInfinite) return 'Error';
    if (v == v.roundToDouble() && v.abs() < 1e15) {
      return v.toInt().toString();
    }
    var t = v.toStringAsFixed(8);
    t = t.replaceFirst(RegExp(r'0+$'), '');
    return t.replaceFirst(RegExp(r'\.$'), '');
  }

  double calc(double a, double b, String o) {
    if (o == '+') return a + b;
    if (o == '-') return a - b;
    if (o == '×') return a * b;
    return b == 0 ? double.nan : a / b;
  }

  void press(String k) {
    HapticFeedback.selectionClick();
    setState(() {
      if (k == 'AC') {
        display = '0';
        first = null;
        op = null;
        fresh = true;
      } else if (k == '±') {
        display = fmtNum(-cur);
      } else if (k == '%') {
        display = fmtNum(cur / 100);
        fresh = true;
      } else if (k == '⌫') {
        final short = display.length <= 1 ||
            (display.length == 2 && display.startsWith('-'));
        if (!fresh && !short) {
          display = display.substring(0, display.length - 1);
        } else {
          display = '0';
          fresh = true;
        }
      } else if ('+-×÷'.contains(k)) {
        if (first != null && op != null && !fresh) {
          first = calc(first!, cur, op!);
          display = fmtNum(first!);
        } else {
          first = cur;
        }
        op = k;
        fresh = true;
      } else if (k == '=') {
        if (first != null && op != null) {
          display = fmtNum(calc(first!, cur, op!));
          first = null;
          op = null;
          fresh = true;
        }
      } else if (k == '.') {
        if (fresh) {
          display = '0.';
          fresh = false;
        } else if (!display.contains('.')) {
          display += '.';
        }
      } else {
        if (fresh || display == '0') {
          display = k;
        } else {
          display += k;
        }
        fresh = false;
      }
    });
  }

  Widget key(AppState s, String k) {
    final isOp = '÷×-+='.contains(k);
    final isTop = k == 'AC' || k == '±' || k == '%';
    final bg = isOp
        ? const Color(0xFFFF9F0A)
        : isTop
            ? const Color(0x55888888)
            : s.glass;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: GestureDetector(
          onTap: () => press(k),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: s.glassBorder),
            ),
            alignment: Alignment.center,
            child: Text(
              k,
              style: TextStyle(
                fontSize: 28,
                color: isOp ? const Color(0xFFFFFFFF) : s.text,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Column(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                display,
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w300,
                  color: s.text,
                ),
              ),
            ),
          ),
        ),
        for (final r in rows) Row(children: [for (final k in r) key(s, k)]),
        const SizedBox(height: 10),
      ],
    );
  }
}
