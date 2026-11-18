import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../app_state.dart';
import 'calc_keys.dart';

class CalculatorTool extends StatefulWidget {
  const CalculatorTool({super.key});
  @override
  State<CalculatorTool> createState() => _CalculatorToolState();
}

class _CalculatorToolState extends State<CalculatorTool> {
  String display = '0';
  String lastExpr = '';
  final List<String> history = [];
  double? first;
  String? op;
  bool fresh = true;

  double get cur => double.tryParse(display) ?? 0;

  String get exprLine {
    if (op != null && first != null) {
      return '${fmtNum(first!)} $op${fresh ? '' : ' $display'}';
    }
    return lastExpr;
  }

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
        lastExpr = '';
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
        lastExpr = '';
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
          final b = cur;
          final r = calc(first!, b, op!);
          final line = '${fmtNum(first!)} $op ${fmtNum(b)}';
          lastExpr = '$line =';
          history.add('$line = ${fmtNum(r)}');
          if (history.length > 50) history.removeAt(0);
          display = fmtNum(r);
          first = null;
          op = null;
          fresh = true;
        }
      } else if (k == '.') {
        lastExpr = '';
        if (fresh) {
          display = '0.';
          fresh = false;
        } else if (!display.contains('.')) {
          display += '.';
        }
      } else {
        lastExpr = '';
        if (fresh || display == '0') {
          display = k;
        } else {
          display += k;
        }
        fresh = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ListView(
                    reverse: true,
                    children: [
                      for (final h in history.reversed)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            h,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 18, color: s.subText),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 32,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        exprLine,
                        style: TextStyle(fontSize: 24, color: s.subText),
                      ),
                    ),
                  ),
                ),
                FittedBox(
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
              ],
            ),
          ),
        ),
        CalcKeypad(onKey: press),
        const SizedBox(height: 10),
      ],
    );
  }
}
