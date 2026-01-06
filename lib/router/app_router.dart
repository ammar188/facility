import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/app/routes/app_routes.dart';
import 'package:facility/screens/auth/loginScreen.dart';
import 'package:facility/screens/dashboard/dashboard_screen.dart';
import 'package:facility/screens/home/homeScreen.dart';
import 'package:facility/screens/home/blocs/featured_products_cubit.dart';
import 'package:facility/screens/home/blocs/popular_products_cubit.dart';
import 'package:facility/screens/home/blocs/recent_products_cubit.dart';
import 'package:facility/screens/home/blocs/latest_products_cubit.dart';
import 'package:facility/screens/home/components/pinned_products_grid_view.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.login.path,
    routes: [
      GoRoute(
        path: AppRoutes.login.path,
        name: AppRoutes.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home.path,
        name: AppRoutes.home.name,
        builder: (context, state) {
          // Provide all product cubits needed by HomeScreen
          return MultiBlocProvider(
            providers: [
              BlocProvider<FeaturedProductsCubit>(
                create: (context) => FeaturedProductsCubit(),
              ),
              BlocProvider<PopularProductsCubit>(
                create: (context) => PopularProductsCubit(),
              ),
              BlocProvider<RecentProductsCubit>(
                create: (context) => RecentProductsCubit(),
              ),
              BlocProvider<LatestProductsCubit>(
                create: (context) => LatestProductsCubit(),
              ),
              BlocProvider<PinnedProductsCubit>(
                create: (context) => PinnedProductsCubit(),
              ),
            ],
            child: DefaultTabController(
              length: 5,
              child: Builder(
                builder: (context) {
                  final tabController = DefaultTabController.of(context);
                  return HomeScreen(tabController: tabController);
                },
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.dashBoard.path,
        name: AppRoutes.dashBoard.name,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.messages.path,
        name: AppRoutes.messages.name,
        builder: (context, state) {
          // Add your messages screen here
          return const Scaffold(
            body: Center(child: Text('Messages Screen')),
          );
        },
      ),
    ],
  );
}

