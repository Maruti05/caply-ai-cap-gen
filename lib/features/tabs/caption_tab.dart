import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'platform_content_tab.dart';

class CaptionTab extends StatelessWidget {
  const CaptionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlatformContentTab(
      label: 'Creative',
      title: 'Captions',
      description: 'Generate perfect captions for your posts.',
      actionType: 'Caption',
      buttonIcon: Icons.edit_note_rounded,
      buttonText: 'Start Generating',
      platforms: {
        'Instagram': FontAwesomeIcons.instagram,
        'TikTok': FontAwesomeIcons.tiktok,
        'Twitter / X': FontAwesomeIcons.xTwitter,
        'LinkedIn': FontAwesomeIcons.linkedin,
        'Facebook': FontAwesomeIcons.facebook,
        'YouTube': FontAwesomeIcons.youtube,
        'Pinterest': FontAwesomeIcons.pinterest,
        'Threads': FontAwesomeIcons.at,
        'Snapchat': FontAwesomeIcons.snapchat,
      },
    );
  }
}
