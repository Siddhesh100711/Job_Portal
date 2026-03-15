import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../core/theme.dart';

class JobApplicantsView extends ConsumerWidget {
  final String jobId;
  final String jobTitle;

  const JobApplicantsView({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicantsAsync = ref.watch(applicantsForJobProvider(jobId));

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(title: Text(jobTitle)),
      body: applicantsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No applicants yet.',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white38),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              return _ApplicantCard(application: application, index: index);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.electricIndigo),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}

class _ApplicantCard extends ConsumerWidget {
  final dynamic application;
  final int index;

  const _ApplicantCard({required this.application, required this.index});

  Future<void> _viewResume(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open resume.')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(
      userProfileProvider(application.candidateId),
    );

    return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: AppTheme.premiumSurface,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: profileAsync.when(
            data: (profile) {
              final name = profile?.name ?? 'Unknown Candidate';
              final skills = profile?.skills ?? [];
              final avatarUrl = profile?.avatarUrl;
              final resumeUrl = profile?.resumeUrl;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.electricIndigo.withValues(
                              alpha: 0.1,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: avatarUrl != null && avatarUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: avatarUrl,
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
                                        size: 30,
                                        color: Colors.white24,
                                      ),
                                )
                              : const Icon(
                                  Icons.person_rounded,
                                  size: 30,
                                  color: Colors.white24,
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            if (skills.isNotEmpty)
                              Wrap(
                                spacing: 6.0,
                                runSpacing: 6.0,
                                children: skills.map((skill) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceDark,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.08,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      skill,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.electricIndigo.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          application.status,
                          style: const TextStyle(
                            color: AppTheme.electricIndigo,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (resumeUrl != null && resumeUrl.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => _viewResume(context, resumeUrl),
                          icon: const Icon(
                            Icons.picture_as_pdf_rounded,
                            size: 16,
                          ),
                          label: const Text('View Resume'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.electricIndigo,
                            side: const BorderSide(
                              color: AppTheme.electricIndigo,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(
                  color: AppTheme.electricIndigo,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (error, stack) => const Text(
              'Failed to load applicant',
              style: TextStyle(color: Colors.white38),
            ),
          ),
        )
        .animate()
        .fade(
          duration: 400.ms,
          delay: Duration(milliseconds: index * 100),
        )
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          delay: Duration(milliseconds: index * 100),
        );
  }
}
