import 'package:flutter/cupertino.dart';
import 'app_state.dart';
import 'tools/bmi.dart';
import 'tools/calculator.dart';
import 'tools/percentage.dart';
import 'tools/scientific.dart';

class ToolPage extends StatelessWidget {
  final String title;
  final Widget child;
  const ToolPage({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return GradientBackground(
      child: CupertinoPageScaffold(
        backgroundColor: const Color(0x00000000),
        navigationBar: CupertinoNavigationBar(
          backgroundColor: const Color(0x00000000),
          border: null,
          middle: Text(title, style: TextStyle(color: s.text)),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}

bool openTool(BuildContext context, String name) {
  final Widget? page = switch (name) {
    'Calculator' => const CalculatorTool(),
    'Scientific' => const ScientificTool(),
    'Percentage' => const PercentageTool(),
    'BMI' => const BmiTool(),
    _ => null,
  };
  if (page == null) return false;
  Navigator.of(context).push(
    CupertinoPageRoute(builder: (_) => ToolPage(title: name, child: page)),
  );
  return true;
}
