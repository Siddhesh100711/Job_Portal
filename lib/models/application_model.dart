import 'package:flutter/foundation.dart';

@immutable
class Application {
  final String id;
  final String jobId;
  final String candidateId;
  final String status;
  final DateTime appliedAt;

  const Application({
    required this.id,
    required this.jobId,
    required this.candidateId,
    required this.status,
    required this.appliedAt,
  });

  Application copyWith({
    String? id,
    String? jobId,
    String? candidateId,
    String? status,
    DateTime? appliedAt,
  }) {
    return Application(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      candidateId: candidateId ?? this.candidateId,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'candidateId': candidateId,
      'status': status,
      'appliedAt': appliedAt.toIso8601String(),
    };
  }

  factory Application.fromMap(Map<String, dynamic> map, String id) {
    return Application(
      id: id,
      jobId: map['jobId'] ?? '',
      candidateId: map['candidateId'] ?? '',
      status: map['status'] ?? 'Applied',
      appliedAt: map['appliedAt'] != null
          ? DateTime.parse(map['appliedAt'])
          : DateTime.now(),
    );
  }
}
