import 'package:flutter/material.dart';
import 'create_storybook.dart';
import '../../../models/storybook.dart';
import '../../../core/widgets/sound_button.dart';
import '../../../core/mixins/sound_mixin.dart';

class StorybookScreen extends StatefulWidget {
  const StorybookScreen({super.key});

  @override
  State<StorybookScreen> createState() => _StorybookScreenState();
}

class _StorybookScreenState extends State<StorybookScreen> with SoundMixin {
  List<Storybook> storybooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStorybooks();
  }

  Future<void> _loadStorybooks() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final loadedStorybooks = await Storybook.loadStorybooks();
      setState(() {
        storybooks = loadedStorybooks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error if needed
    }
  }

  void _navigateToCreateStorybook() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateStorybook()),
    );
    
    // Reload storybooks when returning from create screen
    _loadStorybooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5AC8FA), Color(0xFFA8D97F)], // Gradient colors
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0), // Balanced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Center align elements
                  children: [
                    const Text(
                      'Storybooks',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal, // Text color matching the design
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8), // Spacing between title and counter
                    Text(
                      '${storybooks.length} storybooks', // Dynamically displays the storybook count
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : storybooks.isEmpty
                  ? const Center(
                      child: Text(
                        'No storybooks yet!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: storybooks.length,
                        itemBuilder: (context, index) {
                          final storybook = storybooks[index];
                          return _buildStorybookCard(storybook);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0), // Move the button 80 pixels up
        child: FloatingActionButton(
          onPressed: () {
            playButtonSound(context);
            _navigateToCreateStorybook();
          },
          backgroundColor: Colors.teal, // Teal color for the button
          child: const Icon(
            Icons.add,
            color: Colors.white, // White "+" icon
          ),
        ),
      ),
    );
  }

  Widget _buildStorybookCard(Storybook storybook) {
    return SoundGestureDetector(
      onTap: () {
        // Navigate to the CreateStorybook screen with the existing storybook
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateStorybook(existingStorybook: storybook),
          ),
        ).then((_) {
          // Reload storybooks when returning from edit screen
          _loadStorybooks();
        });
      },
      onLongPress: () {
        // Show delete confirmation dialog
        _showDeleteConfirmation(storybook);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Storybook preview area (placeholder for now)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.book,
                    size: 48,
                    color: Colors.teal,
                  ),
                ),
              ),
            ),
            // Storybook info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storybook.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Created: ${_formatDate(storybook.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${storybook.slides.length} slides',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(Storybook storybook) {
    playButtonSound(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Storybook'),
          content: Text('Are you sure you want to delete "${storybook.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Delete the storybook
                await _deleteStorybook(storybook.id);
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStorybook(String id) async {
    try {
      // Call the static delete method from the Storybook model
      await Storybook.deleteStorybook(id);
      
      // Refresh the storybook list
      _loadStorybooks();
      
      // Show a snackbar to confirm deletion
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storybook deleted successfully')),
        );
      }
    } catch (e) {
      // Show error message if deletion fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete storybook: $e')),
        );
      }
    }
  }
}