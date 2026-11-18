import 'package:flutter/cupertino.dart';
import '../app_state.dart';

class CalcKeypad extends StatelessWidget {
  final ValueChanged<String> onKey;
  const CalcKeypad({super.key, required this.onKey});

  static const rows = [
    ['AC', '±', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['⌫', '0', '.', '='],
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Column(
      children: [
        for (final r in rows)
          Row(children: [for (final k in r) _key(s, k)]),
      ],
    );
  }

  Widget _key(AppState s, String k) {
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
          onTap: () => onKey(k),
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
}
