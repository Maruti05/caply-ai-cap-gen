import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../input/input_screen.dart';

class CaptionTab extends StatefulWidget {
  const CaptionTab({super.key});

  @override
  State<CaptionTab> createState() => _CaptionTabState();
}

class _CaptionTabState extends State<CaptionTab> {
  String _selectedPlatform = 'Instagram';

  final Map<String, dynamic> _platforms = {
    'Instagram': FontAwesomeIcons.instagram,
    'TikTok': FontAwesomeIcons.tiktok,
    'Twitter / X': FontAwesomeIcons.xTwitter,
    'LinkedIn': FontAwesomeIcons.linkedin,
    'Facebook': FontAwesomeIcons.facebook,
    'YouTube': FontAwesomeIcons.youtube,
    'Pinterest': FontAwesomeIcons.pinterest,
    'Threads': FontAwesomeIcons.at,
    'Snapchat': FontAwesomeIcons.snapchat,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Creative', style: textTheme.labelLarge?.copyWith(color: colorScheme.primary)),
                  Text('Captions', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Generate perfect captions for your posts.',
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          Text('Select Platform', style: textTheme.titleMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _platforms.entries.map((entry) {
              final platform = entry.key;
              final dynamic icon = entry.value;
              final isSelected = _selectedPlatform == platform;
              
              return ChoiceChip(
                avatar: FaIcon(
                  icon, 
                  size: 14, 
                  color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant
                ),
                label: Text(platform),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedPlatform = platform);
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                side: BorderSide.none,
                selectedColor: colorScheme.secondaryContainer,
                backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              );
            }).toList(),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InputScreen(
                      platform: _selectedPlatform,
                      actionType: 'Caption',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.edit_note_rounded),
                  SizedBox(width: 12),
                  Text('Start Generating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
