import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';

import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/get_current_location.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MapCubit(GetCurrentLocation(context.read<LocationRepository>()))
            ..loadCurrentLocation(),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final location = widget.state.location;

    final gpsColor = switch (widget.state.status) {
      MapStatus.loadingLocation => Colors.amber,
      MapStatus.ready => Colors.green,
      MapStatus.locationError => Colors.red,
    };

    final gpsLabel = switch (widget.state.status) {
      MapStatus.loadingLocation => 'Finding location',
      MapStatus.ready => 'Location found',
      MapStatus.locationError => 'Location unavailable',
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
                                        .loadCurrentLocation(),
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
                      myLocationEnabled: true,
                      onMapCreated: (controller) {
                        _controller = controller;
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
