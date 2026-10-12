import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trailblazer/src/features/navigation/presentation/cubit/navigation_cubit.dart';
import 'package:trailblazer/src/features/settings/presentation/cubit/appearance_cubit.dart';
import 'package:trailblazer/src/shared/widgets/placeholder_page.dart';
import 'package:trailblazer/src/features/map/presentation/pages/map_page.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static const _pages = [
    MapPage(),
    PlaceholderPage(
      icon: Icons.map_outlined,
      title: 'Map',
      message: 'The map will be added after the app foundation.',
    ),
    PlaceholderPage(
      icon: Icons.photo_library_outlined,
      title: 'Album',
      message: 'Your photo collection will appear here.',
    ),
    PlaceholderPage(
      icon: Icons.history_rounded,
      title: 'History',
      message: 'Your daily routes will appear here.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, selectedIndex) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Trailblazer'),
            actions: [
              IconButton(
                tooltip: 'Open menu',
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => _showMenu(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: IndexedStack(
            index: selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected:
                context.read<NavigationCubit>().selectTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map_rounded),
                label: 'Map',
              ),
              NavigationDestination(
                icon: Icon(Icons.photo_library_outlined),
                selectedIcon: Icon(Icons.photo_library_rounded),
                label: 'Album',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_rounded),
                label: 'History',
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return BlocBuilder<AppearanceCubit, ThemeMode>(
          builder: (context, themeMode) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.palette_outlined),
                    title: const Text('Appearance'),
                    subtitle: Text(
                      themeMode == ThemeMode.dark ? 'Dark mode' : 'Light mode',
                    ),
                    value: themeMode == ThemeMode.dark,
                    onChanged: context.read<AppearanceCubit>().setDarkMode,
                  ),
                  const Divider(),
                  _inactiveMenuItem(
                    Icons.directions_walk_outlined,
                    'Recording & movement',
                  ),
                  _inactiveMenuItem(
                    Icons.lock_outline_rounded,
                    'Privacy & storage',
                  ),
                  _inactiveMenuItem(
                    Icons.info_outline_rounded,
                    'About & help',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _inactiveMenuItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {},
    );
  }
}