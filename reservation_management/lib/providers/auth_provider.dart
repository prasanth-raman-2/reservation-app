import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

/// Provider for the auth service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for the current user
final authUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for the current user ID
final userIdProvider = Provider<String?>((ref) {
  final authUser = ref.watch(authUserProvider);
  return authUser.when(
    data: (user) => user?.uid,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Notifier class for managing authentication state
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      await _authService.signInWithEmailAndPassword(email, password);
      // State will be updated by the listener
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Create a new user with email and password
  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      state = const AsyncValue.loading();
      await _authService.createUserWithEmailAndPassword(email, password);
      // State will be updated by the listener
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      state = const AsyncValue.loading();
      await _authService.signOut();
      // State will be updated by the listener
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// Provider for the auth notifier
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
