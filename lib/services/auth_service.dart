import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  // Sign up
  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return query.docs.isEmpty;
  }

  // Create user profile in Firestore
  Future<void> createUserProfile(
      String uid, String fullName, String username, String email) async {
    await _firestore.collection('users').doc(uid).set({
      'fullName': fullName,
      'username': username,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
