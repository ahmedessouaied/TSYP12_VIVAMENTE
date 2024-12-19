import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../bottom_navbar.dart';
import '../../widgets/widgets.dart';
import '../../structures/structs.dart' as structs;
import '../user_controller.dart';
import 'login.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return _loadingScreen();
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState != ConnectionState.done) {
                return _loadingScreen();
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final user = structs.User.fromFirestore(userSnapshot.data!);
                UserController().setUser(user); // Save user globally
                return const BottomNavbar();
              } else {
                return const LoginScreen();
              }
            }
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }

  Widget _loadingScreen() {
    return const Scaffold(
      body: Center(
        child: CustomLoadingScreen(
          message: "Loading",
        ),
      ),
    );
  }
}