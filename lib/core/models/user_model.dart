import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, teacher, parent, admin }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? profileImage;
  final String? classId;
  final String? className;
  final String? parentId;
  final String? parentName;
  final List<String>? childrenIds; // For parents
  final DateTime createdAt;
  final int status; // 1: active, 0: inactive

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profileImage,
    this.classId,
    this.className,
    this.parentId,
    this.parentName,
    this.childrenIds,
    required this.createdAt,
    this.status = 1,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: _parseRole(data['role']),
      phone: data['phone'],
      profileImage: data['profileImage'],
      classId: data['classId'],
      className: data['className'] ?? data['class'], // Handle both keys
      parentId: data['parentId'],
      parentName: data['parentName'],
      childrenIds: data['childrenIds'] != null
          ? List<String>.from(data['childrenIds'])
          : (data['children'] != null
                ? List<String>.from(data['children'])
                : null),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.name.capitalize(),
      if (phone != null) 'phone': phone,
      if (profileImage != null) 'profileImage': profileImage,
      if (classId != null) 'classId': classId,
      if (className != null) 'className': className,
      if (parentId != null) 'parentId': parentId,
      if (parentName != null) 'parentName': parentName,
      if (childrenIds != null) 'childrenIds': childrenIds,
      'createdAt': createdAt,
      'status': status,
    };
  }

  static UserRole _parseRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'teacher':
        return UserRole.teacher;
      case 'parent':
        return UserRole.parent;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
