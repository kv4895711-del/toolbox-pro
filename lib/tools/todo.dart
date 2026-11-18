import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../store.dart';
import '../ui_kit.dart';

const prioColors = [Color(0xFF2EE6A8), Color(0xFFFFB020), Color(0xFFFF4D5E)];
const prioNames = ['Low', 'Medium', 'High'];

class Task {
  String id;
  String text;
  bool done;
  int prio;
  Task({
    required this.id,
    required this.text,
    this.done = false,
    this.prio = 1,
  });

  Map<String, dynamic> toJson() =>
      {'id': id, 'text': text, 'done': done, 'prio': prio};

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as String,
        text: j['text'] as String,
        done: (j['done'] ?? false) as bool,
        prio: (j['prio'] ?? 1) as int,
      );
}

class TodoTool extends StatefulWidget {
  const TodoTool({super.key});

  @override
  State<TodoTool> createState() => _TodoToolState();
}

class _TodoToolState extends State<TodoTool> {
  List<Task> tasks = [];
  int filter = 0;
  int prio = 1;
  bool loaded = false;
  final input = TextEditingController();
  final focus = FocusNode();

  @override
  void initState() {
    super.initState();
    focus.addListener(() {
      if (mounted) setState(() {});
    });
    load();
  }

  @override
  void dispose() {
    input.dispose();
    focus.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final raw = await Store.read('todo');
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        tasks = [
          for (final e in list) Task.fromJson(Map<String, dynamic>.from(e as Map)),
        ];
      } catch (_) {}
    }
    if (mounted) setState(() => loaded = true);
  }

  Future<void> save() =>
      Store.write('todo', jsonEncode([for (final t in tasks) t.toJson()]));

  List<Task> get visible {
    final l = tasks
        .where((t) => filter == 0 || (filter == 1 ? !t.done : t.done))
        .toList();
    if (filter == 0) {
      return [...l.where((t) => !t.done), ...l.where((t) => t.done)];
    }
    return l;
  }

  void add() {
    final txt = input.text.trim();
    if (txt.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() {
      tasks.insert(
        0,
        Task(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: txt,
          prio: prio,
        ),
      );
      input.clear();
    });
    save();
  }

  void toggle(Task t) {
    HapticFeedback.selectionClick();
    setState(() => t.done = !t.done);
    save();
  }

  void clearDone() {
    HapticFeedback.mediumImpact();
    setState(() => tasks.removeWhere((t) => t.done));
    save();
  }

  String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget hero(AppState s) {
    final total = tasks.length;
    final done = tasks.where((t) => t.done).length;
    final frac = total == 0 ? 0.0 : done / total;
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (r) => LinearGradient(
              colors: [s.theme.accent, s.theme.c2],
            ).createShader(r),
            child: AnimNum(
              value: frac * 100,
              suffix: '%',
              style: const TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting(),
                  style: TextStyle(fontSize: 14, color: s.subText),
                ),
                const SizedBox(height: 2),
                Text(
                  total == 0 ? 'Koi task nahi' : '$done of $total done',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: s.text,
                  ),
                ),
                const SizedBox(height: 12),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: frac),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Container(
                    height: 10,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: s.glass,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget filters(AppState s) {
    const names = ['All', 'Active', 'Done'];
    final doneCount = tasks.where((t) => t.done).length;
    return Row(
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Pill(
              label: names[i],
              on: filter == i,
              onTap: () => setState(() => filter = i),
            ),
          ),
        const Spacer(),
        if (doneCount > 0)
          GestureDetector(
            onTap: clearDone,
            child: Text(
              'Clear done',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: s.theme.accent,
              ),
            ),
          ),
      ],
    );
  }

  Widget item(AppState s, Task t) {
    return Dismissible(
      key: ValueKey(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0x66FF4D5E),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_outline, color: Color(0xFFFFFFFF)),
      ),
      onDismissed: (_) {
        setState(() => tasks.removeWhere((x) => x.id == t.id));
        save();
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () => toggle(t),
          child: GlassCard(
            radius: 22,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.done ? s.theme.accent : const Color(0x00000000),
                    border: Border.all(
                      color: t.done ? s.theme.accent : s.subText,
                      width: 2,
                    ),
                  ),
                  child: AnimatedScale(
                    scale: t.done ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    child: const Icon(
                      Icons.check,
                      size: 18,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      fontSize: 16,
                      color: t.done ? s.subText : s.text,
                      decoration:
                          t.done ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                    child: Text(t.text),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: prioColors[t.prio],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget empty(AppState s) {
    return Center(
      child: FadeSlide(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassCard(
              radius: 34,
              padding: const EdgeInsets.all(26),
              child: Icon(Icons.task_alt, size: 54, color: s.theme.accent),
            ),
            const SizedBox(height: 16),
            Text(
              filter == 2 ? 'Abhi koi task complete nahi' : 'Sab clear! 🎉',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: s.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Neeche se naya task add karo',
              style: TextStyle(fontSize: 14, color: s.subText),
            ),
          ],
        ),
      ),
    );
  }

  Widget inputBar(AppState s) {
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => prio = (prio + 1) % 3);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: prioColors[prio].withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: prioColors[prio]),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: prioColors[prio],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    prioNames[prio],
                    style: TextStyle(fontSize: 12, color: s.text),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CupertinoTextField(
              controller: input,
              focusNode: focus,
              decoration: const BoxDecoration(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              cursorColor: s.theme.accent,
              keyboardAppearance: s.dark ? Brightness.dark : Brightness.light,
              textInputAction: TextInputAction.done,
              placeholder: 'Naya task likho...',
              placeholderStyle: TextStyle(fontSize: 16, color: s.subText),
              style: TextStyle(fontSize: 16, color: s.text),
              onSubmitted: (_) => add(),
            ),
          ),
          GestureDetector(
            onTap: add,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [s.theme.accent, s.theme.c2]),
              ),
              child: const Icon(Icons.add, color: Color(0xFFFFFFFF)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final v = visible;
    final typing = focus.hasFocus;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
      child: Column(
        children: [
          if (!typing) ...[
            FadeSlide(child: hero(s)),
            const SizedBox(height: 12),
            FadeSlide(delay: 70, child: filters(s)),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: !loaded
                ? const Center(child: CupertinoActivityIndicator())
                : (v.isEmpty
                    ? empty(s)
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: v.length,
                        itemBuilder: (context, i) => item(s, v[i]),
                      )),
          ),
          const SizedBox(height: 10),
          FadeSlide(delay: 140, child: inputBar(s)),
        ],
      ),
    );
  }
}
