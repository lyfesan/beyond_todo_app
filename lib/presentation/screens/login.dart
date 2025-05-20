import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:beyond_todo_app/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => LoginScreenState();

}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();// Dispose when the widget is removed
    super.dispose();
  }

  void _showSnackBarError({String? message, Object? e}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message : ${e.toString()}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  void _login() async {
    if (_loginFormKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        await ref.read(authRepositoryProvider).signInWithEmailAndPassword(email, password);
        // On successful login, authStateProvider will emit the user,
        // and AuthGate will navigate to HomeScreen.
      } catch (e) {
        // Handle login errors (show a SnackBar, dialog, or update UI)
        _showSnackBarError(message: "Login failed", e: e);
        _emailController.clear();
        _passwordController.clear();
        //print("Login failed: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: SingleChildScrollView(
            child: Form(
              key: _loginFormKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                          'assets/beyond_todo_logo.png',
                          width: min(MediaQuery.of(context).size.width * 0.5, 250)
                      ),
                    ),
                    SizedBox(height: 64),
                    Center(
                      child: Text(
                        "Login",
                        style: GoogleFonts.robotoFlex(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        label: Text('Email'),
                        hintText: 'Enter your email',
                        filled: true,
                        fillColor: Colors.grey[100],
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      cursorColor: Theme.of(context).colorScheme.primary,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      decoration: InputDecoration(
                        label: Text('Password'),
                        hintText: 'Enter your password',
                        filled: true,
                        fillColor: Colors.grey[100],
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      cursorColor: Theme.of(context).colorScheme.primary,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Don't have account? ",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            Navigator.pushReplacementNamed(context, '/register');
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]
                    ),
                    SizedBox(height: 32),
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),//_login,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}