// models/teacher_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? dateOfBirth;
  final String? address;
  final String? subject;
  final String? experience;
  final String? employeeId;
  final String? qualification;
  final String? designation;
  final String? profilePictureUrl;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  TeacherProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.dateOfBirth,
    this.address,
    this.subject,
    this.experience,
    this.employeeId,
    this.qualification,
    this.designation,
    this.profilePictureUrl,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'subject': subject,
      'experience': experience,
      'employeeId': employeeId,
      'qualification': qualification,
      'designation': designation,
      'profilePictureUrl': profilePictureUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory TeacherProfile.fromMap(Map<String, dynamic> map) {
    return TeacherProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      dateOfBirth: map['dateOfBirth'],
      address: map['address'],
      subject: map['subject'],
      experience: map['experience'],
      employeeId: map['employeeId'],
      qualification: map['qualification'],
      designation: map['designation'] ?? 'Senior Teacher',
      profilePictureUrl: map['profilePictureUrl'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}