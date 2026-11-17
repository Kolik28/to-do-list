import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Daylist',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      );
}
