import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/app_user.dart';
import '../data/repository/firestore_repository.dart';
import '../data/models/task.dart';
import 'auth_provider.dart'; // Import to access authStateProvider

/// Provides an instance of FirestoreRepository
final firestoreRepositoryProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository();
});

/// Streams a list of tasks for the currently authenticated user
final userTasksProvider = StreamProvider<List<Task>>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) {
    return const Stream.empty();
  }

  final repository = ref.watch(firestoreRepositoryProvider);
  return repository.getUserTasks(user.uid);
});

final userProvider = FutureProvider.family<AppUser?, String>((ref, uid) {
  return ref.read(firestoreRepositoryProvider).getUser(uid);
});