import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'platform_content_tab.dart';

class BioTab extends StatelessWidget {
  const BioTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlatformContentTab(
      label: 'Unique',
      title: 'Profiles',
      description: 'Create catchy bios that define your profile.',
      actionType: 'Bio',
      buttonIcon: Icons.person_pin_rounded,
      buttonText: 'Start Generating',
      platforms: {
        'Instagram': FontAwesomeIcons.instagram,
        'TikTok': FontAwesomeIcons.tiktok,
        'Threads': FontAwesomeIcons.at,
        'Twitter / X': FontAwesomeIcons.xTwitter,
        'LinkedIn': FontAwesomeIcons.linkedin,
        'Pinterest': FontAwesomeIcons.pinterest,
      },
    );
  }
}
