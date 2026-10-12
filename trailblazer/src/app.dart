import 'package:flutter/material.dart';

import 'screens/placeholder_page.dart';
import 'theme/app_theme.dart';

class TrailblazerApp extends StatefulWidget {
  const TrailblazerApp({super.key});

  @override
  State<TrailblazerApp> createState() => _TrailblazerAppState();
}

class _TrailblazerAppState extends State<TrailblazerApp> {
  ThemeMode _themeMode = ThemeMode.light;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trailblazer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Trailblazer'),
          actions: [
            IconButton(
              tooltip: 'Open menu',
              icon: const Icon(Icons.menu_rounded),
              onPressed: _showMenu,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            PlaceholderPage(
              icon: Icons.map_outlined,
              title: 'Map',
              message: 'The map will be built after the app foundation.',
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
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
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
      ),
    );
  }

  void _showMenu() {
    var darkModeEnabled = _themeMode == ThemeMode.dark;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    secondary: const Icon(Icons.palette_outlined),
                    title: const Text('Appearance'),
                    subtitle: Text(darkModeEnabled ? 'Dark mode' : 'Light mode'),
                    value: darkModeEnabled,
                    onChanged: (enabled) {
                      setSheetState(() => darkModeEnabled = enabled);
                      setState(() {
                        _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
                      });
                    },
                  ),
                  const Divider(height: 12),
                  _placeholderMenuItem(
                    icon: Icons.directions_walk_outlined,
                    label: 'Recording & movement',
                  ),
                  _placeholderMenuItem(
                    icon: Icons.lock_outline_rounded,
                    label: 'Privacy & storage',
                  ),
                  _placeholderMenuItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About & help',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _placeholderMenuItem({required IconData icon, required String label}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon),
      title: Text(label),
      onTap: () {},
    );
  }
}
