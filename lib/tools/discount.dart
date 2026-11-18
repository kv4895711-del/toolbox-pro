import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../chrome.dart';
import '../ui_kit.dart';
import 'calc_engine.dart';
import 'fmt.dart';

class DiscountTool extends StatefulWidget {
  const DiscountTool({super.key});

  @override
  State<DiscountTool> createState() => _DiscountToolState();
}

class _DiscountToolState extends State<DiscountTool> {
  final p = TextEditingController(text: '2000');
  final dc = TextEditingController(text: '20');
  final tx = TextEditingController();
  static const green = Color(0xFF2EE6A8);
  static const presets = [5, 10, 15, 20, 25, 30, 40, 50];

  @override
  void dispose() {
    p.dispose();
    dc.dispose();
    tx.dispose();
    super.dispose();
  }

  double val(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;
  double get price => val(p);
  double get disc => val(dc).clamp(0.0, 100.0).toDouble();
  double get off => price * disc / 100;
  double get after => price - off;
  double get taxAmt => after * val(tx) / 100;
  double get total => after + taxAmt;

  Widget priceCard(AppState s) {
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Original price',
              style: TextStyle(fontSize: 16, color: s.subText)),
          Row(
            children: [
              Text(
                '₹',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: s.theme.accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CupertinoTextField(
                  controller: p,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  keyboardAppearance:
                      s.dark ? Brightness.dark : Brightness.light,
                  decoration: const BoxDecoration(),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  cursorColor: s.theme.accent,
                  placeholder: '0',
                  placeholderStyle: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: s.subText,
                  ),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: s.text,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget chip(AppState s, int v) {
    final on = disc == v.toDouble();
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => dc.text = '$v');
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? s.theme.accent : s.glass,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: s.glassBorder),
            ),
            child: Text(
              '$v%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: on ? const Color(0xFFFFFFFF) : s.text,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget presetGrid(AppState s) {
    return GlassCard(
      radius: 26,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(children: [for (final v in presets.sublist(0, 4)) chip(s, v)]),
          Row(children: [for (final v in presets.sublist(4)) chip(s, v)]),
        ],
      ),
    );
  }

  Widget line(AppState s, String label, String value, [Color? c]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: s.subText)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: c ?? s.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget dashed(AppState s) {
    return Row(
      children: [
        for (var i = 0; i < 26; i++)
          Expanded(
            child: Container(
              height: 1.5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: s.glassBorder,
            ),
          ),
      ],
    );
  }

  Widget receipt(AppState s) {
    final pct = price <= 0 ? 0.0 : off / price * 100;
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: s.theme.accent),
              const SizedBox(width: 8),
              Text(
                'RECEIPT',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                  color: s.subText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          line(s, 'Original price', '₹${inr(price, 2)}'),
          line(s, 'Discount (${fmtNum(disc)}%)', '− ₹${inr(off, 2)}', green),
          line(s, 'Tax', '+ ₹${inr(taxAmt, 2)}'),
          const SizedBox(height: 8),
          dashed(s),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'YOU PAY',
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 3,
                      color: s.subText,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (r) => LinearGradient(
                        colors: [s.theme.accent, s.theme.c2],
                      ).createShader(r),
                      child: AnimMoney(
                        value: total,
                        decimals: 2,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: green.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: green.withOpacity(0.5)),
            ),
            child: Text(
              'You save ₹${inr(off, 2)} (${fmtNum(pct)}%)',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return FillScroll(
      children: [
        FadeSlide(child: priceCard(s)),
        const SizedBox(height: 12),
        FadeSlide(
          delay: 70,
          child: Row(
            children: [
              Expanded(
                child: NumField(
                  label: 'Discount',
                  suffix: '%',
                  controller: dc,
                  onChanged: () => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NumField(
                  label: 'Tax (optional)',
                  suffix: '%',
                  controller: tx,
                  onChanged: () => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FadeSlide(delay: 130, child: presetGrid(s)),
        const SizedBox(height: 12),
        Expanded(child: FadeSlide(delay: 200, child: receipt(s))),
      ],
    );
  }
}
