import 'package:flutter/material.dart';
import '../../../models/storybook.dart';
import 'create_storybook/functionality/slide_manager.dart';
import 'create_storybook.dart';

class StorybookScreen extends StatefulWidget {
  const StorybookScreen({super.key});

  @override
  State<StorybookScreen> createState() => _StorybookScreenState();
}

class _StorybookScreenState extends State<StorybookScreen> {
  List<Storybook> _storybooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStorybooks();
  }

  Future<void> _loadStorybooks() async {
    setState(() => _isLoading = true);
    final storybooks = await Storybook.loadStorybooks();
    setState(() {
      _storybooks = storybooks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5AC8FA),
        elevation: 0,
        title: const Text('Storybooks', style: TextStyle(color: Colors.teal)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _storybooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_stories, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No storybooks yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first storybook!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _storybooks.length,
                  itemBuilder: (context, index) {
                    final storybook = _storybooks[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(
                          storybook.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        subtitle: Text(
                          '${storybook.slides.length} slides • Created ${_formatDate(storybook.createdAt)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_arrow, color: Colors.teal),
                              onPressed: () {
                                // Load the storybook and start presentation
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateStorybook(),
                                  ),
                                ).then((_) => _loadStorybooks());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.teal),
                              onPressed: () {
                                // Open the storybook in edit mode
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateStorybook(),
                                  ),
                                ).then((_) => _loadStorybooks());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(storybook),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateStorybook(),
            ),
          ).then((_) => _loadStorybooks());
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Just now';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _confirmDelete(Storybook storybook) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Storybook?'),
        content: Text('Are you sure you want to delete "${storybook.title}"?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Storybook.deleteStorybook(storybook.id);
      await _loadStorybooks();
    }
  }
}
