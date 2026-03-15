import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/auth/login_view.dart';
import '../views/candidate/candidate_dashboard_view.dart';
import '../views/candidate/candidate_profile_view.dart';
import '../views/employer/employer_dashboard_view.dart';
import '../views/employer/create_job_view.dart';
import '../views/employer/job_applicants_view.dart';

CustomTransitionPage<void> _fadeTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) =>
          _fadeTransitionPage(key: state.pageKey, child: const LoginView()),
    ),
    GoRoute(
      path: '/candidate-dashboard',
      name: 'candidate-dashboard',
      pageBuilder: (context, state) => _fadeTransitionPage(
        key: state.pageKey,
        child: const CandidateDashboardView(),
      ),
    ),
    GoRoute(
      path: '/candidate-profile',
      name: 'candidate-profile',
      pageBuilder: (context, state) => _fadeTransitionPage(
        key: state.pageKey,
        child: const CandidateProfileView(),
      ),
    ),
    GoRoute(
      path: '/employer-dashboard',
      name: 'employer-dashboard',
      pageBuilder: (context, state) => _fadeTransitionPage(
        key: state.pageKey,
        child: const EmployerDashboardView(),
      ),
    ),
    GoRoute(
      path: '/create-job',
      name: 'create-job',
      pageBuilder: (context, state) =>
          _fadeTransitionPage(key: state.pageKey, child: const CreateJobView()),
    ),
    GoRoute(
      path: '/job-applicants/:jobId',
      name: 'job-applicants',
      pageBuilder: (context, state) {
        final jobId = state.pathParameters['jobId']!;
        final jobTitle = (state.extra as String?) ?? 'Applicants';
        return _fadeTransitionPage(
          key: state.pageKey,
          child: JobApplicantsView(jobId: jobId, jobTitle: jobTitle),
        );
      },
    ),
  ],
);
