import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/firestore_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => RegisterScreenState();

}

class RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _registerFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
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

  void _register() async {
    if (_registerFormKey.currentState!.validate()) {
      final name = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        var result = await ref.read(authRepositoryProvider).createUserWithEmailAndPassword(email, password);
        /*
        if(result != null) {
          AppUser newUser = AppUser(
            uid:
          );
          ref.read(firestoreRepositoryProvider).createUser();
        }*/
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
              key: _registerFormKey,
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
                        "Register",
                        style: GoogleFonts.robotoFlex(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        label: Text('User Name'),
                        hintText: 'Enter your name',
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
                          "Already have account? ",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        InkWell(
                          onTap:(){
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text(
                            "Login",
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
                          onPressed: () => _register, //TODO: Implement register action
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),//_register,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              'Register',
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