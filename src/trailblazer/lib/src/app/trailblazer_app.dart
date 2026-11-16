import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trailblazer/src/app/app_shell.dart';
import 'package:trailblazer/src/core/theme/app_theme.dart';
import 'package:trailblazer/src/features/route_history/data/datasources/route_database.dart';
import 'package:trailblazer/src/features/route_history/data/datasources/route_local_data_source.dart';
import 'package:trailblazer/src/features/route_history/data/repositories/route_history_repository_impl.dart';
import 'package:trailblazer/src/features/route_history/domain/repositories/route_history_repository.dart';
import 'package:trailblazer/src/features/navigation/presentation/cubit/navigation_cubit.dart';
import 'package:trailblazer/src/features/settings/presentation/cubit/appearance_cubit.dart';
import 'package:trailblazer/src/features/location_tracking/data/datasources/device_location_data_source.dart';
import 'package:trailblazer/src/features/location_tracking/data/datasources/foreground_recording_data_source.dart';
import 'package:trailblazer/src/features/location_tracking/data/repositories/location_repository_impl.dart';
import 'package:trailblazer/src/features/location_tracking/domain/repositories/location_repository.dart';

class TrailblazerApp extends StatelessWidget {
  const TrailblazerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ForegroundRecordingDataSource>(
          create: (_) => ForegroundRecordingDataSource(),
          dispose: (source) => source.dispose(),
        ),
        RepositoryProvider<LocationRepository>(
          create: (context) => LocationRepositoryImpl(
            DeviceLocationDataSource(),
            context.read<ForegroundRecordingDataSource>(),
          ),
        ),
        RepositoryProvider<RouteDatabase>(
          create: (_) => RouteDatabase(),
          dispose: (database) => database.close(),
        ),
        RepositoryProvider<RouteHistoryRepository>(
          create: (context) => RouteHistoryRepositoryImpl(
            RouteLocalDataSource(context.read<RouteDatabase>()),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => NavigationCubit()),
          BlocProvider(create: (_) => AppearanceCubit()),
        ],
        child: BlocBuilder<AppearanceCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'Trailblazer',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              home: const AppShell(),
            );
          },
        ),
      ),
    );
  }
}
