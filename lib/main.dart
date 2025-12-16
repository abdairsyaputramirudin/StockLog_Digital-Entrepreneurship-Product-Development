import 'package:flutter/material.dart';
import 'db/schema.dart';
import 'ui/app_theme.dart';
import 'screens/root_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDb();
  runApp(const StockLog2App());
}

class StockLog2App extends StatelessWidget {
  const StockLog2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockLog2',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme(),
      home: const RootShell(),
    );
  }
}
