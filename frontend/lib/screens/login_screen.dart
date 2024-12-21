// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import 'admin_dashboard.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  late final GoogleSignIn _googleSignIn;
  final ApiService _apiService = ApiService();
  bool _isSigningIn = false;
  String? _userName; // Store the user's name

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(
      clientId: kIsWeb
          ? "545461705793-3v0101rqbcp0hqkeiqt0ohca9me9d0b3.apps.googleusercontent.com"
          : null,
      scopes: ['email', 'profile', 'openid'],
    );
  }

  void _handleSignIn() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      final account = await _googleSignIn.signIn();

      if (account != null) {
        final auth = await account.authentication;
        String? idToken = auth.idToken;
        String? accessToken = auth.accessToken;

        if (idToken == null && accessToken == null) {
          throw Exception('Failed to obtain idToken or accessToken.');
        }

        // Store the user's name
        _userName = account.displayName ?? account.email;

        bool success = await _apiService.adminLogin(idToken ?? accessToken!);
        if (success) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminDashboard(userName: _userName),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).unauthorizedAccess)),
            );
          }
        }
      } else {
        // User canceled the sign-in
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).signInCanceled)),
          );
        }
      }
    } catch (error) {
      debugPrint('Login error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).loginFailed(error.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).login),
      ),
      body: Center(
        child: _isSigningIn
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF003058),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text(AppLocalizations.of(context).loginWithGoogle),
              ),
      ),
    );
  }
}
