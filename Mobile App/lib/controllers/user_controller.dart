import 'package:b_bot/controllers/websocket_controller.dart';

import '../structures/structs.dart' as structs;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserController {
  static final UserController _instance = UserController._internal();

  factory UserController() => _instance;

  UserController._internal();

  structs.User? _currentUser;

  structs.User? get currentUser => _currentUser;

  void setUser(structs.User user) {
    _currentUser = user;
  }

  void reloadUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((snapshot) {
        if (snapshot.exists) {
          final user = structs.User.fromFirestore(snapshot);
          setUser(user);
        }
      }).then((_) {
        SocketIOController().reconnect();
      });
    }
  }

  void signOut() {
    try{
      FirebaseAuth.instance.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
