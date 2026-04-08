import 'package:flutter/material.dart';
import '../input/input_screen.dart';

class QuoteTab extends StatefulWidget {
  const QuoteTab({super.key});

  @override
  State<QuoteTab> createState() => _QuoteTabState();
}

class _QuoteTabState extends State<QuoteTab> {
  String _selectedCategory = 'Motivation';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Motivation', 'icon': Icons.bolt_rounded},
    {'name': 'Success', 'icon': Icons.trending_up_rounded},
    {'name': 'Love', 'icon': Icons.favorite_rounded},
    {'name': 'Funny', 'icon': Icons.sentiment_very_satisfied_rounded},
    {'name': 'Life', 'icon': Icons.wb_sunny_rounded},
    {'name': 'Fitness', 'icon': Icons.fitness_center_rounded},
    {'name': 'Deep', 'icon': Icons.psychology_rounded},
    {'name': 'Witty', 'icon': Icons.auto_awesome_rounded},
  ];

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
                      color: colorScheme.secondary.withOpacity(0.1),
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
                  Text('Daily', style: textTheme.labelLarge?.copyWith(color: colorScheme.secondary)),
                  Text('Quotes', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Explore inspiring quotes for every mood.',
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          Text('Select Category', style: textTheme.titleMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat['name'];
              return ChoiceChip(
                avatar: Icon(
                  cat['icon'], 
                  size: 16, 
                  color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant
                ),
                label: Text(cat['name']),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedCategory = cat['name']);
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
                      platform: 'General',
                      actionType: 'Quotes',
                      initialPrompt: _selectedCategory, // Pass the category as initial prompt
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.auto_stories_rounded),
                  SizedBox(width: 12),
                  Text('Find Quotes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
