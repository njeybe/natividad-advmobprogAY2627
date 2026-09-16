import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import '../constant.dart';
import '../models/user.dart';

ValueNotifier<UserService> userService = ValueNotifier(UserService());

/// Enum to distinguish between DummyJSON REST auth and Firebase Authentication
enum LoginType { dummyJson, firebase }

class UserService {
  Map<String, dynamic> data = {};

  // ===========================================================================
  // LAB ACT 5 - ENHANCEMENT 1: Firebase Auth Instance & Core Service Functions
  // ===========================================================================
  final auth.FirebaseAuth firebaseAuth = auth.FirebaseAuth.instance;

  auth.User? get currentUser => firebaseAuth.currentUser;

  Stream<auth.User?> get authStateChanges => firebaseAuth.authStateChanges();

  /// Determine current user login type (Firebase vs DummyJSON)
  Future<LoginType> getLoginType() async {
    final prefs = await SharedPreferences.getInstance();
    final type = prefs.getString('loginType');
    if (type == 'firebase' || (currentUser != null && type != 'dummyjson')) {
      return LoginType.firebase;
    }
    return LoginType.dummyJson;
  }

  /// Sign in with Firebase Email & Password
  Future<auth.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loginType', 'firebase');
    await prefs.setString('email', credential.user?.email ?? email);
    await prefs.setString(
      'username',
      credential.user?.displayName ?? email.split('@').first,
    );

    return credential;
  }

  /// Create Account with Firebase Email & Password and optional profile info
  Future<auth.UserCredential> createAccount({
    required String email,
    required String password,
    Map<String, dynamic>? profileData,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loginType', 'firebase');
    await prefs.setString('email', credential.user?.email ?? email);

    if (profileData != null) {
      await saveExtendedProfile(profileData);
      final username = profileData['username']?.toString();
      if (username != null && username.isNotEmpty) {
        await updateUsername(username: username);
      }
    } else {
      await prefs.setString('username', email.split('@').first);
    }

    return credential;
  }

  /// Sign out of Firebase Auth SDK
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  /// LAB ACT 5 - ENHANCEMENT 3: Update User Profile (Full Name and Username)
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    final String fullName = '$firstName $lastName'.trim();
    if (currentUser != null) {
      await currentUser!.updateDisplayName(fullName.isNotEmpty ? fullName : username);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('username', username);
  }

  /// Update Firebase User Display Name (Username)
  Future<void> updateUsername({required String username}) async {
    if (currentUser != null) {
      await currentUser!.updateDisplayName(username);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  /// Delete Firebase Account with re-authentication
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    auth.AuthCredential credential = auth.EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    if (currentUser != null) {
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.delete();
    }
    await logout();
  }

  /// Reset/Update Password after re-authenticating with current password
  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    auth.AuthCredential credential = auth.EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    if (currentUser != null) {
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.updatePassword(newPassword);
    }
  }

  // ===========================================================================
  // LAB ACT 4 & 5 - ENHANCEMENT 2: DummyJSON REST API Authentication
  // ===========================================================================
  Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$host/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      data['loginType'] = 'dummyjson';
      await saveUserData(data);
      return data;
    } else {
      throw Exception(response.body);
    }
  }

  /// Save extended profile data (fName, lName, age, contactNo, username, email)
  Future<void> saveExtendedProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    if (profile.containsKey('fName')) {
      await prefs.setString('firstName', profile['fName'].toString());
    }
    if (profile.containsKey('lName')) {
      await prefs.setString('lastName', profile['lName'].toString());
    }
    if (profile.containsKey('age')) {
      await prefs.setString('age', profile['age'].toString());
    }
    if (profile.containsKey('contactNo')) {
      await prefs.setString('contactNo', profile['contactNo'].toString());
    }
    if (profile.containsKey('username')) {
      await prefs.setString('username', profile['username'].toString());
    }
    if (profile.containsKey('emailAddress')) {
      await prefs.setString('email', profile['emailAddress'].toString());
    }
  }

  /// Save user data from API response based on User model
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final user = User.fromJson(userData);

    await prefs.setString('loginType', userData['loginType'] ?? 'dummyjson');
    await prefs.setInt('id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('firstName', user.firstName);
    await prefs.setString('lastName', user.lastName);
    await prefs.setString('gender', user.gender);
    await prefs.setString('image', user.image);
    await prefs.setString('accessToken', user.accessToken);
    await prefs.setString('refreshToken', user.refreshToken);
    if (user.age.isNotEmpty) await prefs.setString('age', user.age);
    if (user.contactNo.isNotEmpty) {
      await prefs.setString('contactNo', user.contactNo);
    }

    if (userData.containsKey('token')) {
      await prefs.setString('token', userData['token'] ?? '');
    } else if (user.accessToken.isNotEmpty) {
      await prefs.setString('token', user.accessToken);
    }
  }

  /// Retrieve user data from SharedPreferences and Firebase state
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String loginTypeStr = prefs.getString('loginType') ?? (currentUser != null ? 'firebase' : 'dummyjson');

    final String? prefsUsername = prefs.getString('username');
    final String username = (prefsUsername != null && prefsUsername.isNotEmpty)
        ? prefsUsername
        : (currentUser?.displayName ?? '');
    final String email = currentUser?.email ?? prefs.getString('email') ?? '';

    return {
      'id': prefs.getInt('id') ?? 1,
      'loginType': loginTypeStr,
      'username': username,
      'email': email,
      'firstName': prefs.getString('firstName') ?? '',
      'lastName': prefs.getString('lastName') ?? '',
      'age': prefs.getString('age') ?? '',
      'contactNo': prefs.getString('contactNo') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'image': prefs.getString('image') ?? '',
      'accessToken': prefs.getString('accessToken') ?? '',
      'refreshToken': prefs.getString('refreshToken') ?? '',
      'token': prefs.getString('token') ?? prefs.getString('accessToken') ?? '',
    };
  }

  /// Retrieve User model
  Future<User> getUser() async {
    final userData = await getUserData();
    return User.fromJson(userData);
  }

  /// Check If User Is Logged In (either valid token or active Firebase session)
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? prefs.getString('token');
    final hasToken = token != null && token.isNotEmpty;
    final hasFirebase = firebaseAuth.currentUser != null;
    return hasToken || hasFirebase;
  }

  /// LAB ACT 5 - ENHANCEMENT 1: Centralized Logout clearing session/tokens and redirecting
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to log out: $e');
    }
  }
}
