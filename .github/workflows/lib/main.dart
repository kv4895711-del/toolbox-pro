import 'package:flutter/cupertino.dart';

void main() => runApp(const ToolboxApp());

class ToolboxApp extends StatelessWidget {
  const ToolboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Toolbox Pro',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.activeBlue,
      ),
      home: HomePage(),
    );
  }
}

class Tool {
  final String name;
  final IconData icon;
  const Tool(this.name, this.icon);
}

const tools = [
  Tool('Calculator', CupertinoIcons.plus_slash_minus),
  Tool('Converter', CupertinoIcons.arrow_right_arrow_left),
  Tool('Notes', CupertinoIcons.doc_text),
  Tool('Timer', CupertinoIcons.timer),
  Tool('QR Scanner', CupertinoIcons.qrcode),
  Tool('Compass', CupertinoIcons.compass),
  Tool('Maps', CupertinoIcons.map),
  Tool('AI Assistant', CupertinoIcons.chat_bubble_2),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final list = tools
        .where((t) => t.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Toolbox Pro'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: CupertinoSearchTextField(
                placeholder: 'Search tools',
                onChanged: (v) => setState(() => query = v),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => ToolCard(tool: list[i]),
                childCount: list.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ToolCard extends StatelessWidget {
  final Tool tool;
  const ToolCard({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(tool.name),
          content: const Text('Jaldi aa raha hai'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tool.icon, size: 36, color: CupertinoColors.activeBlue),
            const SizedBox(height: 10),
            Text(tool.name, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
