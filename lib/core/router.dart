import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/main_wrapper.dart';
import '../features/home/screens/home_screen.dart';
import '../features/reading/screens/old_testament_screen.dart';
import '../features/reading/screens/new_testament_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      // StatefulShellRoute keeps the state of each tab alive 
      // (so we don't lose scroll position when switching tabs)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Old Testament
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/old-testament',
                builder: (context, state) => const OldTestamentScreen(),
              ),
            ],
          ),
          // Tab 2: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 3: New Testament
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/new-testament',
                builder: (context, state) => const NewTestamentScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});