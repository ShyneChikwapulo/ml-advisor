import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final bool hasCompletedOnboarding;
  final int avatarIndex;
  final String experienceLevel;
  final List<String> interests;
  final bool enableTips;
  
  // New developer-centric profile data vectors
  final String bio;
  final String githubUsername;
  final String linkedinUrl;
  final String phoneNumber;       // ✅ ADDED
  final String physicalAddress;     // ✅ ADDED
  final List<String> techStack;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.hasCompletedOnboarding = false,
    this.avatarIndex = -1,
    this.experienceLevel = '',
    this.interests = const [],
    this.enableTips = true,
    this.bio = '',
    this.githubUsername = '',
    this.linkedinUrl = '',
    this.phoneNumber = '',         // ✅ ADDED
    this.physicalAddress = '',       // ✅ ADDED
    this.techStack = const [],
    this.createdAt,
  });

  bool get isAdmin => role.trim().toLowerCase() == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.fromMap(json, json['uid'] ?? '');
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime? parsedDate;
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedDate = DateTime.tryParse(map['createdAt']);
    }

    return UserModel(
      uid: documentId.isNotEmpty ? documentId : (map['uid'] ?? ''),
      email: map['email'] ?? '',
      displayName: map['name'] ?? map['displayName'] ?? '',
      role: map['role'] ?? 'Student',
      hasCompletedOnboarding: map['hasCompletedOnboarding'] ?? false,
      avatarIndex: map['avatarIndex'] ?? -1,
      experienceLevel: map['experienceLevel'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      enableTips: map['enableTips'] ?? true,
      bio: map['bio'] ?? '',
      githubUsername: map['githubUsername'] ?? '',
      linkedinUrl: map['linkedinUrl'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',         // ✅ ADDED
      physicalAddress: map['physicalAddress'] ?? '', // ✅ ADDED
      techStack: List<String>.from(map['techStack'] ?? []),
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': displayName,
      'role': role,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'avatarIndex': avatarIndex,
      'experienceLevel': experienceLevel,
      'interests': interests,
      'enableTips': enableTips,
      'bio': bio,
      'githubUsername': githubUsername,
      'linkedinUrl': linkedinUrl,
      'phoneNumber': phoneNumber,         // ✅ ADDED
      'physicalAddress': physicalAddress, // ✅ ADDED
      'techStack': techStack,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}