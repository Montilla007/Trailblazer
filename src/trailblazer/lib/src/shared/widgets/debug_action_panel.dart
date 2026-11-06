import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DebugPanelAction {
  const DebugPanelAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDestructive;
}

class DebugActionPanel extends StatefulWidget {
  const DebugActionPanel({
    required this.actions,
    this.message,
    this.messageIsError = false,
    super.key,
  });

  final List<DebugPanelAction> actions;
  final String? message;
  final bool messageIsError;

  @override
  State<DebugActionPanel> createState() => _DebugActionPanelState();
}

class _DebugActionPanelState extends State<DebugActionPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isExpanded)
          SizedBox(
            width: 260,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Debug tools', style: theme.textTheme.titleSmall),
                    if (widget.message != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.message!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: widget.messageIsError
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    for (final action in widget.actions)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: action.onPressed,
                          icon: Icon(
                            action.icon,
                            color: action.isDestructive
                                ? theme.colorScheme.error
                                : null,
                          ),
                          label: Text(action.label),
                          style: action.isDestructive
                              ? TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                )
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        FloatingActionButton.small(
          heroTag: null,
          tooltip: _isExpanded ? 'Close debug tools' : 'Open debug tools',
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          child: Icon(
            _isExpanded ? Icons.close_rounded : Icons.bug_report_outlined,
          ),
        ),
      ],
    );
  }
}
