import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

final jobStreamProvider = StreamProvider<List<Job>>((ref) {
  return FirebaseFirestore.instance.collection('jobs').snapshots().map((
    snapshot,
  ) {
    return snapshot.docs.map((doc) {
      return Job.fromMap(doc.data(), doc.id);
    }).toList();
  });
});

class JobViewModel extends Notifier<void> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void build() {}

  Future<void> addJob(Job newJob) async {
    await _firestore.collection('jobs').doc(newJob.id).set(newJob.toMap());
  }
}

final jobViewModelProvider = NotifierProvider<JobViewModel, void>(() {
  return JobViewModel();
});
