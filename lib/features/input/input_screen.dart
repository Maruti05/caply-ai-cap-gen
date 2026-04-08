import 'package:flutter/material.dart';
import '../../core/utils/ai_service.dart';
import '../loading/loading_screen.dart';
import '../result/result_screen.dart';

class InputScreen extends StatefulWidget {
  final String platform;
  final String actionType;
  final String? initialPrompt;

  const InputScreen({
    super.key,
    required this.platform,
    required this.actionType,
    this.initialPrompt,
  });

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  late final TextEditingController _promptController;
  final AiService _aiService = AiService();
  late String _selectedStyle;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: widget.initialPrompt);
    _selectedStyle = _styles.first;
  }

  List<String> get _styles {
    if (widget.actionType == 'Quotes') {
      return ['Deep', 'Inspiring', 'Funny', 'Minimalist', 'Witty'];
    }
    return ['Professional', 'Funny', 'Aesthetic', 'Witty', 'Casual'];
  }

  bool _includeEmojis = true;
  bool _includeHashtags = true;

  void _generateContent() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoadingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    try {
      final results = await _aiService.generateContent(
        prompt: prompt,
        platform: widget.platform,
        style: _selectedStyle,
        type: widget.actionType,
        includeEmojis: _includeEmojis,
        includeHashtags: _includeHashtags,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ResultScreen(results: results, actionType: widget.actionType),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Pop loading screen
      
      final errorMessage = e.toString().contains('Exception: ') 
          ? e.toString().replaceAll('Exception: ', '') 
          : e.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  errorMessage,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('New ${widget.actionType}', style: textTheme.titleLarge),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.actionType == 'Quotes' ? "What's the category?" : 'What is this about?',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _promptController,
                maxLines: 5,
                style: textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: widget.actionType == 'Quotes'
                      ? 'e.g. Success, Love, Motivation, Fitness...'
                      : 'e.g. A photo of my cat sleeping on my laptop...',
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text('Tone & Style', style: textTheme.titleLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _styles.map((style) {
                  final isSelected = _selectedStyle == style;
                  return ChoiceChip(
                    label: Text(style),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedStyle = style;
                        });
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    side: BorderSide.none,
                    selectedColor: colorScheme.secondaryContainer,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Include Emojis', style: TextStyle(fontWeight: FontWeight.w500)),
                      value: _includeEmojis,
                      onChanged: (value) {
                        setState(() {
                          _includeEmojis = value;
                        });
                      },
                      secondary: Icon(
                        _includeEmojis ? Icons.emoji_emotions_outlined : Icons.block_outlined,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16),
                    SwitchListTile(
                      title: const Text('Include Hashtags', style: TextStyle(fontWeight: FontWeight.w500)),
                      value: _includeHashtags,
                      onChanged: (value) {
                        setState(() {
                          _includeHashtags = value;
                        });
                      },
                      secondary: Icon(
                        _includeHashtags ? Icons.numbers : Icons.block_outlined,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _generateContent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Generate',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
