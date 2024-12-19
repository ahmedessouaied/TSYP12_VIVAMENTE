import 'package:b_bot/bottom_navbar.dart';
import 'package:b_bot/controllers/user_control/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "../../structures/structs.dart" as structs;
import "../user_controller.dart";

import '../../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserController _userManager = UserController();
  bool _isObscure = true;

  String errorMessage = '';


  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      String firstName = '';
      String middleName = '';
      String lastName = '';

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        List<String> nameParts = user.displayName!.split(' ');
        if (nameParts.length == 1) {
          firstName = nameParts[0];
        } else if (nameParts.length == 2) {
          firstName = nameParts[0];
          lastName = nameParts[1];
        } else if (nameParts.length == 3) {
          firstName = nameParts[0];
          middleName = nameParts[1];
          lastName = nameParts[2];
        } else if (nameParts.length > 3) {
          firstName = nameParts[0];
          lastName = nameParts.last;
          middleName = nameParts.sublist(1, nameParts.length - 1).join(' ');
        }

        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {

          structs.User newUser = structs.User(
            uid: user.uid,
            displayName: user.displayName ?? '',
            firstName: firstName,
            middleName: middleName,
            lastName: lastName,
            email: user.email ?? '',
            createdAt: DateTime.now(),
            profileImage: user.photoURL ?? '',
            phoneNumber: "12345678",
            birthdate: DateTime(2000, 1, 1),
            gender: 'other',
          );

          await FirebaseFirestore.instance.collection('users').doc(user.uid).set(newUser.toFirestore());
          _userManager.setUser(newUser);
        }
        if (userDoc.exists){
          _userManager.setUser(structs.User.fromFirestore(userDoc));
          navigateToHomePage();
        }
      } else {
        if(mounted) showSnackBar(context, "No User Found");
        return;
      }
    } catch (e) {
      if(mounted) showSnackBar(context, "Error occurred during Google Sign-In: $e");
    }
  }

  void navigateToHomePage() {
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => const BottomNavbar()),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            heightFactor: 1.2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                    width: 150,
                  ),
                  Text(
                    'Welcome Back!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                        child: Text(
                          "Don't have an account? Sign up",
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,

                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _login,
                    style: theme.elevatedButtonTheme.style?.copyWith(
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: Image.asset('assets/icons/google_logo.png', height: 24),
                    label: Text(
                      'Sign in with Google',
                      style: theme.textTheme.titleMedium,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.cardColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    try {
      final user = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.user!.uid).get();
      if (userDoc.exists) {
        _userManager.setUser(structs.User.fromFirestore(userDoc));
      } else {
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SignupScreen()),
        );
        return;
      }
      navigateToHomePage();
    } on FirebaseAuthException catch (e) {
      if(mounted) showSnackBar(context, "Error occurred during login: $e");
    }
  }
}