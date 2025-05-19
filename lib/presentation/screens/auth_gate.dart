import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyond_todo_app/providers/auth_provider.dart';
import 'home_screen.dart';
import 'login.dart';

class AuthGate extends ConsumerWidget {
  final Widget loadingBuilder;

  const AuthGate({
    super.key,
    this.loadingBuilder = const Scaffold(body: Center(child: CircularProgressIndicator())),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
      loading: () => loadingBuilder,
      error: (error, stackTrace) => Center(child: Text('Error: $error')), // Handle error appropriately
    );
  }
}