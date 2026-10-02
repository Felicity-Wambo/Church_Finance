import 'package:church_finance/features/dashboard/data/repository/dashboard_repository.dart';
import 'package:church_finance/features/giving/data/repositories/giving_repositories.dart';
import 'package:church_finance/features/giving/domain/use_cases/get_giving_history._use_case.dart';
import 'package:church_finance/features/giving/presentation/providers/giving_providers.dart';
import 'package:church_finance/shared/services/api_service.dart';
import 'package:church_finance/shared/services/local_storage_service.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'core/constants/api_endpoints.dart';
import 'core/themes/light_theme.dart';
import 'routing/app_router.dart';

// AUTH
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

// DASHBOARD
import 'features/dashboard/domain/use_cases/get_dashboard_data_use_case.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';

// GIVING
import 'features/giving/domain/use_cases/process_giving_use_case.dart';

// PLEDGE
import 'features/pledge/presentation/providers/pledge_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // HIVE
  // ============================================================

  await Hive.initFlutter();

  await Hive.openBox(
    'churchFinance',
  );

  // ============================================================
  // SHARED PREFERENCES
  // ============================================================

  final prefs =
      await SharedPreferences.getInstance();

  final localStorage =
      LocalStorageService(prefs);

  // ============================================================
  // DIO
  // ============================================================

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout:
          const Duration(seconds: 120),
      receiveTimeout:
          const Duration(seconds: 120),
      sendTimeout:
          const Duration(seconds: 120),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // ============================================================
  // API SERVICE
  // ============================================================

  final apiService =
      ApiService(dio);

  // ============================================================
  // REPOSITORIES
  // ============================================================

  final authRepository =
      AuthRepository(apiService);

  final dashboardRepository =
      DashboardRepository(apiService);

  final givingRepository =
      GivingRepository(apiService);

  // ============================================================
  // USE CASES
  // ============================================================

  final getDashboardDataUseCase =
      GetDashboardDataUseCase(
    dashboardRepository,
  );

  final processGivingUseCase =
      ProcessGivingUseCase(
    givingRepository,
  );

  final getGivingHistoryUseCase =
      GetGivingHistoryUseCase(
    givingRepository,
  );

  // ============================================================
  // AUTH PROVIDER
  // ============================================================

  final authProvider =
      AuthProvider(
    repository: authRepository,
    storage: localStorage,
  );

  // ============================================================
  // RUN APP
  // ============================================================

  runApp(
    MultiProvider(
      providers: [
        // AUTH
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
        ),

        // DASHBOARD
        ChangeNotifierProvider(
          create: (_) =>
              DashboardProvider(
            getDashboardDataUseCase,
          ),
        ),

        // GIVING
        ChangeNotifierProvider(
          create: (_) =>
              GivingProvider(
            processGivingUseCase:
                processGivingUseCase,
            getGivingHistoryUseCase:
                getGivingHistoryUseCase,
            givingRepository:
                givingRepository,
          ),
        ),

        // PLEDGE
        ChangeNotifierProvider(
          create: (_) =>
              PledgeProvider(),
        ),
      ],
      child: ChurchFinanceApp(
        authProvider:
            authProvider,
      ),
    ),
  );
}

class ChurchFinanceApp
    extends StatelessWidget {
  final AuthProvider authProvider;

  const ChurchFinanceApp({
    super.key,
    required this.authProvider,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp.router(
      title:
          'Church Financial Management',
      theme:
          LightTheme.theme,
      debugShowCheckedModeBanner:
          false,
      routerConfig:
          AppRouter.createRouter(
        authProvider,
      ),
    );
  }
}

