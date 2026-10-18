import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';

import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/get_current_location.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/geo_point.dart';

import '../../domain/usecases/watch_location_updates.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repository = context.read<LocationRepository>();
        final cubit = MapCubit(
          GetCurrentLocation(repository),
          WatchLocationUpdates(repository),
        );

        if (AppConfig.simulateMovement) {
          cubit.startSimulation();
        } else {
          cubit.startRealLocationTracking();
        }

        return cubit;
      },
      child: const _MapView(),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final textTheme = theme.textTheme;

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: _MapCanvas(state: state),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR TRAIL',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'A little more of the world, remembered.',
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Your route and photo places stay on this phone.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    textStyle: textTheme.labelLarge,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Photo selection will be connected later.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_a_photo_outlined, size: 19),
                  label: const Text('Add a photo'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MapCanvas extends StatefulWidget {
  const _MapCanvas({required this.state});

  final MapState state;

  @override
  State<_MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<_MapCanvas> {
  MapLibreMapController? _controller;

  Circle? _simulatedMarker;
  bool _styleLoaded = false;

  Line? _trailLine;

  @override
  void didUpdateWidget(covariant _MapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state.location != widget.state.location) {
      if (widget.state.isSimulated) {
        _syncSimulatedMarker(widget.state.location);
      } else {
        _followRealLocation(widget.state.location);
      }
    }

    if (oldWidget.state.trailPoints != widget.state.trailPoints) {
      _syncTrail(widget.state.trailPoints);
    }
  }

  Future<void> _followRealLocation(GeoPoint? location) async {
    final controller = _controller;

    if (!_styleLoaded || controller == null || location == null) return;

    await controller.animateCamera(
      CameraUpdate.newLatLng(LatLng(location.latitude, location.longitude)),
      duration: const Duration(milliseconds: 1800),
    );
  }

  Future<void> _syncTrail(List<GeoPoint> points) async {
    final controller = _controller;

    if (!_styleLoaded || controller == null) return;

    if (points.length < 2) {
      if (_trailLine != null) {
        await controller.removeLine(_trailLine!);
        _trailLine = null;
      }
      return;
    }

    final options = LineOptions(
      geometry: points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(),
      lineColor: '#28664A',
      lineWidth: 4,
      lineOpacity: 0.85,
    );

    if (_trailLine == null) {
      _trailLine = await controller.addLine(options);
    } else {
      await controller.updateLine(_trailLine!, options);
    }
  }

  Future<void> _syncSimulatedMarker(GeoPoint? location) async {
    final controller = _controller;

    if (!_styleLoaded || controller == null || location == null) return;

    final options = CircleOptions(
      geometry: LatLng(location.latitude, location.longitude),
      circleRadius: 9,
      circleColor: '#28664A',
      circleStrokeColor: '#FFFFFF',
      circleStrokeWidth: 3,
    );

    if (_simulatedMarker == null) {
      _simulatedMarker = await controller.addCircle(options);
    } else {
      await controller.updateCircle(_simulatedMarker!, options);
    }

    await controller.animateCamera(
      CameraUpdate.newLatLng(LatLng(location.latitude, location.longitude)),
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final location = widget.state.location;

    final accuracy = location?.accuracyMeters;

    final gpsColor = switch (widget.state.status) {
      MapStatus.loadingLocation => Colors.amber,
      MapStatus.locationError => Colors.red,
      MapStatus.ready when accuracy == null => Colors.amber,
      MapStatus.ready when accuracy! <= 10 => Colors.green,
      MapStatus.ready when accuracy! <= 30 => Colors.amber,
      MapStatus.ready => Colors.red,
    };

    final gpsLabel = widget.state.isSimulated
        ? 'Simulated movement'
        : switch (widget.state.status) {
            MapStatus.loadingLocation => 'Finding location',
            MapStatus.locationError => 'Location unavailable',
            MapStatus.ready when accuracy == null => 'GPS accuracy unknown',
            MapStatus.ready when accuracy! <= 10 =>
              'Strong GPS · ±${accuracy.toStringAsFixed(0)} m',
            MapStatus.ready when accuracy! <= 30 =>
              'Fair GPS · ±${accuracy.toStringAsFixed(0)} m',
            MapStatus.ready => 'Weak GPS · ±${accuracy!.toStringAsFixed(0)} m',
          };

    return SizedBox(
      height: 460,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: location == null
                  ? ColoredBox(
                      color: colors.surfaceContainerHighest,
                      child: Center(
                        child: widget.state.status == MapStatus.loadingLocation
                            ? const CircularProgressIndicator()
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.state.errorMessage ??
                                        'Could not get your location.',
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  FilledButton(
                                    onPressed: () => context
                                        .read<MapCubit>()
                                        .startRealLocationTracking(),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                      ),
                    )
                  : MapLibreMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(location.latitude, location.longitude),
                        zoom: 15,
                      ),
                      styleString:
                          'https://tiles.openfreemap.org/styles/liberty',
                      myLocationEnabled: !widget.state.isSimulated,
                      onMapCreated: (controller) {
                        _controller = controller;
                        _syncSimulatedMarker(widget.state.location);
                      },
                      onStyleLoadedCallback: () {
                        _styleLoaded = true;
                        _syncSimulatedMarker(widget.state.location);
                        _syncTrail(widget.state.trailPoints);
                      },
                    ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 5, backgroundColor: gpsColor),
                      const SizedBox(width: 8),
                      Text(gpsLabel, style: theme.textTheme.labelMedium),
                    ],
                  ),
                ),
              ),
            ),
            if (location != null)
              Positioned(
                right: 12,
                bottom: 12,
                child: Column(
                  children: [
                    _zoomButton(
                      icon: Icons.add,
                      onPressed: () {
                        _controller?.animateCamera(CameraUpdate.zoomIn());
                      },
                    ),
                    const SizedBox(height: 8),
                    _zoomButton(
                      icon: Icons.remove,
                      onPressed: () {
                        _controller?.animateCamera(CameraUpdate.zoomOut());
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _zoomButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        tooltip: icon == Icons.add ? 'Zoom in' : 'Zoom out',
      ),
    );
  }
}
