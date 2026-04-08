import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../tabs/caption_tab.dart';
import '../tabs/bio_tab.dart';
import '../tabs/quote_tab.dart';
import '../saved/saved_screen.dart';
import '../settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CaptionTab(), // Tab 0
    const BioTab(),     // Tab 1
    const QuoteTab(),   // Tab 2
    const SavedScreen(), // Tab 3
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _getTabTitle(_selectedIndex), 
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5), width: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 0),
          child: NavigationBar(
            height: 72,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
            indicatorColor: colorScheme.primary.withOpacity(0.1),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.edit_note_outlined, color: _selectedIndex == 0 ? colorScheme.primary : null),
                selectedIcon: Icon(Icons.edit_note_rounded, color: colorScheme.primary),
                label: 'Captions',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_pin_outlined, color: _selectedIndex == 1 ? colorScheme.primary : null),
                selectedIcon: Icon(Icons.person_pin_rounded, color: colorScheme.primary),
                label: 'Bios',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_stories_outlined, color: _selectedIndex == 2 ? colorScheme.primary : null),
                selectedIcon: Icon(Icons.auto_stories_rounded, color: colorScheme.primary),
                label: 'Quotes',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_border_rounded, color: _selectedIndex == 3 ? colorScheme.primary : null),
                selectedIcon: Icon(Icons.favorite_rounded, color: colorScheme.primary),
                label: 'Saved',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0: return 'Captions';
      case 1: return 'Bios';
      case 2: return 'Quotes';
      case 3: return 'Saved';
      default: return 'Caply';
    }
  }
}
