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
    bool clearError = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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
    state = state.copyWith(isLoading: true, clearError: true);

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
          clearError: true, // Ensure any previous error is cleared
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
          clearError: true, // No error for missing doc, it's a new user
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
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .set(profile.toMap(), SetOptions(merge: true));
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        clearError: true,
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
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        state = state.copyWith(isLoading: true, clearError: true);
        try {
          final url = await _cloudinaryService.uploadFileBytes(
              result.files.single.bytes!,
              result.files.single.name,
              isRaw: true);
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
        state = state.copyWith(isLoading: true, clearError: true);
        try {
          final bytes = await image.readAsBytes();
          final url = await _cloudinaryService.uploadFileBytes(bytes, image.name);
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
