import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:trailblazer/src/features/map/domain/repositories/location_repository.dart';
import 'package:trailblazer/src/features/map/domain/usecases/watch_location_updates.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_event.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_state.dart';

import '../bloc/map_bloc.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) =>
          MapBloc(WatchLocationUpdates(context.read<LocationRepository>()))
            ..add(const MapTrackingRequested()),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  
  final ViewportController _viewportController = ViewportController();
  final List<StreamSubscription<dynamic>> _gestureSubscriptions = [];
  final FollowPuckViewportState _followPuckViewport = FollowPuckViewportState(
    zoom: 15,
    bearing: FollowPuckViewportStateBearingConstant(0),
    pitch: 0,
  );

  MapboxMap? _mapboxMap;
  Timer? _puckLogTimer;

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapState>(
      listenWhen: (previous, current) =>
          previous.viewportMode != current.viewportMode,
      listener: (context, state) {
        final shouldFollow =
            state.viewportMode == MapViewportMode.followingPuck;

        _viewportController.moveTo(
          shouldFollow ? _followPuckViewport : const IdleViewportState(),
          transition: shouldFollow ? const DefaultViewportTransition() : null,
        );
      },
      child: SizedBox.expand(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: MapWidget(
                  viewportController: _viewportController,
                  onMapCreated: (mapboxMap) {
                    _onMapCreated(context, mapboxMap);
                  },
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.small(
                  heroTag: 'map-recenter',
                  tooltip: 'Recenter on my location',
                  onPressed: () {
                    context.read<MapBloc>().add(
                      const MapViewportFollowRequested(),
                    );
                  },
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onMapCreated(BuildContext context, MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    _gestureSubscriptions.add(
      mapboxMap.gestures.pan.gestureEvents.listen((event) {
        if (event.gestureState == GestureState.started && mounted) {
          context.read<MapBloc>().add(const MapViewportFollowPaused());
        }
      }),
    );

    await mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        showAccuracyRing: true,
        puckBearingEnabled: true,
        puckBearing: PuckBearing.HEADING,
      ),
    );

    if (!mounted) return;

    // Start following after the map and location puck are ready.
    context.read<MapBloc>().add(const MapViewportFollowRequested());
  }

  void _resumeFollowing() {
    if (_mapboxMap == null) {
      debugPrint('[MAP] Cannot follow yet: map is not ready');
      return;
    }

    debugPrint('[MAP] Requesting puck follow');

    _viewportController.moveTo(
      FollowPuckViewportState(
        zoom: 15,
        bearing: FollowPuckViewportStateBearingConstant(0),
        pitch: 0,
      ),
      transition: const DefaultViewportTransition(),
      completion: (finished) {
        debugPrint('[MAP] Follow transition finished: $finished');
      },
    );
  }

  Future<void> _logPuckPosition() async {
    final map = _mapboxMap;
    if (map == null) return;

    try {
      final layer = await map.style.getLayer('mapbox-location-indicator-layer');

      if (layer is! LocationIndicatorLayer) return;

      final coordinates = layer.location;
      if (coordinates == null || coordinates.length < 2) return;

      // Mapbox's example converts these coordinates to Position(longitude, latitude).
      final puck = Position(coordinates[1]!, coordinates[0]!);

      debugPrint(
        '[PUCK] lat=${puck.lat.toStringAsFixed(6)}, '
        'lon=${puck.lng.toStringAsFixed(6)}',
      );
    } catch (error) {
      debugPrint('[PUCK] Could not read puck position: $error');
    }
  }

  @override
  void dispose() {
    for (final subscription in _gestureSubscriptions) {
      unawaited(subscription.cancel());
    }

    _viewportController.dispose();
    super.dispose();
  }
}
