import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  Map<String, List<Map<String, dynamic>>> _groupedItems = {
    'Caption': [],
    'Bio': [],
    'Quotes': [],
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedItems();
  }

  Future<void> _loadSavedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('saved_items') ?? [];
    
    Map<String, List<Map<String, dynamic>>> grouped = {
      'Caption': [],
      'Bio': [],
      'Quotes': [],
    };

    for (var itemStr in savedList) {
      try {
        final decoded = json.decode(itemStr);
        final type = decoded['type'] ?? 'Caption';
        if (grouped.containsKey(type)) {
          grouped[type]!.add(decoded);
        } else {
          // If it's a type we don't handle specifically, put it in Captions or ignore
          grouped['Caption']!.add(decoded);
        }
      } catch (_) {
        // Handle legacy items that are just strings
        grouped['Caption']!.add({'content': itemStr, 'type': 'Caption'});
      }
    }

    setState(() {
      _groupedItems = grouped;
      _isLoading = false;
    });
  }

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('saved_items') ?? [];
    
    savedList.removeWhere((s) {
      try {
        final decoded = json.decode(s);
        return decoded['content'] == item['content'] && decoded['type'] == item['type'];
      } catch (_) {
        return s == item['content'];
      }
    });

    await prefs.setStringList('saved_items', savedList);
    _loadSavedItems(); // Reload
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item removed'),
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
    SharePlus.instance.share(ShareParams(text: content));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            tabs: const [
              Tab(text: 'Captions'),
              Tab(text: 'Bios'),
              Tab(text: 'Quotes'),
            ],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _buildListForType('Caption'),
                      _buildListForType('Bio'),
                      _buildListForType('Quotes'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListForType(String type) {
    final items = _groupedItems[type] ?? [];
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return _buildEmptyState(textTheme, colorScheme, type);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24.0),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        final content = item['content'] ?? '';

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content, 
                  style: type == 'Quotes' 
                    ? textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic, color: colorScheme.primary)
                    : textTheme.bodyLarge
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _copyToClipboard(content),
                      icon: Icon(Icons.copy_rounded, color: colorScheme.primary, size: 20),
                      tooltip: 'Copy',
                    ),
                    IconButton(
                      onPressed: () => _shareContent(content),
                      icon: Icon(Icons.share_rounded, color: colorScheme.primary, size: 20),
                      tooltip: 'Share',
                    ),
                    IconButton(
                      onPressed: () => _deleteItem(item),
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(TextTheme textTheme, ColorScheme colorScheme, String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 64, color: colorScheme.primary.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'No saved ${type.toLowerCase()}s',
            style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
