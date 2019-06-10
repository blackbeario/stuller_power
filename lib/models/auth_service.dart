import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AuthService with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _db = Firestore.instance;

  Future<FirebaseUser> get getUser => _auth.currentUser();
  Stream<FirebaseUser> get user => _auth.onAuthStateChanged;

  Future<FirebaseUser> signIn(String email, String password) async {
    try {
      FirebaseUser user = await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      updateUserData(user);
      return user;
    } catch (error) {
      notifyListeners();
      print(error);
      return null;
    }
  }

  Future signOut() async {
    notifyListeners();
    return _auth.signOut();
  }

  Future<void> updateUserData(FirebaseUser user) async {
    DocumentReference userRef = _db.collection('users').document(user.uid);
    
    return userRef.setData({
      'uid': user.uid,
      'lastActivity': DateTime.now()
    }, merge: true);
  }
}