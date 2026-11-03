import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trailblazer/src/features/map/domain/repositories/location_repository.dart';
import 'package:trailblazer/src/features/map/domain/repositories/route_history_repository.dart';
import 'package:trailblazer/src/features/map/domain/usecases/save_route_point.dart';
import 'package:trailblazer/src/features/map/domain/usecases/watch_location_updates.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_bloc.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_event.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_state.dart';
import 'package:trailblazer/src/shared/widgets/gps_accuracy_indicator.dart';

import '../widgets/map_canvas.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) => MapBloc(
        WatchLocationUpdates(context.read<LocationRepository>()),
        SaveRoutePoint(context.read<RouteHistoryRepository>()),
      )..add(const MapTrackingRequested()),
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
}
