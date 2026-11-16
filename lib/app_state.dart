import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';

class AppTheme {
  final String name;
  final Color c1;
  final Color c2;
  final Color accent;
  const AppTheme(this.name, this.c1, this.c2, this.accent);
}

const presetThemes = [
  AppTheme('Ocean Blue', Color(0xFF1E5BFF), Color(0xFF00C2FF), Color(0xFF4DA3FF)),
  AppTheme('Aurora', Color(0xFF7B2FF7), Color(0xFFFF4FA3), Color(0xFFC77DFF)),
  AppTheme('Mint', Color(0xFF00B894), Color(0xFF7CF5C8), Color(0xFF2EE6A8)),
  AppTheme('Sunset', Color(0xFFFF6A00), Color(0xFFFF2E63), Color(0xFFFFA44D)),
  AppTheme('Lavender', Color(0xFF6C5CE7), Color(0xFFA29BFE), Color(0xFFB8B0FF)),
  AppTheme('Forest', Color(0xFF134E4A), Color(0xFF2E8B57), Color(0xFF6EE7A0)),
  AppTheme('Candy', Color(0xFFFF5FA2), Color(0xFFFFB86C), Color(0xFFFF8FB8)),
  AppTheme('Midnight', Color(0xFF0F172A), Color(0xFF334155), Color(0xFF38BDF8)),
];

class AppState extends ChangeNotifier {
  AppTheme theme = presetThemes[0];
  bool dark = true;
  final Set<String> favorites = {'Calculator', 'Notes', 'Timer', 'Compass'};

  void setTheme(AppTheme t) {
    theme = t;
    notifyListeners();
  }

  void setDark(bool v) {
    dark = v;
    notifyListeners();
  }

  void toggleFavorite(String name) {
    if (!favorites.remove(name)) favorites.add(name);
    notifyListeners();
  }

  Color get text => dark ? const Color(0xFFFFFFFF) : const Color(0xFF14161F);
  Color get subText => text.withOpacity(0.65);
  Color get glass => dark ? const Color(0x1FFFFFFF) : const Color(0x99FFFFFF);
  Color get glassBorder =>
      dark ? const Color(0x33FFFFFF) : const Color(0xCCFFFFFF);

  List<Color> get bg {
    final base = dark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final t = dark ? 0.45 : 0.75;
    return [Color.lerp(theme.c1, base, t)!, Color.lerp(theme.c2, base, t)!];
  }
}

final appState = AppState();

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: s.bg,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  s.theme.accent.withOpacity(0.55),
                  s.theme.accent.withOpacity(0.0),
                ]),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final bool blur;
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.blur = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: s.glass,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: s.glassBorder),
      ),
      child: child,
    );
    if (!blur) return box;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: box,
      ),
    );
  }
}
