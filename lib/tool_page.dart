import 'package:flutter/cupertino.dart';
import 'app_state.dart';
import 'chrome.dart';
import 'tools/age.dart';
import 'tools/bmi.dart';
import 'tools/calculator.dart';
import 'tools/converter.dart';
import 'tools/discount.dart';
import 'tools/emi.dart';
import 'tools/notes.dart';
import 'tools/password.dart';
import 'tools/percentage.dart';
import 'tools/scientific.dart';
import 'tools/stopwatch.dart';
import 'tools/timer.dart';
import 'tools/todo.dart';
import 'tools/wordcount.dart';

class ToolPage extends StatelessWidget {
  final String title;
  final Widget child;
  const ToolPage({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return AuroraBackground(
      child: CupertinoPageScaffold(
        backgroundColor: const Color(0x00000000),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: const [
                    GlassBack(),
                    Expanded(child: Center(child: BrandMark())),
                    SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 12),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: s.text,
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
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
    'Age' => const AgeTool(),
    'Discount' => const DiscountTool(),
    'EMI' => const EmiTool(),
    'Converter' => const ConverterTool(),
    'Password' => const PasswordTool(),
    'Word Counter' => const WordCountTool(),
    'Timer' => const TimerTool(),
    'Stopwatch' => const StopwatchTool(),
    'Notes' => const NotesTool(),
    'To-Do' => const TodoTool(),
    _ => null,
  };
  if (page == null) return false;
  Navigator.of(context).push(
    CupertinoPageRoute(builder: (_) => ToolPage(title: name, child: page)),
  );
  return true;
}
