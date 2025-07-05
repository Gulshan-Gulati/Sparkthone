import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // To show error messages as SnackBars

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register a new user with email and password
  Future<User?> createUserWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, context);
    } catch (e) {
      _showSnackBar("Something went wrong.", context);
    }
    return null;
  }

  // Log in an existing user with email and password
  Future<User?> logUserWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      final UserCredential cred =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, context);
    } catch (e) {
      _showSnackBar("Something went wrong.", context);
    }
    return null;
  }

  // Sign out the current user
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
    } catch (e) {
      _showSnackBar("Sign out failed. Please try again.", context);
    }
  }

  // Handle authentication error messages
  void _handleAuthError(FirebaseAuthException e, BuildContext context) {
    String message = "";
    switch (e.code) {
      case 'invalid-email':
        message = "The email address is badly formatted.";
        break;
      case 'email-already-in-use':
        message = "The email is already in use.";
        break;
      case 'wrong-password':
        message = "The password is incorrect.";
        break;
      case 'user-not-found':
        message = "No user found with this email.";
        break;
      default:
        message = "An unknown error occurred.";
    }
    _showSnackBar(message, context);
  }

  // Show a SnackBar for user feedback
  void _showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
