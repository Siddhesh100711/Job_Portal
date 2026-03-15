import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile_model.dart';
import '../services/cloudinary_service.dart';

class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? errorMessage;

  ProfileState({this.profile, this.isLoading = false, this.errorMessage});

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ProfileViewModel extends Notifier<ProfileState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  ProfileState build() {
    return ProfileState();
  }

  Future<void> fetchProfile(String uid) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint('!!! FETCH PROFILE ERROR: NO USER !!!');
        return;
      }

      // Add 10-second timeout to protect against infinite hangs
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('!!! FETCH PROFILE TIMED OUT after 10s !!!');
              throw Exception(
                'Verification required - Please sign out and sign in again.',
              );
            },
          );

      if (doc.exists && doc.data() != null) {
        state = state.copyWith(
          profile: UserProfile.fromMap(doc.data()!, uid),
          errorMessage: null, // Ensure any previous error is cleared
        );
      } else {
        state = state.copyWith(
          profile: UserProfile(
            uid: uid,
            email: currentUser.email ?? '',
            name: currentUser.displayName ?? '',
            bio: '',
            skills: [],
            resumeUrl: '',
            avatarUrl: '',
          ),
          errorMessage: null, // No error for missing doc, it's a new user
        );
      }
    } on FirebaseException catch (e) {
      debugPrint(
        '!!! FIREBASE ERROR DURING HANDSHAKE: ${e.code} - ${e.message} !!!',
      );
      state = state.copyWith(
        errorMessage: 'Firebase Config Error: ${e.message}',
      );
    } catch (e) {
      debugPrint('!!! ERROR FETCHING PROFILE: $e !!!');
      state = state.copyWith(errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('!!! FIREBASE AUTH IS NULL !!!');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'You must be signed in.',
      );
      throw Exception('You must be signed in.');
    }
    // ignore: unused_local_variable
    final uid = currentUser.uid;

    // Only update loading state if not already loading (to avoid overriding upload loading)
    final bool alreadyLoading = state.isLoading;
    if (!alreadyLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .set(profile.toMap(), SetOptions(merge: true));
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      debugPrint('!!! SAVE PROFILE ERROR: $e !!!');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> uploadResume() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('!!! FIREBASE AUTH IS NULL !!!');
      throw Exception('You must be signed in.');
    }
    // ignore: unused_local_variable
    final uid = currentUser.uid;

    if (state.profile == null) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        state = state.copyWith(isLoading: true, errorMessage: null);
        try {
          final url = await _cloudinaryService.uploadFile(File(filePath));
          if (url != null) {
            final updatedProfile = state.profile!.copyWith(resumeUrl: url);
            await saveProfile(updatedProfile);
          } else {
            state = state.copyWith(isLoading: false);
          }
        } catch (e) {
          state = state.copyWith(isLoading: false, errorMessage: e.toString());
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('!!! RESUME PICKER ERROR: $e !!!');
      rethrow;
    }
  }

  Future<void> uploadAvatar() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('!!! FIREBASE AUTH IS NULL !!!');
      throw Exception('You must be signed in.');
    }
    // ignore: unused_local_variable
    final uid = currentUser.uid;

    if (state.profile == null) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        state = state.copyWith(isLoading: true, errorMessage: null);
        try {
          final url = await _cloudinaryService.uploadFile(File(image.path));
          if (url != null) {
            final updatedProfile = state.profile!.copyWith(avatarUrl: url);
            await saveProfile(updatedProfile);
          } else {
            state = state.copyWith(isLoading: false);
          }
        } catch (e) {
          state = state.copyWith(isLoading: false, errorMessage: e.toString());
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('!!! IMAGE PICKER ERROR: $e !!!');
      rethrow;
    }
  }
}

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(() {
      return ProfileViewModel();
    });
