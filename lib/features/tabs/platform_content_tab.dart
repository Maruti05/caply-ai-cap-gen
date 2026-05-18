import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/widgets/ad_banner_widget.dart';
import '../input/input_screen.dart';

class PlatformContentTab extends HookWidget {
  final String label;
  final String title;
  final String description;
  final String actionType;
  final IconData buttonIcon;
  final String buttonText;
  final Map<String, FaIconData> platforms;

  const PlatformContentTab({
    super.key,
    required this.label,
    required this.title,
    required this.description,
    required this.actionType,
    required this.buttonIcon,
    required this.buttonText,
    required this.platforms,
  });

  @override
  Widget build(BuildContext context) {
    final selectedPlatform = useState('Instagram');
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        const AdBannerWidget(
          padding: EdgeInsets.symmetric(vertical: 4),
          showDivider: true,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(textTheme, colorScheme),
                        const SizedBox(height: 32),
                        Text(
                          description,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text('Select Platform', style: textTheme.titleMedium),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: platforms.entries.map((entry) {
                            final platform = entry.key;
                            final isSelected =
                                selectedPlatform.value == platform;
                            return ChoiceChip(
                              avatar: FaIcon(
                                entry.value,
                                size: 14,
                                color: isSelected
                                    ? colorScheme.onSecondaryContainer
                                    : colorScheme.onSurfaceVariant,
                              ),
                              label: Text(platform),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  selectedPlatform.value = platform;
                                }
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              side: BorderSide.none,
                              selectedColor: colorScheme.secondaryContainer,
                              backgroundColor: colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 48),
                        _buildButton(
                          context,
                          colorScheme,
                          selectedPlatform.value,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const Image(
              image: AssetImage('assets/images/logo.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
            ),
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context,
    ColorScheme colorScheme,
    String platform,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  InputScreen(platform: platform, actionType: actionType),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(buttonIcon),
            const SizedBox(width: 12),
            Text(
              buttonText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
