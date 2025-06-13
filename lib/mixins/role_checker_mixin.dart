import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_masjid/providers/user_role_provider.dart';

mixin RoleCheckerMixin {
  UserRoleProvider getUserRoleProvider(BuildContext context) {
    return Provider.of<UserRoleProvider>(context, listen: false);
  }

  bool checkUserRole(BuildContext context, String requiredRole) {
    return getUserRoleProvider(context).hasRole(requiredRole);
  }

  bool checkAnyRole(BuildContext context, List<String> roles) {
    return getUserRoleProvider(context).hasAnyRole(roles);
  }

  bool isAdmin(BuildContext context) {
    return getUserRoleProvider(context).isAdmin;
  }

  bool isPetugas(BuildContext context) {
    return getUserRoleProvider(context).isPetugas;
  }

  Future<bool> initializeUserRole(BuildContext context) async {
    await getUserRoleProvider(context).initialize();
    return true;
  }
} 