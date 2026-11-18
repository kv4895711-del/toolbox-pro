import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import '../app_state.dart';

const mapBlue = Color(0xFF0A84FF);

class MapPal {
  final Color panel, line, text, sub;
  const MapPal(this.panel, this.line, this.text, this.sub);

  static MapPal of(BuildContext context) {
    final s = AppScope.of(context);
    if (s.text.computeLuminance() > 0.5) {
      return const MapPal(Color(0xE6141418), Color(0x80FFFFFF),
          Color(0xFFFFFFFF), Color(0xFFB8B8C2));
    }
    return const MapPal(Color(0xF2FFFFFF), Color(0xCC000000),
        Color(0xFF111111), Color(0xFF5A5A5F));
  }
}

class MapGlass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  const MapGlass({
    super.key,
    required this.child,
    this.radius = 22,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    final p = MapPal.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: p.panel,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: p.line, width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }
}

class MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool on;
  const MapBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.on = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = MapPal.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 48,
        child: MapGlass(
          radius: 24,
          padding: EdgeInsets.zero,
          child: Center(
            child: Icon(icon, size: 22, color: on ? mapBlue : p.text),
          ),
        ),
      ),
    );
  }
}

class MeDot extends StatelessWidget {
  const MeDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: mapBlue,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFFFFF), width: 3),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 6)],
      ),
    );
  }
}

class BottomScrim extends StatelessWidget {
  const BottomScrim({super.key});

  @override
  Widget build(BuildContext context) {
    final p = MapPal.of(context);
    final bp = MediaQuery.of(context).padding.bottom;
    return IgnorePointer(
      child: Container(
        height: 150 + bp,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [p.panel.withOpacity(0), p.panel],
          ),
        ),
      ),
    );
  }
}

class MapCredit extends StatelessWidget {
  final bool sat;
  const MapCredit({super.key, required this.sat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      color: const Color(0xCCFFFFFF),
      child: Text(
        sat
            ? '© Esri, Maxar, Earthstar Geographics'
            : '© OpenStreetMap contributors',
        style: const TextStyle(fontSize: 10, color: Color(0xFF000000)),
      ),
    );
  }
}
