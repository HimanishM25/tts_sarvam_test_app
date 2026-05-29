import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tts_sarvam_test_app/presentation/screens/shell_screen.dart';
import 'package:tts_sarvam_test_app/presentation/screens/recorder_screen.dart';
import 'package:tts_sarvam_test_app/presentation/screens/transcription_history_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/recorder',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/recorder',
              builder: (context, state) => const RecordingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const TranscriptionHistoryScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
