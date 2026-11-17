import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../ui_kit.dart';

class WordCountTool extends StatefulWidget {
  const WordCountTool({super.key});

  @override
  State<WordCountTool> createState() => _WordCountToolState();
}

class _WordCountToolState extends State<WordCountTool> {
  final c = TextEditingController();

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  String get t => c.text;
  int get words => RegExp(r'\S+').allMatches(t).length;
  int get noSpace => t.replaceAll(RegExp(r'\s'), '').length;

  int get sentences {
    if (t.trim().isEmpty) return 0;
    final n = RegExp(r'[.!?]+(\s|$)').allMatches(t.trim()).length;
    return n == 0 ? 1 : n;
  }

  int get paragraphs => t
      .split(RegExp(r'\n\s*\n'))
      .where((p) => p.trim().isNotEmpty)
      .length;

  Widget stat(AppState s, String label, double v,
      {int decimals = 0, String suffix = ''}) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: s.subText)),
              const SizedBox(height: 4),
              AnimNum(
                value: v,
                decimals: decimals,
                suffix: suffix,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: s.theme.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget gap() => const SizedBox(width: 12, height: 12);

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        FadeSlide(
          child: Row(
            children: [
              stat(s, 'Words', words.toDouble()),
              gap(),
              stat(s, 'Characters', t.length.toDouble()),
            ],
          ),
        ),
        gap(),
        FadeSlide(
          delay: 70,
          child: Row(
            children: [
              stat(s, 'No spaces', noSpace.toDouble()),
              gap(),
              stat(s, 'Sentences', sentences.toDouble()),
            ],
          ),
        ),
        gap(),
        FadeSlide(
          delay: 140,
          child: Row(
            children: [
              stat(s, 'Paragraphs', paragraphs.toDouble()),
              gap(),
              stat(s, 'Reading time', words / 200,
                  decimals: 1, suffix: ' min'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FadeSlide(
          delay: 200,
          child: Row(
            children: [
              Pill(
                label: 'Paste',
                on: false,
                onTap: () async {
                  final d = await Clipboard.getData(Clipboard.kTextPlain);
                  if (d?.text != null && mounted) {
                    c.text = d!.text!;
                    setState(() {});
                  }
                },
              ),
              const SizedBox(width: 8),
              Pill(
                label: 'Clear',
                on: false,
                onTap: () => setState(() => c.clear()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FadeSlide(
          delay: 260,
          child: GlassCard(
            radius: 24,
            child: CupertinoTextField(
              controller: c,
              maxLines: null,
              minLines: 7,
              keyboardAppearance: s.dark ? Brightness.dark : Brightness.light,
              decoration: const BoxDecoration(),
              padding: EdgeInsets.zero,
              cursorColor: s.theme.accent,
              placeholder: 'Yahan likho ya paste karo...',
              placeholderStyle: TextStyle(fontSize: 17, color: s.subText),
              style: TextStyle(fontSize: 17, color: s.text),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
      ],
    );
  }
}
