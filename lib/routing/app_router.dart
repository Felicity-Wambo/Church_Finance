import 'package:church_finance/features/auth/domain/use_cases/register_use_case.dart';
import 'package:church_finance/features/giving/data/models/giving_model.dart';
import 'package:church_finance/features/giving/presentation/screens/giving_processing_screen.dart';
import 'package:church_finance/features/giving/presentation/screens/giving_success_screen.dart';
import 'package:church_finance/features/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/giving/presentation/screens/give_screen.dart';
import '../features/giving/presentation/screens/giving_history_screen.dart';

class AppRouter {
  static GoRouter createRouter(
    AuthProvider authProvider,
  ) {
    return GoRouter(
      initialLocation: '/login',

      debugLogDiagnostics: true,

      redirect: (
        context,
        state,
      ) {
        final isAuthenticated =
            authProvider.isAuthenticated;

        final isLoginRoute =
            state.matchedLocation ==
                    '/login' ||
                state.matchedLocation ==
                    '/register';

        if (isAuthenticated &&
            isLoginRoute) {
          return '/dashboard';
        }

        if (!isAuthenticated &&
            !isLoginRoute) {
          return '/login';
        }

        return null;
      },

      routes: [
        // ============================================================
        // LOGIN
        // ============================================================

        GoRoute(
          path: '/login',
          name: 'login',
          builder: (
            context,
            state,
          ) {
            return const LoginScreen();
          },
        ),

        // ============================================================
        // REGISTER
        // ============================================================

        GoRoute(
          path: '/register',
          name: 'register',
          builder: (
            context,
            state,
          ) {
            return const RegisterScreen();
          },
        ),

        // ============================================================
        // DASHBOARD
        // ============================================================

        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (
            context,
            state,
          ) {
            return const DashboardScreen();
          },
        ),

        // ============================================================
        // GIVE
        // ============================================================

        GoRoute(
          path: '/give',
          name: 'give',
          builder: (
            context,
            state,
          ) {
            return const GiveScreen();
          },
        ),

        // ============================================================
        // GIVING PROCESSING
        // ============================================================

        GoRoute(
          path: '/giving/processing',
          name: 'giving-processing',
          builder: (
            context,
            state,
          ) {
            final extra =
                state.extra;

            if (extra is! GivingModel) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Giving information not available.',
                  ),
                ),
              );
            }

            return GivingProcessingScreen(
              giving: extra,
            );
          },
        ),

        // ============================================================
        // GIVING SUCCESS
        // ============================================================

        GoRoute(
          path: '/giving/success',
          name: 'giving-success',
          builder: (
            context,
            state,
          ) {
            final extra =
                state.extra;

            if (extra is! GivingModel) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Giving information not available.',
                  ),
                ),
              );
            }

            return GivingSuccessScreen(
              giving: extra,
            );
          },
        ),

        // ============================================================
        // HISTORY
        // ============================================================

        GoRoute(
          path: '/giving/history',
          name: 'giving-history',
          builder: (
            context,
            state,
          ) {
            return const GivingHistoryScreen();
          },
        ),

        // ============================================================
        // PROFILE
        // ============================================================

        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (
            context,
            state,
          ) {
            return const ProfileScreen();
          },
        ),
      ],
    );
  }
}