import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoggedIn = false;
  String _currentUser = '';
  User? _firebaseUser;
  String? _verificationId;

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
      _currentUser =
          user?.displayName ?? user?.email ?? user?.phoneNumber ?? '';
      notifyListeners();
    });
  }

  // Phone Number Authentication - Send OTP
  Future<String> sendOTP(String phoneNumber) async {
    try {
      // For testing, check if this is a test number from Firebase Console
      if (phoneNumber == '+919500921707') {
        _verificationId = 'test_verification_id';
        return 'Test OTP sent successfully (use code 252224)';
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (mainly for Android)
          try {
            await _auth.signInWithCredential(credential);
            if (kDebugMode) print('Auto verification successful');
          } catch (e) {
            if (kDebugMode) print('Auto verification failed: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print('Phone verification failed: ${e.code} - ${e.message}');
          }
          throw Exception('Phone verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          if (kDebugMode) {
            print('OTP sent with verification ID: $verificationId');
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          if (kDebugMode) print('Auto retrieval timeout: $verificationId');
        },
        timeout: const Duration(seconds: 60),
      );
      return 'OTP sent successfully';
    } catch (e) {
      if (kDebugMode) print('Send OTP error: $e');
      throw Exception('Failed to send OTP: $e');
    }
  }

  // Phone Number Authentication - Verify OTP
  Future<bool> verifyOTP(String otpCode) async {
    try {
      if (_verificationId == null) {
        throw Exception('No verification in progress');
      }

      // Handle test verification
      if (_verificationId == 'test_verification_id') {
        if (otpCode == '252224') {
          // Create a mock user for testing
          _isLoggedIn = true;
          _currentUser = 'Test User (+91 95009 21707)';
          notifyListeners();
          return true;
        } else {
          throw Exception('Invalid test OTP. Use 252224');
        }
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      if (kDebugMode) {
        print('OTP verification successful: ${result.user?.phoneNumber}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('Verify OTP error: $e');
      throw Exception('Failed to verify OTP: $e');
    }
  }

  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    try {
      if (kDebugMode) print('Google Sign-In triggered');

      // Initialize Google Sign-In with scopes
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        if (kDebugMode) print('Google Sign-In canceled by user');
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      if (result.user != null) {
        if (kDebugMode) {
          print('Google Sign-In successful: ${result.user?.displayName}');
        }
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign-In Error: $e');
      }
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
