import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRoleProvider extends ChangeNotifier {
  String? _userRole;
  bool _isLoading = true;
  bool _isAdmin = false;
  bool _isPetugas = false;
  bool _isInitialized = false;

  // Getters
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;
  bool get isPetugas => _isPetugas;
  bool get isInitialized => _isInitialized;

  // Initialize the provider
  Future<void> initialize() async {
    if (_isInitialized) return; // Already initialized
    
    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          _userRole = userDoc.data()?['role'] as String?;
          _updateRoleFlags();
        }
      }
    } catch (e) {
      debugPrint('Error initializing UserRoleProvider: $e');
      _userRole = null;
      _updateRoleFlags();
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Update role flags based on current role
  void _updateRoleFlags() {
    _isAdmin = _userRole == 'admin';
    _isPetugas = _userRole == 'petugas';
  }

  // Check if user has required role
  bool hasRole(String requiredRole) {
    if (!_isInitialized) return false;
    return _userRole == requiredRole;
  }

  // Check if user has any of the required roles
  bool hasAnyRole(List<String> roles) {
    if (!_isInitialized) return false;
    return roles.contains(_userRole);
  }

  // Check if user has admin or petugas role
  bool get canManageContent {
    if (!_isInitialized) return false;
    return _isAdmin || _isPetugas;
  }

  // Clear user role (for logout)
  void clearRole() {
    _userRole = null;
    _isAdmin = false;
    _isPetugas = false;
    _isInitialized = false;
    notifyListeners();
  }

  // Force refresh role (for role changes)
  Future<void> refreshRole() async {
    _isInitialized = false;
    await initialize();
  }
} 