import 'package:flutter/foundation.dart';

@immutable
class Job {
  final String id;
  final String title;
  final String companyName;
  final String location;
  final String salaryRange;
  final String description;
  final List<String> skills;

  const Job({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.salaryRange,
    required this.description,
    required this.skills,
  });

  Job copyWith({
    String? id,
    String? title,
    String? companyName,
    String? location,
    String? salaryRange,
    String? description,
    List<String>? skills,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      location: location ?? this.location,
      salaryRange: salaryRange ?? this.salaryRange,
      description: description ?? this.description,
      skills: skills ?? this.skills,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'companyName': companyName,
      'location': location,
      'salaryRange': salaryRange,
      'description': description,
      'skills': skills,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map, String id) {
    return Job(
      id: id,
      title: map['title'] ?? '',
      companyName: map['companyName'] ?? '',
      location: map['location'] ?? '',
      salaryRange: map['salaryRange'] ?? '',
      description: map['description'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
    );
  }
}
