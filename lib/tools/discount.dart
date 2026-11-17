import 'package:flutter/cupertino.dart';
import '../app_state.dart';
import '../ui_kit.dart';
import 'fmt.dart';

class DiscountTool extends StatefulWidget {
  const DiscountTool({super.key});

  @override
  State<DiscountTool> createState() => _DiscountToolState();
}

class _DiscountToolState extends State<DiscountTool> {
  final p = TextEditingController();
  final dc = TextEditingController();
  final tx = TextEditingController();
  static const green = Color(0xFF2EE6A8);

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
  double get after => price * (1 - disc / 100);
  double get saved => price - after;
  double get taxAmt => after * val(tx) / 100;

  Widget result(AppState s) {
    final frac = price <= 0 ? 1.0 : (after / price).clamp(0.0, 1.0).toDouble();
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.all(22),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You pay', style: TextStyle(fontSize: 14, color: s.subText)),
            const SizedBox(height: 6),
            AnimMoney(
              value: after + taxAmt,
              decimals: 2,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: s.theme.accent,
              ),
            ),
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: frac),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Container(
                height: 12,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  widthFactor: v,
                  child: Container(
                    decoration: BoxDecoration(
                      color: s.theme.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paid ₹${inr(after, 2)}',
                  style: TextStyle(fontSize: 14, color: s.subText),
                ),
                Text(
                  'Saved ₹${inr(saved, 2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: green,
                  ),
                ),
              ],
            ),
            if (taxAmt > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Includes tax ₹${inr(taxAmt, 2)}',
                style: TextStyle(fontSize: 13, color: s.subText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        FadeSlide(
          child: NumField(
            label: 'Original price',
            suffix: '₹',
            controller: p,
            onChanged: () => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        FadeSlide(
          delay: 80,
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
        const SizedBox(height: 14),
        FadeSlide(
          delay: 140,
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final v in [5, 10, 20, 30, 50])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: Pill(
                        label: '$v%',
                        on: disc == v,
                        onTap: () => setState(() => dc.text = '$v'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (price > 0) FadeSlide(delay: 200, child: result(s)),
      ],
    );
  }
}
