import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/utils/app_error_handler.dart';
import '../../../core/design/components/verso_snackbar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authUserProvider);

    return userAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: ErrorStateWidget(
          error: err,
          onRetry: () => ref.invalidate(authUserProvider),
        ),
      ),
      data: (user) {
        if (user == null)
          return const Scaffold(body: Center(child: Text('Not Logged In')));

        final name = user.userMetadata?['full_name'] ?? 'Reader';
        final email = user.email ?? 'No Email';
        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

        return Scaffold(
          appBar: AppBar(title: const Text('My Profile')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Gap(20),
                CircleAvatar(
                  radius: 60,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const Gap(24),
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Gap(8),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const Gap(40),

                // --- ACTION BUTTONS (Using Bottom Sheets) ---

                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Change Email'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled:
                        true, // Allows sheet to expand with keyboard
                    useSafeArea: true,
                    builder: (_) => const _ChangeEmailSheet(),
                  ),
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (_) => const _ChangePasswordSheet(),
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- 1. CHANGE EMAIL SHEET (Bottom Sheet) ---
class _ChangeEmailSheet extends ConsumerStatefulWidget {
  const _ChangeEmailSheet();

  @override
  ConsumerState<_ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends ConsumerState<_ChangeEmailSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  Future<void> _update() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@') || pass.isEmpty) {
      VersoSnackbar.error(context, message: "Invalid input");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      // 1. Verify Identity
      await repo.reauthenticate(pass);
      // 2. Update Email
      await repo.updateEmail(email);

      if (mounted) {
        Navigator.pop(context);
        VersoSnackbar.success(context,
            message: "Check your email (both old and new) to confirm.");
      }
    } catch (e) {
      if (mounted) {
        VersoSnackbar.error(context, message: AppErrorHandler.getMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This padding handles the keyboard automatically
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(24),

            Text(
              "Change Email",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Gap(24),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "New Email Address",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(16),
            TextField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: "Current Password",
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
              ),
            ),
            const Gap(32),
            FilledButton(
              onPressed: _isLoading ? null : _update,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Update Email"),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}

// --- 2. CHANGE PASSWORD SHEET (Bottom Sheet) ---
class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isLoading = false;
  bool _obsOld = true;
  bool _obsNew = true;
  bool _obsConfirm = true;

  Future<void> _update() async {
    final oldPass = _oldPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (newPass.length < 6) {
      VersoSnackbar.error(context, message: "New password is too short");
      return;
    }
    if (newPass != confirmPass) {
      VersoSnackbar.error(context, message: "Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      // 1. Verify Old Password
      await repo.reauthenticate(oldPass);
      // 2. Update to New Password
      await repo.updatePassword(newPass);

      if (mounted) {
        Navigator.pop(context);
        VersoSnackbar.success(context,
            message: "Password updated successfully!");
      }
    } catch (e) {
      if (mounted) {
        VersoSnackbar.error(context, message: AppErrorHandler.getMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(24),

            Text(
              "Change Password",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Gap(24),

            TextField(
              controller: _oldPassController,
              obscureText: _obsOld,
              decoration: InputDecoration(
                labelText: "Current Password",
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obsOld ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obsOld = !_obsOld),
                ),
              ),
            ),

            // --- NEW: FORGOT PASSWORD BUTTON ---
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Close the bottom sheet first
                  Navigator.pop(context);
                  // Navigate to the Forgot Password screen
                  GoRouter.of(context).push('/forgot-password');
                },
                child: const Text('Forgot Password?'),
              ),
            ),

            TextField(
              controller: _newPassController,
              obscureText: _obsNew,
              decoration: InputDecoration(
                labelText: "New Password",
                prefixIcon: const Icon(Icons.key),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obsNew ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obsNew = !_obsNew),
                ),
              ),
            ),
            const Gap(16),
            TextField(
              controller: _confirmPassController,
              obscureText: _obsConfirm,
              decoration: InputDecoration(
                labelText: "Confirm New Password",
                prefixIcon: const Icon(Icons.check_circle_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obsConfirm ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obsConfirm = !_obsConfirm),
                ),
              ),
            ),
            const Gap(32),
            FilledButton(
              onPressed: _isLoading ? null : _update,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Update Password"),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}
