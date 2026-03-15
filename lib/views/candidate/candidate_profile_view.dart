import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/user_profile_model.dart';
import '../../core/theme.dart';

class CandidateProfileView extends ConsumerStatefulWidget {
  const CandidateProfileView({super.key});

  @override
  ConsumerState<CandidateProfileView> createState() =>
      _CandidateProfileViewState();
}

class _CandidateProfileViewState extends ConsumerState<CandidateProfileView> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillInputController = TextEditingController();
  final List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authState = ref.read(authViewModelProvider);
    final user = authState.user;
    if (user == null) return;

    // Fetch profile data
    await ref.read(profileViewModelProvider.notifier).fetchProfile(user.uid);

    // Populate controllers
    final profile = ref.read(profileViewModelProvider).profile;
    if (profile != null) {
      _nameController.text = profile.name;
      _bioController.text = profile.bio;
      _skills.clear();
      _skills.addAll(profile.skills);
    } else {
      // Fallback for missing profile
      _nameController.text = user.displayName ?? '';
      _bioController.text = '';
      _skills.clear();
    }
  }

  Future<void> _saveProfile() async {
    final authState = ref.read(authViewModelProvider);
    final user = authState.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be signed in to save your profile.'),
        ),
      );
      return;
    }

    final currentProfile = ref.read(profileViewModelProvider).profile;
    final profile = UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      skills: List<String>.from(_skills),
      resumeUrl: currentProfile?.resumeUrl ?? '',
      avatarUrl: currentProfile?.avatarUrl ?? '',
    );

    await ref.read(profileViewModelProvider.notifier).saveProfile(profile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.premiumSurface,
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppTheme.electricIndigo),
              SizedBox(width: 12),
              Text(
                'Profile saved successfully.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _addSkill() {
    final skill = _skillInputController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() => _skills.add(skill));
      _skillInputController.clear();
    }
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final profile = profileState.profile;
    final isLoading = profileState.isLoading;

    // 1. Loading State Safety Net
    if (isLoading && profile == null) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.electricIndigo),
              SizedBox(height: 24),
              Text(
                'Syncing with Firebase...',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Main UI with Null-Safe Fallbacks
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (profileState.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        profileState.errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white38,
                      ),
                      onPressed: () => _loadProfile(), // Retry
                    ),
                  ],
                ),
              ),
            // Avatar Section
            Center(
                  child: GestureDetector(
                    onTap: isLoading
                        ? null
                        : () {
                            ref
                                .read(profileViewModelProvider.notifier)
                                .uploadAvatar();
                          },
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.electricIndigo.withValues(
                                alpha: 0.3,
                              ),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: (profile?.avatarUrl ?? "").isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: profile?.avatarUrl ?? "",
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.electricIndigo,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                          Icons.person_rounded,
                                          size: 50,
                                          color: Colors.white24,
                                        ),
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    size: 50,
                                    color: Colors.white24,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.electricIndigo,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (isLoading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fade(duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
            const SizedBox(height: 32),

            TextFormField(
              controller: _nameController,
              enabled: !isLoading,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _bioController,
              enabled: !isLoading,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Resume Section
            Text('Resume', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description_rounded,
                    color: AppTheme.electricIndigo,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (profile?.resumeUrl ?? "").isNotEmpty
                              ? 'Resume Uploaded'
                              : 'No Resume Uploaded',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if ((profile?.resumeUrl ?? "").isNotEmpty)
                          const Text(
                            'PDF Format',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.electricIndigo,
                      ),
                    )
                  else
                    TextButton.icon(
                      onPressed: () {
                        ref
                            .read(profileViewModelProvider.notifier)
                            .uploadResume();
                      },
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: Text(
                        (profile?.resumeUrl ?? "").isNotEmpty
                            ? 'Replace'
                            : 'Upload',
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.electricIndigo,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Text('Skills', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _skillInputController,
                    enabled: !isLoading,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Add a skill',
                      hintText: 'e.g. Flutter',
                      hintStyle: TextStyle(color: Colors.white24),
                    ),
                    onFieldSubmitted: (_) => _addSkill(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: isLoading ? null : _addSkill,
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.electricIndigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _skills.map((skill) {
                return Chip(
                  label: Text(
                    skill,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white54,
                  ),
                  onDeleted: isLoading ? null : () => _removeSkill(skill),
                  backgroundColor: AppTheme.surfaceDark,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.electricIndigo,
                ),
              )
            else
              FilledButton(
                onPressed: () {
                  _saveProfile();
                },
                child: const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text('Save Profile', style: TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
