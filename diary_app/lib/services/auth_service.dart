import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _hasSetPassword = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasSetPassword => _hasSetPassword;

  AuthService() {
    _initAuth();
  }

  // 初始化認證狀態
  Future<void> _initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSetPassword = prefs.containsKey('password_hash');

    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _currentUser = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );
        _isAuthenticated = true;
      } else {
        _currentUser = null;
        _isAuthenticated = false;
      }
      notifyListeners();
    });
  }

  // 設置本地密碼（用於離線驗證）
  Future<bool> setPassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hash = sha256.convert(utf8.encode(password)).toString();
      await prefs.setString('password_hash', hash);
      _hasSetPassword = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('設置密碼錯誤: $e');
      return false;
    }
  }

  // 驗證本地密碼
  Future<bool> verifyPassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString('password_hash');
      if (storedHash == null) return false;

      final hash = sha256.convert(utf8.encode(password)).toString();
      return hash == storedHash;
    } catch (e) {
      debugPrint('驗證密碼錯誤: $e');
      return false;
    }
  }

  // 使用Email註冊
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _currentUser = UserModel(
          id: credential.user!.uid,
          email: credential.user!.email ?? '',
        );
        _isAuthenticated = true;
        notifyListeners();
        return null; // 成功
      }
      return '註冊失敗';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return '密碼強度不足';
        case 'email-already-in-use':
          return '此Email已被使用';
        case 'invalid-email':
          return 'Email格式不正確';
        default:
          return '註冊失敗: ${e.message}';
      }
    } catch (e) {
      return '發生錯誤: $e';
    }
  }

  // 使用Email登入
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _currentUser = UserModel(
          id: credential.user!.uid,
          email: credential.user!.email ?? '',
          displayName: credential.user!.displayName,
          photoUrl: credential.user!.photoURL,
        );
        _isAuthenticated = true;
        notifyListeners();
        return null; // 成功
      }
      return '登入失敗';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return '找不到此用戶';
        case 'wrong-password':
          return '密碼錯誤';
        case 'invalid-email':
          return 'Email格式不正確';
        case 'user-disabled':
          return '此帳號已被停用';
        default:
          return '登入失敗: ${e.message}';
      }
    } catch (e) {
      return '發生錯誤: $e';
    }
  }

  // 登出
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // 重置密碼
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // 成功
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return '找不到此Email';
        case 'invalid-email':
          return 'Email格式不正確';
        default:
          return '重置失敗: ${e.message}';
      }
    } catch (e) {
      return '發生錯誤: $e';
    }
  }
}
