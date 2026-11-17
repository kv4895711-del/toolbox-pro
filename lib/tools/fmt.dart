import 'package:flutter/cupertino.dart';

String inr(num v, [int decimals = 0]) {
  final parts = v.abs().toStringAsFixed(decimals).split('.');
  final w = parts[0];
  var out = w;
  if (w.length > 3) {
    final head = w.substring(0, w.length - 3);
    final tail = w.substring(w.length - 3);
    out = head.replaceAllMapped(
            RegExp(r'\B(?=(\d{2})+(?!\d))'), (m) => ',') +
        ',' +
        tail;
  }
  if (parts.length > 1) out += '.${parts[1]}';
  return '${v < 0 ? '-' : ''}$out';
}

class AnimMoney extends StatelessWidget {
  final double value;
  final TextStyle style;
  final int decimals;
  const AnimMoney({
    super.key,
    required this.value,
    required this.style,
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: value),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('₹${inr(v, decimals)}', style: style),
    );
  }
}
