import 'package:flutter/material.dart';
import '../../core/utils/ai_service.dart';
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

  bool _isLoading = false;
  bool _includeEmojis = true;
  bool _includeHashtags = true;

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

  void _generateContent() async {
    if (_isLoading) return;

    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() => _isLoading = true);

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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ResultScreen(results: results, actionType: widget.actionType),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage;
      if (e is AppException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Something went wrong. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('New ${widget.actionType}', style: textTheme.titleLarge),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.actionType == 'Quotes'
                      ? "What's the category?"
                      : 'What is this about?',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _promptController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Enter your content...',
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
                      onSelected: (_) {
                        setState(() => _selectedStyle = style);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                SwitchListTile(
                  title: const Text('Include Emojis'),
                  value: _includeEmojis,
                  onChanged: (v) => setState(() => _includeEmojis = v),
                ),

                SwitchListTile(
                  title: const Text('Include Hashtags'),
                  value: _includeHashtags,
                  onChanged: (v) => setState(() => _includeHashtags = v),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _generateContent,
                    child: const Text('Generate'),
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}