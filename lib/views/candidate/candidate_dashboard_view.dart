import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../viewmodels/job_viewmodel.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/theme.dart';
import '../widgets/tactile_button.dart';

/// Tracks which jobs the user has already applied to in this session.
class AppliedJobsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void markApplied(String jobId) {
    state = {...state, jobId};
  }
}

final appliedJobsProvider = NotifierProvider<AppliedJobsNotifier, Set<String>>(
  () {
    return AppliedJobsNotifier();
  },
);

class CandidateDashboardView extends ConsumerWidget {
  const CandidateDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsyncValue = ref.watch(jobStreamProvider);
    final appliedJobs = ref.watch(appliedJobsProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('JobKaro - Discover Roles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.push('/candidate-profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(authViewModelProvider.notifier).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: jobsAsyncValue.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No roles available at the moment.',
                    textAlign: TextAlign.center,
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
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final hasApplied = appliedJobs.contains(job.id);

              return Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    decoration: BoxDecoration(
                      color: AppTheme.premiumSurface,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontSize: 20, height: 1.2),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.business_rounded,
                                        size: 16,
                                        color: AppTheme.electricIndigo,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        job.companyName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.electricIndigo.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                job.salaryRange,
                                style: const TextStyle(
                                  color: AppTheme.electricIndigo,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.white38,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              job.location,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          job.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1.5,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: job.skills.map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceDark,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Text(
                                skill,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: hasApplied
                              ? FilledButton.tonal(
                                  onPressed: null,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppTheme.surfaceDark,
                                    disabledBackgroundColor:
                                        AppTheme.surfaceDark,
                                    disabledForegroundColor: Colors.white38,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_rounded,
                                        size: 18,
                                        color: AppTheme.electricIndigo,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Applied'),
                                    ],
                                  ),
                                )
                              : TactileButton(
                                  onPressed: () async {
                                    try {
                                      await ref
                                          .read(
                                            applicationViewModelProvider
                                                .notifier,
                                          )
                                          .applyForJob(jobId: job.id);

                                      ref
                                          .read(appliedJobsProvider.notifier)
                                          .markApplied(job.id);

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                AppTheme.premiumSurface,
                                            content: const Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  color:
                                                      AppTheme.electricIndigo,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Application Submitted Successfully',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text('Apply Now'),
                                ),
                        ),
                      ],
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
