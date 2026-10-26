import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trailblazer/src/features/map/presentation/bloc/map_bloc.dart';
import 'package:trailblazer/src/features/map/presentation/bloc/map_state.dart';

class GpsAccuracyIndicator extends StatelessWidget {
  const GpsAccuracyIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (previous, current) =>
          previous.accuracyMeters != current.accuracyMeters ||
          previous.status != current.status,
      builder: (context, state) {
        final accuracy = state.accuracyMeters;
        final hasUsableAccuracy =
            state.status == MapStatus.tracking &&
            accuracy != null &&
            accuracy.isFinite &&
            accuracy >= 0;

        late final String label;
        late final Color indicatorColor;

        if (!hasUsableAccuracy) {
          label = 'GPS accuracy unavailable';
          indicatorColor = theme.colorScheme.onSurfaceVariant;
        } else if (accuracy < 10) {
          label = 'Strong';
          indicatorColor = isDark
              ? const Color(0xFF78D39B)
              : const Color(0xFF2E7D32);
        } else if (accuracy < 20) {
          label = 'Fair';
          indicatorColor = isDark
              ? const Color(0xFFFFD166)
              : const Color(0xFF9A6700);
        } else {
          label = 'Poor';
          indicatorColor = isDark
              ? const Color(0xFFFF8A80)
              : const Color(0xFFC62828);
        }

        final accuracyText = hasUsableAccuracy
            ? '±${accuracy.toStringAsFixed(1)} m'
            : null;

        return Semantics(
          label: accuracyText == null
              ? label
              : 'GPS $label, accuracy $accuracyText',
          child: Material(
            elevation: 3,
            color: theme.colorScheme.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.gps_fixed_rounded,
                    size: 18,
                    color: indicatorColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: theme.textTheme.labelLarge,
                  ),
                  if (accuracyText != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      accuracyText,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}