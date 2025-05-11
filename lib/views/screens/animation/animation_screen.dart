import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/animation_cache_manager.dart';


class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key});

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen> with WidgetsBindingObserver {
  List<String> savedAnimations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadSavedAnimations();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh animations when dependencies change
    loadSavedAnimations();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh animations when app comes to the foreground
    if (state == AppLifecycleState.resumed) {
      loadSavedAnimations();
    }
  }

  Future<void> loadSavedAnimations() async {
    final animations = await AnimationCacheManager.getSavedAnimations();
    setState(() {
      savedAnimations = animations;
    });
  }

  Future<void> deleteAnimation(int index) async {
    final animationPath = savedAnimations[index];
    final file = File(animationPath);
    if (await file.exists()) {
      await file.delete();
    }

    final prefs = await SharedPreferences.getInstance();
    final updated = List<String>.from(savedAnimations)..removeAt(index);
    await prefs.setStringList('saved_animations', updated);
    setState(() {
      savedAnimations = updated;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Force refresh animations when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSavedAnimations();
    });
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5AC8FA), Color(0xFFA8D97F)],
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    const Text(
                      'Animations',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${savedAnimations.length} animations',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: savedAnimations.isEmpty
                  ? const Center(
                child: Text(
                  'No animations yet!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  itemCount: savedAnimations.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final animationPath = savedAnimations[index];
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.teal, width: 2),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(File(animationPath), fit: BoxFit.contain),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Animation'),
                                  content: const Text('Are you sure you want to permanently delete this animation?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                await deleteAnimation(index);
                              }
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.delete, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
