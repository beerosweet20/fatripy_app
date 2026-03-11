import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign up
  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password reset
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
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
    String uid,
    String fullName,
    String username,
    String email,
  ) async {
    await _firestore.collection('users').doc(uid).set({
      'fullName': fullName,
      'username': username,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Admin access is determined strictly from Firebase custom claims.
  /// Firestore `role` fields are not used for authorization decisions.
  Future<bool> isAdmin({User? user, bool forceRefresh = false}) async {
    final resolvedUser = user ?? _auth.currentUser;
    if (resolvedUser == null) {
      return false;
    }
    final token = await resolvedUser.getIdTokenResult(forceRefresh);
    return token.claims?['admin'] == true;
  }

  Future<void> updateProfile({String? fullName, String? email}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final normalizedName = fullName?.trim();
    final normalizedEmail = email?.trim();

    if (normalizedName != null &&
        normalizedName.isNotEmpty &&
        normalizedName != (user.displayName ?? '').trim()) {
      await user.updateDisplayName(normalizedName);
    }

    if (normalizedEmail != null &&
        normalizedEmail.isNotEmpty &&
        normalizedEmail != user.email) {
      await user.updateEmail(normalizedEmail);
    }

    final updates = <String, dynamic>{};
    if (normalizedName != null && normalizedName.isNotEmpty) {
      updates['fullName'] = normalizedName;
    }
    if (normalizedEmail != null && normalizedEmail.isNotEmpty) {
      updates['email'] = normalizedEmail;
    }

    if (updates.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(updates, SetOptions(merge: true));
    }

    await user.reload();
  }

  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }
}
