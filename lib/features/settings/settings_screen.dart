import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../core/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Settings', style: textTheme.titleLarge),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            Text('Appearance', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _buildThemeOption(
                    context,
                    title: 'System Default',
                    mode: ThemeMode.system,
                    icon: Icons.settings_brightness_outlined,
                  ),
                  _buildThemeOption(
                    context,
                    title: 'Light Mode',
                    mode: ThemeMode.light,
                    icon: Icons.light_mode_outlined,
                  ),
                  _buildThemeOption(
                    context,
                    title: 'Dark Mode',
                    mode: ThemeMode.dark,
                    icon: Icons.dark_mode_outlined,
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 24),
            // Text('About', style: textTheme.titleMedium),
            // const SizedBox(height: 12),
            // Container(
            //   decoration: BoxDecoration(
            //     color: colorScheme.surfaceContainerHighest,
            //     borderRadius: BorderRadius.circular(24),
            //   ),
            //   child: Column(
            //     children: [
            //       ListTile(
            //         leading: const Icon(Icons.share_outlined),
            //         title: const Text('Share this application'),
            //         onTap: () {
            //           SharePlus.instance.share(
            //             ShareParams(text: 'Check out caply app at https://example.com'),
            //           );
            //         },
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(16),
            //         ),
            //       ),
            //       ListTile(
            //         leading: const Icon(Icons.star_rate_outlined),
            //         title: const Text('Rate this application'),
            //         onTap: () async {
            //           final InAppReview inAppReview = InAppReview.instance;
            //           if (await inAppReview.isAvailable()) {
            //             inAppReview.requestReview();
            //           }
            //         },
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(16),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required ThemeMode mode,
    required IconData icon,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isSelected = themeProvider.themeMode == mode;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: isSelected ? colorScheme.primary : null),
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : null,
      onTap: () {
        themeProvider.setThemeMode(mode);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
