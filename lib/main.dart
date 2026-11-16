import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'app_state.dart';

void main() => runApp(AppScope(state: appState, child: const ToolboxApp()));

class ToolboxApp extends StatelessWidget {
  const ToolboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return CupertinoApp(
      title: 'Toolbox Pro',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: s.dark ? Brightness.dark : Brightness.light,
        primaryColor: s.theme.accent,
      ),
      home: const RootPage(),
    );
  }
}

class Tool {
  final String name;
  final IconData icon;
  Tool(this.name, this.icon);
}

final allTools = [
  Tool('Calculator', PhosphorIconsLight.calculator),
  Tool('Scientific', PhosphorIconsLight.atom),
  Tool('Percentage', PhosphorIconsLight.percent),
  Tool('BMI', PhosphorIconsLight.heartbeat),
  Tool('Age', PhosphorIconsLight.cake),
  Tool('Discount', PhosphorIconsLight.tag),
  Tool('EMI', PhosphorIconsLight.bank),
  Tool('Converter', PhosphorIconsLight.ruler),
  Tool('Currency', PhosphorIconsLight.currencyDollar),
  Tool('Timer', PhosphorIconsLight.timer),
  Tool('Stopwatch', PhosphorIconsLight.hourglass),
  Tool('World Clock', PhosphorIconsLight.globe),
  Tool('Alarm', PhosphorIconsLight.alarm),
  Tool('Notes', PhosphorIconsLight.notepad),
  Tool('To-Do', PhosphorIconsLight.checkSquare),
  Tool('QR Scanner', PhosphorIconsLight.scan),
  Tool('QR Maker', PhosphorIconsLight.qrCode),
  Tool('Compass', PhosphorIconsLight.compass),
  Tool('Flashlight', PhosphorIconsLight.flashlight),
  Tool('Level', PhosphorIconsLight.crosshair),
  Tool('Password', PhosphorIconsLight.lockKey),
  Tool('Word Counter', PhosphorIconsLight.textAa),
  Tool('Recorder', PhosphorIconsLight.microphone),
];

void showSoon(BuildContext context, String name) {
  showCupertinoDialog(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(name),
      content: const Text('Yeh tool jaldi aa raha hai'),
      actions: [
        CupertinoDialogAction(
          child: const Text('OK'),
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeTab(),
      ComingSoon(title: 'Maps', icon: PhosphorIconsLight.mapTrifold),
      ComingSoon(title: 'AI Assistant', icon: PhosphorIconsLight.sparkle),
      const SettingsTab(),
    ];
    return GradientBackground(
      child: CupertinoPageScaffold(
        backgroundColor: const Color(0x00000000),
        child: Stack(
          children: [
            Positioned.fill(child: IndexedStack(index: tab, children: pages)),
            Positioned(
              left: 20,
              right: 20,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BottomBar(
                    index: tab,
                    onTap: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => tab = i);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const BottomBar({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final icons = [
      PhosphorIconsLight.house,
      PhosphorIconsLight.mapTrifold,
      PhosphorIconsLight.sparkle,
      PhosphorIconsLight.gearSix,
    ];
    const labels = ['Home', 'Maps', 'AI', 'Settings'];
    return GlassCard(
      blur: true,
      radius: 30,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: List.generate(4, (i) {
          final on = i == index;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: on
                      ? s.theme.accent.withOpacity(0.28)
                      : const Color(0x00000000),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icons[i], size: 26, color: on ? s.text : s.subText),
                    const SizedBox(height: 2),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 11,
                        color: on ? s.text : s.subText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String query = '';

  Widget sectionTitle(AppState s, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: s.text,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final q = query.toLowerCase();
    final shown =
        allTools.where((t) => t.name.toLowerCase().contains(q)).toList();
    final favs =
        allTools.where((t) => s.favorites.contains(t.name)).toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello 👋',
                      style: TextStyle(fontSize: 16, color: s.subText)),
                  Text(
                    'Toolbox Pro',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: s.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CupertinoSearchTextField(
                placeholder: 'Search tools',
                backgroundColor: s.glass,
                itemColor: s.subText,
                style: TextStyle(color: s.text),
                placeholderStyle: TextStyle(color: s.subText),
                onChanged: (v) => setState(() => query = v),
              ),
            ),
          ),
          if (query.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: BigCard(
                        title: 'Calculator',
                        subtitle: 'Quick math',
                        icon: PhosphorIconsLight.calculator,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BigCard(
                        title: 'AI Assistant',
                        subtitle: 'Ask anything',
                        icon: PhosphorIconsLight.sparkle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (query.isEmpty && favs.isNotEmpty)
            SliverToBoxAdapter(child: sectionTitle(s, 'Favorites')),
          if (query.isEmpty && favs.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 116,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    for (final t in favs)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SizedBox(width: 92, child: ToolTile(tool: t)),
                      ),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(child: sectionTitle(s, 'All tools')),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 116,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => ToolTile(tool: shown[i]),
                childCount: shown.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const BigCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showSoon(context, title);
      },
      child: GlassCard(
        blur: true,
        radius: 26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: s.theme.accent,
              ),
              child: Icon(icon, size: 26, color: const Color(0xFFFFFFFF)),
            ),
            const SizedBox(height: 26),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: s.text,
              ),
            ),
            Text(subtitle, style: TextStyle(fontSize: 13, color: s.subText)),
          ],
        ),
      ),
    );
  }
}

class ToolTile extends StatelessWidget {
  final Tool tool;
  const ToolTile({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final fav = s.favorites.contains(tool.name);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showSoon(context, tool.name);
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        s.toggleFavorite(tool.name);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GlassCard(
                radius: 20,
                padding: const EdgeInsets.all(16),
                child: Icon(tool.icon, size: 30, color: s.text),
              ),
              if (fav)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Icon(
                    PhosphorIconsFill.heart,
                    size: 16,
                    color: s.theme.accent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tool.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: s.text),
          ),
        ],
      ),
    );
  }
}

class ComingSoon extends StatelessWidget {
  final String title;
  final IconData icon;
  const ComingSoon({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassCard(
            radius: 32,
            padding: const EdgeInsets.all(28),
            child: Icon(icon, size: 48, color: s.text),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: s.text,
            ),
          ),
          const SizedBox(height: 4),
          Text('Jaldi aa raha hai', style: TextStyle(color: s.subText)),
        ],
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: s.text,
            ),
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Row(
              children: [
                Icon(PhosphorIconsLight.moon, color: s.text),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dark mode',
                    style: TextStyle(fontSize: 17, color: s.text),
                  ),
                ),
                CupertinoSwitch(value: s.dark, onChanged: s.setDark),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'Themes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: s.text,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 16,
            children: [
              for (final t in presetThemes) ThemeChip(theme: t),
              GestureDetector(
                onTap: () => showCupertinoModalPopup(
                  context: context,
                  builder: (_) => const CustomThemeSheet(),
                ),
                child: SizedBox(
                  width: 76,
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: s.glass,
                          border: Border.all(color: s.glassBorder),
                        ),
                        child: Icon(PhosphorIconsLight.plus, color: s.text),
                      ),
                      const SizedBox(height: 6),
                      Text('Custom',
                          style: TextStyle(fontSize: 12, color: s.text)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ThemeChip extends StatelessWidget {
  final AppTheme theme;
  const ThemeChip({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final selected = s.theme == theme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        s.setTheme(theme);
      },
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.c1, theme.c2],
                ),
                border: Border.all(
                  color: selected ? s.text : s.glassBorder,
                  width: selected ? 3 : 1,
                ),
              ),
              child: selected
                  ? const Icon(PhosphorIconsLight.check,
                      color: Color(0xFFFFFFFF))
                  : null,
            ),
            const SizedBox(height: 6),
            Text(theme.name,
                maxLines: 1, style: TextStyle(fontSize: 12, color: s.text)),
          ],
        ),
      ),
    );
  }
}

final swatches = [
  const Color(0xFF1E5BFF),
  const Color(0xFF00C2FF),
  const Color(0xFF00B894),
  const Color(0xFF7CF5C8),
  const Color(0xFF7B2FF7),
  const Color(0xFFFF4FA3),
  const Color(0xFFFF6A00),
  const Color(0xFFFF2E63),
  const Color(0xFFFFC300),
  const Color(0xFF111827),
  const Color(0xFF334155),
  const Color(0xFFFFFFFF),
];

class ColorRow extends StatelessWidget {
  final String label;
  final Color value;
  final ValueChanged<Color> onPick;
  final Color textColor;
  const ColorRow({
    super.key,
    required this.label,
    required this.value,
    required this.onPick,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 15, color: textColor)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final c in swatches)
              GestureDetector(
                onTap: () => onPick(c),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: c == value ? textColor : const Color(0x33888888),
                      width: c == value ? 3 : 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class CustomThemeSheet extends StatefulWidget {
  const CustomThemeSheet({super.key});

  @override
  State<CustomThemeSheet> createState() => _CustomThemeSheetState();
}

class _CustomThemeSheetState extends State<CustomThemeSheet> {
  late Color c1;
  late Color c2;
  late Color accent;

  @override
  void initState() {
    super.initState();
    c1 = appState.theme.c1;
    c2 = appState.theme.c2;
    accent = appState.theme.accent;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final sheetColor =
        s.dark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    return DefaultTextStyle(
      style: TextStyle(
        color: s.text,
        fontSize: 15,
        decoration: TextDecoration.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: SafeArea(
          top: false,
          child: Colum
