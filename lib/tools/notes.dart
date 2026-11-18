import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import '../app_state.dart';
import '../chrome.dart';
import '../store.dart';
import '../ui_kit.dart';

const noteColors = [
  Color(0xFFFFB020),
  Color(0xFF4DA3FF),
  Color(0xFF2EE6A8),
  Color(0xFFFF4FA3),
  Color(0xFFB388FF),
  Color(0xFFFF6A4D),
];

String dateLabel(int ms) {
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  return '${d.day} ${m[d.month - 1]}';
}

class Note {
  String id;
  String title;
  String body;
  int color;
  bool pinned;
  int updated;
  Note({
    required this.id,
    this.title = '',
    this.body = '',
    this.color = 0,
    this.pinned = false,
    required this.updated,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'color': color,
        'pinned': pinned,
        'updated': updated,
      };

  factory Note.fromJson(Map<String, dynamic> j) => Note(
        id: j['id'] as String,
        title: (j['title'] ?? '') as String,
        body: (j['body'] ?? '') as String,
        color: (j['color'] ?? 0) as int,
        pinned: (j['pinned'] ?? false) as bool,
        updated: (j['updated'] ?? 0) as int,
      );
}

class NotesTool extends StatefulWidget {
  const NotesTool({super.key});

  @override
  State<NotesTool> createState() => _NotesToolState();
}

class _NotesToolState extends State<NotesTool> {
  List<Note> notes = [];
  String query = '';
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final raw = await Store.read('notes');
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        notes = [
          for (final e in list) Note.fromJson(Map<String, dynamic>.from(e as Map)),
        ];
      } catch (_) {}
    }
    if (mounted) setState(() => loaded = true);
  }

  Future<void> save() =>
      Store.write('notes', jsonEncode([for (final n in notes) n.toJson()]));

  List<Note> get visible {
    final q = query.toLowerCase();
    final l = notes
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.body.toLowerCase().contains(q))
        .toList();
    l.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.updated.compareTo(a.updated);
    });
    return l;
  }

  void open(Note n, {bool isNew = false}) {
    if (isNew) setState(() => notes.add(n));
    Navigator.of(context)
        .push(
          CupertinoPageRoute(
            builder: (_) => NoteEditor(
              note: n,
              onChanged: () {
                n.updated = DateTime.now().millisecondsSinceEpoch;
                if (mounted) setState(() {});
                save();
              },
              onDelete: () {
                if (mounted) setState(() => notes.remove(n));
                save();
              },
            ),
          ),
        )
        .then((_) {
      if (n.title.trim().isEmpty && n.body.trim().isEmpty) {
        if (mounted) setState(() => notes.remove(n));
        save();
      }
    });
  }

  void create() {
    HapticFeedback.mediumImpact();
    final now = DateTime.now().millisecondsSinceEpoch;
    open(
      Note(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        color: notes.length % noteColors.length,
        updated: now,
      ),
      isNew: true,
    );
  }

  Widget card(AppState s, Note n, int i) {
    final c = noteColors[n.color % noteColors.length];
    return FadeSlide(
      delay: (i * 50).clamp(0, 400).toInt(),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          open(n);
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.withOpacity(s.dark ? 0.22 : 0.35),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: c.withOpacity(0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      n.title.isEmpty ? 'Untitled' : n.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: s.text,
                      ),
                    ),
                  ),
                  if (n.pinned) Icon(Icons.push_pin, size: 16, color: c),
                ],
              ),
              if (n.body.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  n.body,
                  maxLines: 7,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: s.subText),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                dateLabel(n.updated),
                style: TextStyle(fontSize: 11, color: s.subText),
              ),
            ],
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
              radius: 36,
              padding: const EdgeInsets.all(28),
              child: Icon(
                Icons.sticky_note_2_outlined,
                size: 56,
                color: s.theme.accent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              query.isEmpty ? 'Koi note nahi hai' : 'Kuch nahi mila',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: s.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              query.isEmpty
                  ? 'Neeche + dabake pehla note likho'
                  : 'Doosra word try karo',
              style: TextStyle(fontSize: 14, color: s.subText),
            ),
          ],
        ),
      ),
    );
  }

  Widget addButton(AppState s) {
    return GestureDetector(
      onTap: create,
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [s.theme.accent, s.theme.c2]),
          boxShadow: [
            BoxShadow(
              color: s.theme.accent.withOpacity(0.55),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.add, size: 34, color: Color(0xFFFFFFFF)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final v = visible;
    final left = <Widget>[];
    final right = <Widget>[];
    for (var i = 0; i < v.length; i++) {
      (i.isEven ? left : right).add(card(s, v[i], i));
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
      child: Column(
        children: [
          FadeSlide(
            child: CupertinoSearchTextField(
              placeholder: 'Search notes',
              backgroundColor: s.glass,
              itemColor: s.subText,
              style: TextStyle(color: s.text),
              placeholderStyle: TextStyle(color: s.subText),
              onChanged: (t) => setState(() => query = t),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: !loaded
                      ? const Center(child: CupertinoActivityIndicator())
                      : (v.isEmpty
                          ? empty(s)
                          : SingleChildScrollView(
                              padding: const EdgeInsets.only(bottom: 96),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: Column(children: left)),
                                  const SizedBox(width: 12),
                                  Expanded(child: Column(children: right)),
                                ],
                              ),
                            )),
                ),
                Positioned(right: 4, bottom: 4, child: addButton(s)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NoteEditor extends StatefulWidget {
  final Note note;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  const NoteEditor({
    super.key,
    required this.note,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late final TextEditingController t =
      TextEditingController(text: widget.note.title);
  late final TextEditingController b =
      TextEditingController(text: widget.note.body);

  @override
  void dispose() {
    t.dispose();
    b.dispose();
    super.dispose();
  }

  void changed() {
    widget.note.title = t.text;
    widget.note.body = b.text;
    widget.onChanged();
    setState(() {});
  }

  void confirmDelete() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete note?'),
        content: const Text('Yeh note hamesha ke liye hat jaayega.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDelete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget roundIcon(AppState s, IconData icon, VoidCallback onTap, {Color? c}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        blur: true,
        radius: 24,
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, size: 24, color: c ?? s.text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final n = widget.note;
    final c = noteColors[n.color % noteColors.length];
    final words = RegExp(r'\S+').allMatches(b.text).length;
    return AuroraBackground(
      child: CupertinoPageScaffold(
        backgroundColor: const Color(0x00000000),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    const GlassBack(),
                    const Spacer(),
                    roundIcon(
                      s,
                      n.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                      () {
                        HapticFeedback.selectionClick();
                        n.pinned = !n.pinned;
                        changed();
                      },
                      c: n.pinned ? c : null,
                    ),
                    const SizedBox(width: 10),
                    roundIcon(s, Icons.delete_outline, confirmDelete),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: c.withOpacity(s.dark ? 0.18 : 0.3),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: c.withOpacity(0.6)),
                    ),
                    child: Column(
                      children: [
                        CupertinoTextField(
                          controller: t,
                          maxLines: 2,
                          decoration: const BoxDecoration(),
                          padding: EdgeInsets.zero,
                          cursorColor: c,
                          keyboardAppearance:
                              s.dark ? Brightness.dark : Brightness.light,
                          placeholder: 'Title',
                          placeholderStyle: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: s.subText,
                          ),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: s.text,
                          ),
                          onChanged: (_) => changed(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (var i = 0; i < noteColors.length; i++)
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  n.color = i;
                                  changed();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: noteColors[i],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: n.color == i
                                          ? s.text
                                          : const Color(0x33FFFFFF),
                                      width: n.color == i ? 3 : 1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(height: 1, color: c.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Expanded(
                          child: CupertinoTextField(
                            controller: b,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: const BoxDecoration(),
                            padding: EdgeInsets.zero,
                            cursorColor: c,
                            keyboardAppearance:
                                s.dark ? Brightness.dark : Brightness.light,
                            placeholder: 'Likhna shuru karo...',
                            placeholderStyle:
                                TextStyle(fontSize: 17, color: s.subText),
                            style: TextStyle(fontSize: 17, color: s.text),
                            onChanged: (_) => changed(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '$words words · ${b.text.length} characters',
                            style: TextStyle(fontSize: 12, color: s.subText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
