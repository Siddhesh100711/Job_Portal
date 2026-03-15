import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String bio;
  final List<String> skills;
  final String resumeUrl;
  final String avatarUrl;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.bio,
    required this.skills,
    required this.resumeUrl,
    required this.avatarUrl,
  });

  UserProfile copyWith({
    String? uid,
    String? email,
    String? name,
    String? bio,
    List<String>? skills,
    String? resumeUrl,
    String? avatarUrl,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'bio': bio,
      'skills': skills,
      'resumeUrl': resumeUrl,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      bio: map['bio'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      resumeUrl: map['resumeUrl'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
    );
  }
}
