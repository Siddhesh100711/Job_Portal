import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/theme.dart';
import '../widgets/tactile_button.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoginMode = true;
  String _selectedRole = 'Candidate';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = ref.read(authViewModelProvider.notifier);
    bool success;

    if (_isLoginMode) {
      success = await authVM.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      success = await authVM.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
        _selectedRole,
      );
    }

    if (success) {
      // Fetch role from Firestore and route accordingly
      if (mounted) {
        final role = await authVM.getCurrentUserRole();
        if (mounted) {
          if (role == 'Employer') {
            context.go('/employer-dashboard');
          } else {
            context.go('/candidate-dashboard');
          }
        }
      }
    } else {
      // Show error from ViewModel state
      if (mounted) {
        final errorMessage = ref.read(authViewModelProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              errorMessage ?? 'Authentication failed.',
              style: const TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.electricIndigo.withValues(
                            alpha: 0.12,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.work_rounded,
                          size: 56,
                          color: AppTheme.electricIndigo,
                        ),
                      ),
                    )
                    .animate()
                    .fade(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                    ),
                const SizedBox(height: 32),
                Text(
                  _isLoginMode ? 'Welcome\nBack' : 'Create\nAccount',
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(height: 1.1, fontSize: 42),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  _isLoginMode
                      ? 'Sign in to discover your next opportunity.'
                      : 'Join the portal and start your journey.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // --- Name field (Register mode only) ---
                if (!_isLoginMode) ...[
                  TextFormField(
                    controller: _nameController,
                    enabled: !isLoading,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],

                // --- Email ---
                TextFormField(
                  controller: _emailController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // --- Password ---
                TextFormField(
                  controller: _passwordController,
                  enabled: !isLoading,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),

                // --- Role selection (Register mode only) ---
                if (!_isLoginMode) ...[
                  const SizedBox(height: 24),
                  Text(
                    'I am a…',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Candidate'),
                          selected: _selectedRole == 'Candidate',
                          onSelected: isLoading
                              ? null
                              : (_) =>
                                    setState(() => _selectedRole = 'Candidate'),
                          selectedColor: AppTheme.electricIndigo,
                          backgroundColor: AppTheme.surfaceDark,
                          labelStyle: TextStyle(
                            color: _selectedRole == 'Candidate'
                                ? Colors.white
                                : Colors.white54,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _selectedRole == 'Candidate'
                                  ? AppTheme.electricIndigo
                                  : Colors.white12,
                            ),
                          ),
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Employer'),
                          selected: _selectedRole == 'Employer',
                          onSelected: isLoading
                              ? null
                              : (_) =>
                                    setState(() => _selectedRole = 'Employer'),
                          selectedColor: AppTheme.electricIndigo,
                          backgroundColor: AppTheme.surfaceDark,
                          labelStyle: TextStyle(
                            color: _selectedRole == 'Employer'
                                ? Colors.white
                                : Colors.white54,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _selectedRole == 'Employer'
                                  ? AppTheme.electricIndigo
                                  : Colors.white12,
                            ),
                          ),
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 36),

                // --- Submit Button ---
                TactileButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(_isLoginMode ? 'Sign In' : 'Create Account'),
                ),
                const SizedBox(height: 20),

                // --- Toggle Login / Register ---
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => setState(() => _isLoginMode = !_isLoginMode),
                  child: Text(
                    _isLoginMode
                        ? "Don't have an account? Create one"
                        : 'Already have an account? Sign in',
                    style: const TextStyle(color: AppTheme.electricIndigo),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
