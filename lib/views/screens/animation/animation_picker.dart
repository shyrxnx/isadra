import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/animation_cache_manager.dart';

class AnimationPicker extends StatefulWidget {
  final String textureImageUrl;
  final String imageName;

  const AnimationPicker({
    super.key,
    required this.textureImageUrl,
    required this.imageName,
  });

  @override
  _AnimationPickerState createState() => _AnimationPickerState();
}

class _AnimationPickerState extends State<AnimationPicker> {
  String selectedCategory = 'ALL';
  String selectedAnimation = '';
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final ApiService _apiService = ApiService();
  Uint8List? _currentGifBytes;
  bool _isLoadingGif = false;

  final Map<String, String> _animations = {
    'Angry': 'QUIRKY', 'Blowkiss': 'NORMAL', 'Brush': 'NORMAL', 'Celebrate': 'QUIRKY',
    'Chicken Dance': 'QUIRKY', 'Dab': 'QUIRKY', 'Dance L': 'QUIRKY', 'Falldown': 'QUIRKY',
    'Fancy Dance': 'QUIRKY', 'Fist Pump': 'QUIRKY', 'Flex Muscle': 'QUIRKY', 'Impatient': 'QUIRKY',
    'Breathe': 'NORMAL', 'Jumping Jacks': 'NORMAL', 'Jump': 'NORMAL', 'Kick L': 'QUIRKY',
    'Laugh': 'QUIRKY', 'Point Me': 'NORMAL', 'Point You': 'NORMAL', 'Punch': 'QUIRKY',
    'Run': 'NORMAL', 'Salute': 'NORMAL', 'Sit': 'NORMAL', 'Stretch': 'NORMAL',
    'Walk': 'NORMAL', 'Wave': 'NORMAL', 'Yoga': 'NORMAL', 'Zombie': 'QUIRKY',
  };

  List<String> get _allAnimations => _animations.keys.toList()..sort();
  List<String> get _normalAnimations => _animations.keys.where((key) => _animations[key] == 'NORMAL').toList()..sort();
  List<String> get _quirkyAnimations => _animations.keys.where((key) => _animations[key] == 'QUIRKY').toList()..sort();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _generateAndDisplayGif(BuildContext context, String motionName) async {
    if (motionName.isNotEmpty && widget.imageName.isNotEmpty) {
      String? base64Gif = await _apiService.generateGif(widget.imageName, motionName);
      if (base64Gif != null) {
        return base64Decode(base64Gif);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to generate GIF.')));
        return null;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an animation.')));
      return null;
    }
  }

  Future<void> _previewAnimation(String animationName) async {
    setState(() {
      selectedAnimation = animationName;
      _isLoadingGif = true;
      _currentGifBytes = null;
    });

    final cachedPath = await AnimationCacheManager.checkIfCached('${widget.imageName}_$animationName');
    if (cachedPath != null) {
      final file = File(cachedPath);
      final bytes = await file.readAsBytes();
      setState(() {
        _currentGifBytes = bytes;
        _isLoadingGif = false;
      });
    } else {
      final gifBytes = await _generateAndDisplayGif(context, animationName);
      if (gifBytes != null) {
        await AnimationCacheManager.saveTempAnimation('${widget.imageName}_$animationName', gifBytes);
        setState(() {
          _currentGifBytes = gifBytes;
          _isLoadingGif = false;
        });
      } else {
        setState(() {
          _isLoadingGif = false;
        });
      }
    }
  }

  Future<void> _handleSaveAnimation(BuildContext context) async {
    if (_currentGifBytes != null) {
      try {
        await AnimationCacheManager.saveTempAnimation('${widget.imageName}_$selectedAnimation', _currentGifBytes!);
        await AnimationCacheManager.saveToPermanentStorage('${widget.imageName}_$selectedAnimation');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GIF saved to gallery ')));
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving GIF: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No GIF to save.')));
    }
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
            colors: [Color(0xFF5AC8FA), Color(0xFFA8D97F)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.teal),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => _handleSaveAnimation(context),
                  child: const Text('Save', style: TextStyle(color: Colors.teal, fontSize: 16)),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text('Add Animation', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Text('Swipe through the motions below to see your character perform them!', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black87)),
            ),
            Container(
              margin: const EdgeInsets.all(16.0),
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple, width: 5),
              ),
              child: _isLoadingGif
                  ? const Center(child: CircularProgressIndicator())
                  : _currentGifBytes != null
                  ? Image.memory(
                _currentGifBytes!,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    widget.textureImageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(child: Text('Failed to load image')),
                  );
                },
              )
                  : Image.network(
                widget.textureImageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(child: Text('Failed to load image')),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _categoryButton('ALL', Colors.teal),
                _categoryButton('NORMAL', Colors.brown),
                _categoryButton('QUIRKY', Colors.orange),
              ],
            ),
            const SizedBox(height: 1),
            SizedBox(
              height: 155,
              child: PageView(
                controller: _pageController,
                children: _buildAnimationPages(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: _buildPageIndicator(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryButton(String label, Color activeColor) {
    return SizedBox(
      width: 100,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: selectedCategory == label ? activeColor : null,
          side: BorderSide(color: activeColor, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onPressed: () {
          setState(() {
            selectedCategory = label;
            _pageController.jumpToPage(0);
            _currentPage = 0;
          });
        },
        child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
      ),
    );
  }

  List<Widget> _buildAnimationPages() {
    List<String> animations = _getAnimationsByCategory();
    List<Widget> pages = [];
    for (int i = 0; i < animations.length; i += 6) {
      List<String> chunk = animations.sublist(i, (i + 6 > animations.length) ? animations.length : i + 6);
      pages.add(
        Center(
          child: Wrap(
            spacing: 10,
            runSpacing: 12,
            children: chunk.map((animation) => _animationButton(animation)).toList(),
          ),
        ),
      );
    }
    return pages;
  }

  Widget _animationButton(String label) {
    return SizedBox(
      width: 110,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: selectedAnimation == label ? Colors.teal : null,
          side: const BorderSide(color: Colors.teal, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () {
          _previewAnimation(label);
        },
        child: Text(
          _formatAnimationName(label),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  List<String> _getAnimationsByCategory() {
    if (selectedCategory == 'ALL') return _allAnimations;
    if (selectedCategory == 'NORMAL') return _normalAnimations;
    if (selectedCategory == 'QUIRKY') return _quirkyAnimations;
    return [];
  }

  String _formatAnimationName(String name) {
    String formattedName = name.replaceAll(RegExp(r' \([^)]*\)| \[[^\]]*\]'), '');
    return formattedName.split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ');
  }

  Widget _buildPageIndicator() {
    final int pageCount = _buildAnimationPages().length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.teal : Colors.grey[200],
          ),
        );
      }),
    );
  }
}

class DisplayGifScreen extends StatelessWidget {
  final String base64Gif;

  const DisplayGifScreen({super.key, required this.base64Gif});

  @override
  Widget build(BuildContext context) {
    final Uint8List bytes = base64Decode(base64Gif);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Animation'),
      ),
      body: Center(
        child: Image.memory(bytes),
      ),
    );
  }
}