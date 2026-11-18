import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'app_state.dart';

const kBrand = 'NIRNAY ZEBRA';

class AuroraBackground extends StatelessWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});

  Widget blob(Color c, double size, double op) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [c.withOpacity(op), c.withOpacity(0.0)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = s.theme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: s.bg,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(top: -120, right: -100, child: blob(t.accent, 380, 0.55)),
          Positioned(top: 260, left: -160, child: blob(t.c1, 380, 0.5)),
          Positioned(bottom: -140, right: -80, child: blob(t.c2, 400, 0.55)),
          child,
        ],
      ),
    );
  }
}

class GlassBack extends StatelessWidget {
  const GlassBack({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
      child: GlassCard(
        blur: true,
        radius: 24,
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.chevron_left, size: 32, color: s.text),
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: s.theme.accent, width: 2.5),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: s.theme.accent,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          kBrand,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: s.theme.accent,
          ),
        ),
      ],
    );
  }
}

class SegBar extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  const SegBar({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final n = labels.length;
    return GlassCard(
      blur: true,
      radius: 30,
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        height: 48,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment(n == 1 ? 0.0 : -1 + 2 * index / (n - 1), 0),
              child: FractionallySizedBox(
                widthFactor: 1 / n,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: [s.theme.accent, s.theme.c2],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: s.theme.accent.withOpacity(0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < n; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onChanged(i);
                      },
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            labels[i],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: i == index
                                  ? const Color(0xFFFFFFFF)
                                  : s.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FillScroll extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  const FillScroll({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(18, 4, 18, 20),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final minH =
            (c.maxHeight - padding.vertical).clamp(0.0, double.infinity);
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minH.toDouble()),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
