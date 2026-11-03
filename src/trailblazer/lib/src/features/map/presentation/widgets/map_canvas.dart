import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:trailblazer/src/features/map/domain/entities/geo_point.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_bloc.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_event.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_state.dart';

class MapCanvas extends StatefulWidget {
  const MapCanvas({super.key});

  @override
  State<MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<MapCanvas> {
  static const _trailSourceId = 'recorded-trail-source';
  static const _trailLayerId = 'recorded-trail-layer';
  static const _emptyFeatureCollection =
      '{"type":"FeatureCollection","features":[]}';

  final ViewportController _viewportController = ViewportController();

  MapboxMap? _mapboxMap;
  GeoJsonSource? _trailSource;
  StreamSubscription<dynamic>? _panGestureSubscription;
  Timer? _puckSamplingTimer;
  bool _puckSampleInFlight = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MapBloc, MapState>(
          listenWhen: (previous, current) =>
              previous.viewportMode != current.viewportMode ||
              previous.zoom != current.zoom ||
              previous.pitch != current.pitch,
          listener: (context, state) {
            if (state.viewportMode == MapViewportMode.followingPuck) {
              _viewportController.moveTo(
                FollowPuckViewportState(
                  zoom: state.zoom,
                  bearing: FollowPuckViewportStateBearingConstant(0),
                  pitch: state.pitch,
                ),
                transition: const DefaultViewportTransition(),
              );
              return;
            }

            final map = _mapboxMap;
            if (map == null) return;

            unawaited(
              map.easeTo(
                CameraOptions(zoom: state.zoom, pitch: state.pitch),
                MapAnimationOptions(duration: 300),
              ),
            );
          },
        ),
        BlocListener<MapBloc, MapState>(
          listenWhen: (previous, current) =>
              previous.trailPoints != current.trailPoints,
          listener: (context, state) {
            unawaited(_updateTrail(state.trailPoints));
          },
        ),
      ],
      child: MapWidget(
        viewportController: _viewportController,
        onMapCreated: (mapboxMap) {
          unawaited(_onMapCreated(context.read<MapBloc>(), mapboxMap));
        },
        onStyleLoadedListener: (_) {
          unawaited(_onStyleLoaded(context.read<MapBloc>()));
        },
      ),
    );
  }

  Future<void> _onMapCreated(MapBloc bloc, MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    _panGestureSubscription = mapboxMap.gestures.pan.gestureEvents.listen((
      event,
    ) {
      if (event.gestureState == GestureState.started && mounted) {
        bloc.add(const MapViewportFollowPaused());
      }
    });

    await mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        showAccuracyRing: true,
        puckBearingEnabled: true,
        puckBearing: PuckBearing.HEADING,
      ),
    );

    if (!mounted) return;

    bloc.add(const MapViewportFollowRequested());
  }

  Future<void> _onStyleLoaded(MapBloc bloc) async {
    final map = _mapboxMap;
    if (map == null || _trailSource != null) return;

    final source = GeoJsonSource(
      id: _trailSourceId,
      data: _emptyFeatureCollection,
      dynamicData: true,
    );

    await map.addSource(source);
    await map.addLayer(
      LineLayer(
        id: _trailLayerId,
        sourceId: _trailSourceId,
        lineJoin: LineJoin.ROUND,
        lineCap: LineCap.ROUND,
        lineColor: const Color(0xFF28664A).toARGB32(),
        lineWidth: 5,
      ),
    );

    _trailSource = source;
    _startPuckSampling(bloc);

    await _updateTrail(bloc.state.trailPoints);
  }

  Future<void> _updateTrail(List<GeoPoint> points) async {
    final source = _trailSource;
    if (source == null) return;

    await source.updateGeoJSON(_trailToGeoJson(points));
  }

  String _trailToGeoJson(List<GeoPoint> points) {
    if (points.length < 2) return _emptyFeatureCollection;

    return jsonEncode({
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'geometry': {
            'type': 'LineString',
            'coordinates': [
              for (final point in points) [point.longitude, point.latitude],
            ],
          },
          'properties': <String, Object?>{},
        },
      ],
    });
  }

  void _startPuckSampling(MapBloc bloc) {
    _puckSamplingTimer?.cancel();

    _puckSamplingTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => unawaited(_samplePuckPosition(bloc)),
    );
  }

  Future<void> _samplePuckPosition(MapBloc bloc) async {
    if (_puckSampleInFlight) return;

    final map = _mapboxMap;
    if (map == null) return;

    _puckSampleInFlight = true;

    try {
      final layer = await map.getLayer('mapbox-location-indicator-layer');

      if (layer is! LocationIndicatorLayer) return;

      final coordinates = layer.location;
      if (coordinates == null || coordinates.length < 2 || !mounted) return;

      bloc.add(
        MapPuckPositionSampled(
          latitude: coordinates[0]!,
          longitude: coordinates[1]!,
          sampledAt: DateTime.now().toUtc(),
          accuracyMeters: bloc.state.accuracyMeters,
        ),
      );
    } finally {
      _puckSampleInFlight = false;
    }
  }

  @override
  void dispose() {
    _puckSamplingTimer?.cancel();
    unawaited(_panGestureSubscription?.cancel());
    _viewportController.dispose();
    super.dispose();
  }
}
