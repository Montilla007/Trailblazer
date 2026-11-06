import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trailblazer/src/features/map/domain/repositories/location_repository.dart';
import 'package:trailblazer/src/features/map/domain/repositories/route_history_repository.dart';
import 'package:trailblazer/src/features/map/domain/usecases/delete_all_saved_routes.dart';
import 'package:trailblazer/src/features/map/domain/usecases/get_all_saved_route_points.dart';
import 'package:trailblazer/src/features/map/domain/usecases/get_route_for_day.dart';
import 'package:trailblazer/src/features/map/domain/usecases/save_route_point.dart';
import 'package:trailblazer/src/features/map/domain/usecases/watch_location_updates.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_bloc.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_event.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_state.dart';
import 'package:trailblazer/src/shared/widgets/debug_action_panel.dart';
import 'package:trailblazer/src/shared/widgets/gps_accuracy_indicator.dart';

import '../widgets/map_canvas.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) {
        final repository = context.read<RouteHistoryRepository>();
        final bloc = MapBloc(
          WatchLocationUpdates(context.read<LocationRepository>()),
          SaveRoutePoint(repository),
          GetRoutePointsForDay(repository),
          GetAllSavedRoutePoints(repository),
          DeleteAllSavedRoutes(repository),
        )..add(const MapTrackingRequested());

        if (kDebugMode) {
          bloc.add(const MapAllSavedTrailLoadRequested());
        }

        return bloc;
      },
      child: const _MapView(),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            const Positioned.fill(child: MapCanvas()),
            const Positioned(top: 16, left: 16, child: GpsAccuracyIndicator()),
            if (kDebugMode)
              Positioned(
                left: 16,
                bottom: 16,
                child: BlocBuilder<MapBloc, MapState>(
                  buildWhen: (previous, current) =>
                      previous.isLiveTrailVisible !=
                          current.isLiveTrailVisible ||
                      previous.isSavedTrailVisible !=
                          current.isSavedTrailVisible ||
                      previous.debugAccuracyMode != current.debugAccuracyMode ||
                      previous.debugMessage != current.debugMessage ||
                      previous.debugMessageIsError !=
                          current.debugMessageIsError,
                  builder: (context, state) {
                    return DebugActionPanel(
                      message: state.debugMessage,
                      messageIsError: state.debugMessageIsError,
                      actions: [
                        DebugPanelAction(
                          label: 'Accuracy: Unavailable',
                          icon: Icons.gps_off_rounded,
                          onPressed: () {
                            context.read<MapBloc>().add(
                              const MapDebugAccuracyModeSelected(
                                DebugAccuracyMode.unavailable,
                              ),
                            );
                          },
                        ),
                        DebugPanelAction(
                          label: 'Accuracy: Poor',
                          icon: Icons.signal_cellular_alt_1_bar,
                          onPressed: () {
                            context.read<MapBloc>().add(
                              const MapDebugAccuracyModeSelected(
                                DebugAccuracyMode.poor,
                              ),
                            );
                          },
                        ),
                        DebugPanelAction(
                          label: 'Accuracy: Fair',
                          icon: Icons.signal_cellular_alt_2_bar,
                          onPressed: () {
                            context.read<MapBloc>().add(
                              const MapDebugAccuracyModeSelected(
                                DebugAccuracyMode.fair,
                              ),
                            );
                          },
                        ),
                        DebugPanelAction(
                          label: 'Accuracy: Strong',
                          icon: Icons.signal_cellular_alt,
                          onPressed: () {
                            context.read<MapBloc>().add(
                              const MapDebugAccuracyModeSelected(
                                DebugAccuracyMode.strong,
                              ),
                            );
                          },
                        ),
                        DebugPanelAction(
                          label: state.isLiveTrailVisible
                              ? 'Hide live trail'
                              : 'Show live trail',
                          icon: state.isLiveTrailVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          onPressed: () {
                            context.read<MapBloc>().add(
                              const MapLiveTrailVisibilityToggled(),
                            );
                          },
                        ),
                        DebugPanelAction(
                          label: state.isSavedTrailVisible
                              ? 'Hide saved trail'
                              : 'Show saved trail',
                          icon: state.isSavedTrailVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          onPressed: () {
                            context.read<MapBloc>().add(
                              const MapSavedTrailVisibilityToggled(),
                            );
                          },
                        ),
                        DebugPanelAction(
                          label: 'Load all saved routes',
                          icon: Icons.route_outlined,
                          onPressed: () {
                            context.read<MapBloc>().add(
                              const MapAllSavedTrailLoadRequested(),
                            );
                          },
                        ),
                        DebugPanelAction(
                          label: 'Load SQLite trail by date',
                          icon: Icons.route_outlined,
                          onPressed: () => _selectSavedTrailDate(context),
                        ),
                        DebugPanelAction(
                          label: 'Delete all saved routes',
                          icon: Icons.delete_outline,
                          isDestructive: true,
                          onPressed: () => _confirmDeleteAllRoutes(context),
                        ),
                      ],
                    );
                  },
                ),
              ),
            Positioned(
              right: 16,
              bottom: 16,
              child: BlocBuilder<MapBloc, MapState>(
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'map-pitch',
                        tooltip: state.pitch == 0
                            ? 'Switch to 3D view'
                            : 'Switch to 2D view',
                        onPressed: () {
                          context.read<MapBloc>().add(const MapPitchToggled());
                        },
                        child: Text(state.pitch == 0 ? '3D' : '2D'),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'map-zoom-in',
                        tooltip: 'Zoom in',
                        onPressed: () {
                          context.read<MapBloc>().add(
                            const MapZoomInRequested(),
                          );
                        },
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'map-zoom-out',
                        tooltip: 'Zoom out',
                        onPressed: () {
                          context.read<MapBloc>().add(
                            const MapZoomOutRequested(),
                          );
                        },
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'map-recenter',
                        tooltip: 'Recenter on my location',
                        onPressed: () {
                          context.read<MapBloc>().add(
                            const MapViewportFollowRequested(),
                          );
                        },
                        child: const Icon(Icons.my_location),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectSavedTrailDate(BuildContext context) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (selectedDate == null || !context.mounted) return;

    final localDay = [
      selectedDate.year.toString().padLeft(4, '0'),
      selectedDate.month.toString().padLeft(2, '0'),
      selectedDate.day.toString().padLeft(2, '0'),
    ].join('-');

    context.read<MapBloc>().add(MapSavedTrailLoadRequested(localDay: localDay));
  }

  Future<void> _confirmDeleteAllRoutes(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete all saved routes?'),
        content: const Text(
          'This permanently deletes all saved route history on this device. '
          'Live recording will continue, so new route points may be saved '
          'again after deletion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            child: const Text('Delete all'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      context.read<MapBloc>().add(const MapAllSavedRoutesDeleteRequested());
    }
  }
}
