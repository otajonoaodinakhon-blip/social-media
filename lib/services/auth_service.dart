import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  AppUser? _user;
  AppUser? get user => _user;

  AuthService() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUser(firebaseUser.uid);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = AppUser.fromMap(doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  Future<bool> register(String email, String password, String username) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final newUser = AppUser(
        uid: credential.user!.uid,
        username: username,
        email: email,
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('users').doc(credential.user!.uid).set(
        newUser.toMap()
      );
      
      _user = newUser;
      notifyListeners();
      return true;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? bio,
    String? location,
    String? avatar,
  }) async {
    if (_user == null) return;
    
    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        if (bio != null) 'bio': bio,
        if (location != null) 'location': location,
        if (avatar != null) 'avatar': avatar,
      });
      
      _user = AppUser.fromMap({
        ..._user!.toMap(),
        if (bio != null) 'bio': bio,
        if (location != null) 'location': location,
        if (avatar != null) 'avatar': avatar,
      });
      notifyListeners();
    } catch (e) {
      print('Update profile error: $e');
    }
  }

  Future<void> followUser(String targetUid) async {
    if (_user == null) return;
    
    try {
      await _firestore.collection('users').doc(targetUid).update({
        'followers': FieldValue.arrayUnion([_user!.uid]),
      });
      
      await _firestore.collection('users').doc(_user!.uid).update({
        'following': FieldValue.arrayUnion([targetUid]),
      });
      
      _user!.following.add(targetUid);
      notifyListeners();
    } catch (e) {
      print('Follow error: $e');
    }
  }

  Future<void> unfollowUser(String targetUid) async {
    if (_user == null) return;
    
    try {
      await _firestore.collection('users').doc(targetUid).update({
        'followers': FieldValue.arrayRemove([_user!.uid]),
      });
      
      await _firestore.collection('users').doc(_user!.uid).update({
        'following': FieldValue.arrayRemove([targetUid]),
      });
      
      _user!.following.remove(targetUid);
      notifyListeners();
    } catch (e) {
      print('Unfollow error: $e');
    }
  }
}
