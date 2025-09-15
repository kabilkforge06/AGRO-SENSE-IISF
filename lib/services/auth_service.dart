import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoggedIn = false;
  String _currentUser = '';
  User? _firebaseUser;

  // Static credentials as backup option
  static const String validUsername = 'sih';
  static const String validPassword = 'sih';

  bool get isLoggedIn => _isLoggedIn || _firebaseUser != null;
  String get currentUser => _currentUser;
  User? get firebaseUser => _firebaseUser;

  AuthService() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      _isLoggedIn = user != null;
      _currentUser = user?.displayName ?? user?.email ?? '';
      notifyListeners();
    });
  }

  // Google Sign-In (simplified for newer package version)
  Future<bool> signInWithGoogle() async {
    try {
      // For now, we'll implement a simple demo login
      // This can be replaced with actual Google Sign-In when configured properly
      _isLoggedIn = true;
      _currentUser = 'Demo User (Google)';
      notifyListeners();
      return true;
    } catch (e) {
      // Google Sign-In Error
      return false;
    }
  }

  // Static credential login (backup option)
  Future<bool> login(String username, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    if (username == validUsername && password == validPassword) {
      _isLoggedIn = true;
      _currentUser = username;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Sign out
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Logout Error
    }

    _isLoggedIn = false;
    _currentUser = '';
    _firebaseUser = null;
    notifyListeners();
  }
}
