import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatefulWidget {
  final List<String> results;
  final String actionType;

  const ResultScreen({
    super.key,
    required this.results,
    required this.actionType,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final Set<int> _savedIndices = {};

  Future<void> _saveLocally(String content, int index) async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('saved_items') ?? [];

    final Map<String, String> item = {
      'content': content,
      'type': widget.actionType,
      'date': DateTime.now().toIso8601String(),
    };

    final itemJson = json.encode(item);

    // Filter out duplicates and legacy string-only items
    bool alreadySaved = false;
    for (final s in savedList) {
      try {
        final decoded = json.decode(s);
        if (decoded['content'] == content) {
          alreadySaved = true;
          break;
        }
      } catch (_) {
        if (s == content) {
          alreadySaved = true;
          break;
        }
      }
    }

    if (!alreadySaved) {
      savedList.add(itemJson);
      await prefs.setStringList('saved_items', savedList);
    }

    setState(() {
      _savedIndices.add(index);
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Saved to Favorites!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _copyToClipboard(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _shareContent(String content) {
    Share.share(content);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Your ${widget.actionType}${widget.actionType.toLowerCase().endsWith('s') ? '' : 's'}',
          style: textTheme.titleLarge,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.pop(context); // Go back to input to regenerate
            },
            tooltip: 'Regenerate',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(24.0),
                itemCount: widget.results.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final content = widget.results[index];
                  final isSaved = _savedIndices.contains(index);

                  return Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.actionType == 'Quotes' ? '"$content"' : content,
                            style: widget.actionType == 'Quotes'
                                ? textTheme.headlineSmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: colorScheme.primary,
                                    height: 1.4,
                                  )
                                : textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () => _copyToClipboard(content),
                                icon: Icon(
                                  Icons.copy_rounded,
                                  color: colorScheme.primary,
                                ),
                                tooltip: 'Copy',
                              ),
                              IconButton(
                                onPressed: () => _shareContent(content),
                                icon: Icon(
                                  Icons.share_rounded,
                                  color: colorScheme.primary,
                                ),
                                tooltip: 'Share',
                              ),
                              IconButton(
                                onPressed: isSaved
                                    ? null
                                    : () => _saveLocally(content, index),
                                icon: Icon(
                                  isSaved ? Icons.favorite : Icons.favorite_border,
                                  color: isSaved ? Colors.red : colorScheme.primary,
                                ),
                                tooltip: 'Save',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Disclaimer: AI-generated content may be inaccurate or inappropriate. Please review and edit before posting.',
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
