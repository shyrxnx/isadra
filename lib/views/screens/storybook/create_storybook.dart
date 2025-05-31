import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'create_storybook/widgets/navigation_item.dart';
import 'create_storybook/functionality/animation_picker.dart';
import 'create_storybook/functionality/background_picker.dart';
import 'create_storybook/functionality/text_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'create_storybook/widgets/slide_navigation.dart';
import 'create_storybook/functionality/slide_manager.dart';
import 'create_storybook/widgets/animation_overlay.dart';
import 'create_storybook/widgets/slide_thumbnail.dart';
import 'package:provider/provider.dart';
import '../../../models/storybook.dart';

class CreateStorybook extends StatelessWidget {
  final Storybook? existingStorybook;

  const CreateStorybook({super.key, this.existingStorybook});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => existingStorybook != null
        ? SlideManager.fromStorybook(existingStorybook!)
        : SlideManager(),
      child: _CreateStorybookContent(existingStorybook: existingStorybook),
    );
  }
}

class _CreateStorybookContent extends StatefulWidget {
  final Storybook? existingStorybook;

  const _CreateStorybookContent({this.existingStorybook});

  @override
  State<_CreateStorybookContent> createState() => _CreateStorybookContentState();
}

class _CreateStorybookContentState extends State<_CreateStorybookContent> {
  final TextEditingController _titleController = TextEditingController();
  String? _savedStoryId;  // Track if this story was already saved
  int _selectedDuration = 5;
  bool _hasUnsavedChanges = false;
  String _lastSavedTitle = '';  // Track the title at last save
  bool _isInitialBuild = true; // Flag to ignore initial change notifications

  @override
  void initState() {
    super.initState();

    // Initialize with existing storybook data if available
    if (widget.existingStorybook != null) {
      _titleController.text = widget.existingStorybook!.title;
      _lastSavedTitle = widget.existingStorybook!.title;
      _savedStoryId = widget.existingStorybook!.id;
      _hasUnsavedChanges = false;
    }
    
    // Listen for changes to the title, but with check to avoid initial change
    _titleController.addListener(() {
      if (!_isInitialBuild) {
        // Only track changes after the initial build
        if (_titleController.text != _lastSavedTitle) {
          _markAsUnsaved();
        }
      }
    });
    
    // We'll handle SlideManager changes more carefully
  }
  // Add a state variable to track progress within a slide
  double _slideProgress = 0.0;
  Timer? _progressTimer;

  @override
  void dispose() {
    _progressTimer?.cancel();
    _titleController.removeListener(_markAsUnsaved);
    _titleController.dispose();
    super.dispose();
  }
  
  void _markAsUnsaved() {
    if (!_isInitialBuild) { // Skip during initial setup
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _startProgressTimer(SlideManager slideManager) {
    // Reset progress
    setState(() {
      _slideProgress = 0.0;
    });

    // Cancel any existing timer
    _progressTimer?.cancel();

    // Calculate the interval for updating progress (update 20 times per second)
    final updateInterval = (slideManager.currentSlide.duration * 1000) ~/ 100;

    // Start a new timer
    _progressTimer = Timer.periodic(Duration(milliseconds: updateInterval), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _slideProgress += 0.01;
        if (_slideProgress >= 1.0) {
          _slideProgress = 1.0;
          timer.cancel();
        }
      });
    });
  }

  Widget _buildPresentationMode(SlideManager slideManager) {
    // Start the progress timer when we enter presentation mode
    // This is safe because the widget will be rebuilt when the slide changes
    if (_progressTimer == null || !_progressTimer!.isActive) {
      _startProgressTimer(slideManager);
    }
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Warm, vintage book-like gradient
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5EFE0), // Warm parchment
              Color(0xFFECE2C6), // Slightly darker parchment
            ],
            stops: [0.3, 1.0],
          ),
          // Add a subtle vignette effect with box shadow
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 25,
              spreadRadius: 5,
              blurStyle: BlurStyle.inner,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title bar in storybook style
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1), // Warm parchment color
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.brown.shade200, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_stories, color: Colors.brown),
                    const SizedBox(width: 8),
                    Text(
                      _titleController.text.isNotEmpty ? _titleController.text : 'Untitled Story',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown.shade700, fontFamily: 'Serif'),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.brown.shade300),
                      ),
                      child: Text(
                        'Page ${slideManager.currentSlideIndex + 1}/${slideManager.slides.length}',
                        style: TextStyle(
                          color: Colors.brown.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.brown, size: 24),
                      onPressed: () => slideManager.stopPresentation(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.brown.shade50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Main content area - storybook style frame
            Container(
              width: 360,  // Same width as editor mode
              height: 300, // Same height as editor mode
              decoration: BoxDecoration(
                // Keep the original border but enhance it
                border: Border.all(color: Colors.brown.shade300, width: 2),
                // Subtle inner shadow for page effect
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.7),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                    spreadRadius: 1,
                  ),
                ],
                color: Colors.white,
                // Keep the background image
                image: slideManager.currentSlide.backgroundImageFile != null
                    ? DecorationImage(
                        image: FileImage(slideManager.currentSlide.backgroundImageFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  // Animations - clean version without edit controls (unchanged)
                  for (final animData in slideManager.currentSlide.animations)
                    Positioned(
                      left: animData.position.x,
                      top: animData.position.y,
                      child: Transform.scale(
                        scale: animData.position.scale,
                        child: Image.file(
                          animData.file,
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  // Texts - clean version without edit controls
                  for (final textData in slideManager.currentSlide.texts)
                    Positioned(
                      left: textData.position.x,
                      top: textData.position.y,
                      child: Transform.scale(
                        scale: textData.position.scale,
                        child: Text(
                          textData.text,
                          style: TextStyle(
                            fontSize: textData.fontSize,
                            fontWeight: textData.isBold ? FontWeight.bold : FontWeight.normal,
                            color: textData.color,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Progress indicator below the content
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 32.0, right: 32.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Navigation buttons
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.brown.shade700),
                        onPressed: slideManager.currentSlideIndex > 0 ? () {
                          slideManager.goToPreviousSlide();
                          _startProgressTimer(slideManager); // Restart timer for new slide
                        } : null,
                      ),
                      // Progress bar
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _slideProgress, // Use our slide-specific progress
                            backgroundColor: Colors.brown.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.brown.shade400),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      // Next button
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios, size: 20, color: Colors.brown.shade700),
                        onPressed: slideManager.currentSlideIndex < slideManager.slides.length - 1 ? () {
                          slideManager.goToNextSlide();
                          _startProgressTimer(slideManager); // Restart timer for new slide
                        } : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Time remaining indicator
                  Text(
                    'Time remaining: ${(slideManager.currentSlide.duration * (1.0 - _slideProgress)).toStringAsFixed(1)} seconds',
                    style: TextStyle(color: Colors.brown.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
            
            // Duration indicator
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.brown.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.brown.shade200),
                ),
                child: Text(
                  'Duration: ${slideManager.currentSlide.duration} seconds',
                  style: TextStyle(color: Colors.brown.shade700, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop(SlideManager slideManager) async {
    // If there's no content or no slides, allow exit without saving
    if (slideManager.slides.isEmpty) {
      return true;
    }

    bool hasContent = false;
    for (var slide in slideManager.slides) {
      if (slide.backgroundImageFile != null ||
          slide.animations.isNotEmpty ||
          slide.texts.isNotEmpty) {
        hasContent = true;
        break;
      }
    }

    if (!hasContent) {
      return true;
    }

    // If we have content but no unsaved changes, allow exit without showing dialog
    bool titleUnchanged = _titleController.text == _lastSavedTitle;
    bool contentUnchanged = !slideManager.hasChanges;
    
    // If nothing has changed and this is an existing storybook, allow exit without dialog
    if (titleUnchanged && contentUnchanged && _savedStoryId != null) {
      return true;
    }

    // Otherwise show the save dialog
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Storybook?'),
        content: const Text('Do you want to save your storybook before leaving?'),
        actions: [
          TextButton(
            child: const Text('Discard'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              await _saveStorybook(slideManager);
              if (mounted) {
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<int> _getNextUnnamedNumber() async {
    final storybooks = await Storybook.loadStorybooks();
    int maxNumber = 0;

    for (final book in storybooks) {
      if (book.title.startsWith('Unnamed')) {
        final parts = book.title.split(' ');
        if (parts.length > 1) {
          final number = int.tryParse(parts[1]);
          if (number != null && number > maxNumber) {
            maxNumber = number;
          }
        }
      }
    }

    // Always return at least 1, or the next number
    return maxNumber + 1;
  }

  Future<void> _saveStorybook(SlideManager slideManager) async {
    String title = _titleController.text.trim();

    // Always get a new number for unnamed storybooks (even when resaving)
    if (title.isEmpty || title.startsWith('Unnamed')) {
      int nextNumber = await _getNextUnnamedNumber();
      title = 'Unnamed $nextNumber'; // Add a space between Unnamed and the number
      _titleController.text = title; // Update the text field
      
      // For debugging - show what number was generated
      print('Generated storybook name: $title with number: $nextNumber');
    }

    final storybook = Storybook(
      id: _savedStoryId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
      slides: slideManager.slides,
    );

    await Storybook.saveStorybook(storybook);
    _savedStoryId = storybook.id;  // Remember this story's ID
    _lastSavedTitle = title;       // Remember the saved title
    
    // Reset the unsaved changes flags
    setState(() {
      _hasUnsavedChanges = false;
    });
    
    // Reset changes in the SlideManager too
    slideManager.resetChanges();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved "$title"'),
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the slide manager with listener for changes
    final slideManager = Provider.of<SlideManager>(context, listen: true);
    final currentSlide = slideManager.currentSlide;
    
    // After the first build, mark as not initial anymore to start tracking changes
    if (_isInitialBuild) {
      // Use a microtask to run after this build completes
      Future.microtask(() {
        setState(() {
          _isInitialBuild = false;
        });
      });
    } else {
      // After initial build, track SlideManager changes
      // Using didChangeDependencies would be better, but this will work too
      if (slideManager.hasChanges) {
        _markAsUnsaved();
      }
    }

    if (slideManager.isPlaying) {
      return _buildPresentationMode(slideManager);
    }

    return WillPopScope(
      onWillPop: () => _onWillPop(slideManager),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF5AC8FA),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.teal),
            onPressed: () => _onWillPop(slideManager).then((canPop) {
              if (canPop) Navigator.pop(context);
            }),
          ),
          title: TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.teal, fontSize: 18),
            decoration: const InputDecoration(
              hintText: 'Enter story title',
              hintStyle: TextStyle(color: Colors.teal),
              border: InputBorder.none,
            ),
          ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.teal),
            onPressed: () => _saveStorybook(slideManager),
          ),
          IconButton(
            icon: const Icon(Icons.timer, color: Colors.teal),
            onPressed: () => _showDurationPicker(context),
          ),
          Consumer<SlideManager>(
            builder: (context, slideManager, child) {
              return IconButton(
                icon: Icon(
                  slideManager.isPlaying ? Icons.stop : Icons.play_arrow,
                  color: Colors.teal,
                ),
                onPressed: () {
                  if (slideManager.isPlaying) {
                    slideManager.stopPresentation();
                  } else {
                    slideManager.startPresentation();
                  }
                },
              );
            },
          ),

        ],
      ),
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
            Expanded(
              child: Center(
                child: Container(
                  width: 360,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple.shade300),
                    color: currentSlide.backgroundImageFile == null ? Colors.white : null,
                    image: currentSlide.backgroundImageFile != null
                        ? DecorationImage(
                            image: FileImage(currentSlide.backgroundImageFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // Display all animations for the current slide
                      for (int i = 0; i < currentSlide.animations.length; i++)
                        _buildRemovableAnimationWidget(currentSlide.animations[i], i),
                      // Display all texts for the current slide
                      for (int i = 0; i < currentSlide.texts.length; i++)
                        _buildRemovableTextWidget(currentSlide.texts[i], i),
                      if (currentSlide.backgroundImageFile == null && currentSlide.animations.isEmpty && currentSlide.texts.isEmpty)
                        const Center(child: Text("Tap icons below to add content")),
                    ],
                  ),
                ),
              ),
            ),
            // Thumbnail row for slide preview and quick navigation
            SlideThumbnailRow(
              slideManager: slideManager,
              onSlideSelected: (index) {
                slideManager.goToSlide(index);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SlideNavigation(
                currentIndex: slideManager.currentSlideIndex,
                totalSlides: slideManager.slides.length,
                onPrevious: slideManager.goToPreviousSlide,
                onNext: slideManager.goToNextSlide,
                onAdd: () {
                  // Check if the current slide is empty before adding a new one
                  if (slideManager.isCurrentSlideEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please add content to the current slide before adding a new one'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    slideManager.addNewSlide();
                  }
                },
                onDelete: () => confirmDeleteSlide(context),
                canAddMoreSlides: slideManager.canAddMoreSlides,
              ),
            ),
            Container(
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NavigationItem(
                      icon: Icons.movie,
                      label: "Animations",
                      onTap: () => _showAnimationPicker(context, slideManager)),
                  NavigationItem(
                      icon: Icons.image,
                      label: "Background",
                      onTap: () => _pickBackgroundImage(slideManager)),
                  NavigationItem(
                      icon: Icons.text_fields,
                      label: "Text",
                      onTap: () => _addTextOverlay(context, slideManager)),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildRemovableAnimationWidget(AnimationOverlayData animationData, int index) {
    final slideManager = Provider.of<SlideManager>(context, listen: false);
    return Stack(
      children: [
        AnimationOverlay(
          data: animationData,
          onPositionChanged: (x, y, scale) {
            slideManager.updateAnimationPosition(index, x, y, scale);
          },
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => slideManager.removeCurrentAnimation(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemovableTextWidget(TextOverlayData textData, int index) {
    final slideManager = Provider.of<SlideManager>(context, listen: false);
    return Stack(
      children: [
        TextEditor.buildTextWidget(
          textData.text,
          textData.color,
          textData.position.x,
          textData.position.y,
          textData.position.scale,
          textData.id,
          (x, y, scale) => slideManager.updateTextPosition(index, x, y, scale),
          fontStyle: textData.fontStyle,
          fontSize: textData.fontSize,
          isBold: textData.isBold,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => slideManager.removeCurrentText(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickBackgroundImage(SlideManager slideManager) async {
    final pickedFile = await BackgroundPicker.pickBackgroundImage(ImagePicker());
    if (pickedFile != null) {
      slideManager.updateCurrentBackground(File(pickedFile.path));
    }
  }

  void _addTextOverlay(BuildContext context, SlideManager slideManager) {
    TextEditor.showTextDialog(context, (String text, Color color, int fontStyle, double fontSize, bool isBold) {
      slideManager.addCurrentText(TextOverlayData(
        text: text,
        color: color,
        fontStyle: fontStyle,
        fontSize: fontSize,
        isBold: isBold
      ));
    });
  }

  Future<void> _showAnimationPicker(BuildContext context, SlideManager slideManager) async {
    final animations = await AnimationPicker.getSavedAnimations();
    AnimationPicker.showAnimationPicker(context, animations, (File animationFile) {
      slideManager.addCurrentAnimation(animationFile);
    });
  }

  void _showDurationPicker(BuildContext context) {
    // Get the SlideManager instance from the parent context
    final slideManager = Provider.of<SlideManager>(context, listen: false);
    // Store a local reference to avoid accessing Provider inside the dialog
    final SlideManager localSlideManager = slideManager;
    
    // Ensure we have a valid duration value
    _selectedDuration = localSlideManager.currentSlide.duration > 0 ? 
                        localSlideManager.currentSlide.duration : 5;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Set Slide Duration'),
        content: StatefulBuilder(
          builder: (builderContext, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NumberPicker(
                minValue: 1,
                maxValue: 60,
                value: _selectedDuration,
                onChanged: (value) {
                  setState(() {
                    _selectedDuration = value;
                  });
                },
                textStyle: const TextStyle(fontSize: 16),
                selectedTextStyle: const TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold,
                  color: Colors.teal
                ),
              ),
              const Text('seconds', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              try {
                // Use the local reference instead of Provider.of
                localSlideManager.updateSlideDuration(Duration(seconds: _selectedDuration));
                Navigator.pop(dialogContext);
                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Slide duration set to $_selectedDuration seconds'),
                    backgroundColor: Colors.teal,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                // Show error message
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error setting duration: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void confirmDeleteSlide(BuildContext context) {
    final slideManager = Provider.of<SlideManager>(context, listen: false);
    if (slideManager.slides.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must have at least one slide.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Slide"),
        content: const Text("Are you sure you want to delete this slide?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              slideManager.removeSlide(slideManager.currentSlideIndex);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

}