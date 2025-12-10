import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get the current user
    final userAsync = ref.watch(authUserProvider);
    final user = userAsync.value;

    // 2. Get user metadata (like the name we saved during sign up)
    final name = user?.userMetadata?['full_name'] ?? 'Reader';
    final email = user?.email ?? '';
    // Generate a simple avatar initial
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'B';

    return Drawer(
      child: Column(
        children: [
          // Header with User Info
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            accountName: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(email),
          ),

          // Menu Items
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close drawer first
              GoRouter.of(context).push('/profile');  // Navigate
            },
          ),
          ListTile(
            leading: const Icon(Icons.history_edu),
            title: const Text('Reading Journal'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.push('/activity-log'); // Navigate
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close drawer first
              GoRouter.of(context).push('/settings'); // Navigate
            },
          ),
          
          const Spacer(), // Pushes the logout button to the bottom
          const Divider(),
          
          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              // Close the drawer first
              Navigator.pop(context);
              
              // Call Sign Out
              await ref.read(authRepositoryProvider).signOut();
              
              // The Router's AuthGuard will automatically redirect to /login
            },
          ),
          const Gap(16),
        ],
      ),
    );
  }
}