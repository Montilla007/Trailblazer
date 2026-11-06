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
  static const _liveTrailSourceId = 'live-trail-source';
  static const _liveTrailLayerId = 'live-trail-layer';
  static const _savedTrailSourceId = 'saved-trail-source';
  static const _savedTrailLayerId = 'saved-trail-layer';
  static const _savedTrailColor = Color(0xFF1976D2);
  static const _emptyFeatureCollection =
      '{"type":"FeatureCollection","features":[]}';

  final ViewportController _viewportController = ViewportController();

  MapboxMap? _mapboxMap;
  GeoJsonSource? _liveTrailSource;
  GeoJsonSource? _savedTrailSource;
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
              previous.trailPoints != current.trailPoints ||
              previous.isLiveTrailVisible != current.isLiveTrailVisible,
          listener: (context, state) {
            unawaited(
              _updateLiveTrail(
                state.trailPoints,
                visible: state.isLiveTrailVisible,
              ),
            );
          },
        ),
        BlocListener<MapBloc, MapState>(
          listenWhen: (previous, current) =>
              previous.savedTrailPoints != current.savedTrailPoints,
          listener: (context, state) {
            unawaited(
              _updateSavedTrail(
                state.savedTrailPoints,
                visible: state.isSavedTrailVisible,
              ),
            );
          },
        ),
        BlocListener<MapBloc, MapState>(
          listenWhen: (previous, current) =>
              previous.savedTrailLocalDay != current.savedTrailLocalDay,
          listener: (context, state) {
            unawaited(
              _displaySavedTrail(
                state.savedTrailPoints,
                visible: state.isSavedTrailVisible,
              ),
            );
          },
        ),
        BlocListener<MapBloc, MapState>(
          listenWhen: (previous, current) =>
              previous.isSavedTrailVisible != current.isSavedTrailVisible,
          listener: (context, state) {
            unawaited(
              _updateSavedTrail(
                state.savedTrailPoints,
                visible: state.isSavedTrailVisible,
              ),
            );
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
    if (map == null || _liveTrailSource != null) return;

    final liveTrailSource = GeoJsonSource(
      id: _liveTrailSourceId,
      data: _emptyFeatureCollection,
      dynamicData: true,
    );

    await map.addSource(liveTrailSource);
    await map.addLayer(
      LineLayer(
        id: _liveTrailLayerId,
        sourceId: _liveTrailSourceId,
        lineJoin: LineJoin.ROUND,
        lineCap: LineCap.ROUND,
        lineColor: const Color(0xFF28664A).toARGB32(),
        lineWidth: 5,
      ),
    );

    final savedTrailSource = GeoJsonSource(
      id: _savedTrailSourceId,
      data: _emptyFeatureCollection,
      dynamicData: true,
    );

    await map.addSource(savedTrailSource);
    await map.addLayer(
      LineLayer(
        id: _savedTrailLayerId,
        sourceId: _savedTrailSourceId,
        lineJoin: LineJoin.ROUND,
        lineCap: LineCap.ROUND,
        lineColor: _savedTrailColor.toARGB32(),
        lineWidth: 4,
      ),
    );
    _liveTrailSource = liveTrailSource;
    _savedTrailSource = savedTrailSource;
    _startPuckSampling(bloc);

    await _updateLiveTrail(
      bloc.state.trailPoints,
      visible: bloc.state.isLiveTrailVisible,
    );
    await _displaySavedTrail(
      bloc.state.savedTrailPoints,
      visible: bloc.state.isSavedTrailVisible,
    );
  }

  Future<void> _updateLiveTrail(
    List<GeoPoint> points, {
    required bool visible,
  }) async {
    final source = _liveTrailSource;
    if (source == null) return;

    await source.updateGeoJSON(
      visible ? _trailToGeoJson(points) : _emptyFeatureCollection,
    );
  }

  Future<void> _updateSavedTrail(
    List<GeoPoint> points, {
    required bool visible,
  }) async {
    final source = _savedTrailSource;
    if (source == null) return;

    await source.updateGeoJSON(
      visible ? _trailToGeoJson(points) : _emptyFeatureCollection,
    );
  }

  Future<void> _displaySavedTrail(
    List<GeoPoint> points, {
    required bool visible,
  }) async {
    if (_savedTrailSource == null) return;

    await _updateSavedTrail(points, visible: visible);

    final map = _mapboxMap;
    if (!visible || map == null || points.isEmpty) return;

    final coordinates = points
        .map(
          (point) =>
              Point(coordinates: Position(point.longitude, point.latitude)),
        )
        .toList(growable: false);
    final camera = await map.cameraForCoordinatesPadding(
      coordinates,
      CameraOptions(bearing: 0, pitch: 0),
      MbxEdgeInsets(top: 80, left: 40, bottom: 80, right: 40),
      17,
      null,
    );

    final center = camera.center;
    if (center == null) return;

    _viewportController.moveTo(
      CameraViewportState(
        center: center,
        zoom: camera.zoom,
        bearing: camera.bearing,
        pitch: camera.pitch,
      ),
      transition: const DefaultViewportTransition(),
    );
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
          accuracyMeters: bloc.state.effectiveAccuracyMeters,
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
