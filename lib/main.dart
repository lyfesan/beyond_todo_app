import 'package:beyond_todo_app/presentation/screens/auth_gate.dart';
import 'package:beyond_todo_app/presentation/screens/home_screen.dart';
import 'package:beyond_todo_app/presentation/screens/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:beyond_todo_app/presentation/screens/login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/themes/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Beyond Todo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthGate(),
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      }
    );
  }
}