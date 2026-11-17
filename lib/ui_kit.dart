import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';

class FadeSlide extends StatelessWidget {
  final Widget child;
  final int delay;
  const FadeSlide({super.key, required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    final total = 450 + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1.0, curve: Curves.easeOutCubic),
      builder: (context, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 24), child: c),
      ),
      child: child,
    );
  }
}

class AnimNum extends StatelessWidget {
  final double value;
  final int decimals;
  final String suffix;
  final TextStyle style;
  const AnimNum({
    super.key,
    required this.value,
    required this.style,
    this.decimals = 0,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: value),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) =>
          Text('${v.toStringAsFixed(decimals)}$suffix', style: style),
    );
  }
}

class Pill extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;
  const Pill({
    super.key,
    required this.label,
    required this.on,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: on ? s.theme.accent : s.glass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: s.glassBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: on ? const Color(0xFFFFFFFF) : s.text,
          ),
        ),
      ),
    );
  }
}

class NumField extends StatelessWidget {
  final String label;
  final String suffix;
  final TextEditingController controller;
  final VoidCallback onChanged;
  const NumField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: s.subText)),
                CupertinoTextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  keyboardAppearance:
                      s.dark ? Brightness.dark : Brightness.light,
                  decoration: const BoxDecoration(),
                  padding: const EdgeInsets.only(top: 4),
                  cursorColor: s.theme.accent,
                  placeholder: '0',
                  placeholderStyle: TextStyle(fontSize: 26, color: s.subText),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: s.text,
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ],
            ),
          ),
          Text(suffix, style: TextStyle(fontSize: 18, color: s.subText)),
        ],
      ),
    );
  }
}

class KeyCap extends StatefulWidget {
  final Widget child;
  final Color color;
  final VoidCallback onTap;
  final double radius;
  const KeyCap({
    super.key,
    required this.child,
    required this.color,
    required this.onTap,
    this.radius = 18,
  });

  @override
  State<KeyCap> createState() => _KeyCapState();
}

class _KeyCapState extends State<KeyCap> {
  bool down = false;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => down = true),
      onTapUp: (_) => setState(() => down = false),
      onTapCancel: () => setState(() => down = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: down ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(color: s.glassBorder),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
