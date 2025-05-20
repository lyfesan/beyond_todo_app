  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:beyond_todo_app/data/repository/auth_repository.dart';

  final authRepositoryProvider = Provider<AuthRepository>((ref) {
    return AuthRepository(FirebaseAuth.instance);
  });

  final authStateProvider = StreamProvider<User?>((ref) {
    return ref.read(authRepositoryProvider).authStateChange;
  });