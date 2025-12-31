// models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? profileImage;
  final String? classSection;
  final String? rollNumber;
  final String? parentId;
  final String? parentName;
  final String? parentEmail;
  final String? parentPhone;
  final List<String>? children; // For parents
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profileImage,
    this.classSection,
    this.rollNumber,
    this.parentId,
    this.parentName,
    this.parentEmail,
    this.parentPhone,
    this.children,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'Student',
      phone: data['phone'],
      profileImage: data['profileImage'],
      classSection: data['class'],
      rollNumber: data['rollNumber'],
      parentId: data['parentId'],
      parentName: data['parentName'],
      parentEmail: data['parentEmail'],
      parentPhone: data['parentPhone'],
      children: data['children'] != null 
          ? List<String>.from(data['children'])
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      if (phone != null) 'phone': phone,
      if (profileImage != null) 'profileImage': profileImage,
      if (classSection != null) 'class': classSection,
      if (rollNumber != null) 'rollNumber': rollNumber,
      if (parentId != null) 'parentId': parentId,
      if (parentName != null) 'parentName': parentName,
      if (parentEmail != null) 'parentEmail': parentEmail,
      if (parentPhone != null) 'parentPhone': parentPhone,
      if (children != null) 'children': children,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}