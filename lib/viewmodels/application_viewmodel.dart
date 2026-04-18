import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/application_model.dart';
import '../models/user_profile_model.dart';
import 'package:uuid/uuid.dart';

class ApplicationViewModel extends Notifier<void> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void build() {}

  /// Applies for a job. Pulls candidateId directly from FirebaseAuth.
  /// Throws if the user is not authenticated.
  Future<void> applyForJob({required String jobId}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('You must be signed in to apply.');
    }

    final existingApp = await _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .where('candidateId', isEqualTo: user.uid)
        .get();

    if (existingApp.docs.isNotEmpty) {
      throw Exception('You have already applied for this job.');
    }

    final newApp = Application(
      id: const Uuid().v4(),
      jobId: jobId,
      candidateId: user.uid,
      status: 'Applied',
      appliedAt: DateTime.now(),
    );

    await _firestore
        .collection('applications')
        .doc(newApp.id)
        .set(newApp.toMap());
  }
}

final applicationViewModelProvider =
    NotifierProvider<ApplicationViewModel, void>(() {
      return ApplicationViewModel();
    });

/// Stream of Applications for a specific job (used by the Employer ATS).
final applicantsForJobProvider =
    StreamProvider.family<List<Application>, String>((ref, jobId) {
      return FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return Application.fromMap(doc.data(), doc.id);
            }).toList();
          });
    });

/// Fetches a UserProfile by uid for display (used for applicant cards).
final userProfileProvider = StreamProvider.family<UserProfile?, String>((
  ref,
  uid,
) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) {
    if (doc.exists && doc.data() != null) {
      return UserProfile.fromMap(doc.data()!, uid);
    }
    return null;
  });
});
