import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../core/state/processed_image.dart';
import 'annotation_picker.dart';

class MaskConfirmationScreen extends StatefulWidget {
  final String imageName;

  const MaskConfirmationScreen({super.key, required this.imageName});

  @override
  _MaskConfirmationScreenState createState() => _MaskConfirmationScreenState();
}

class _MaskConfirmationScreenState extends State<MaskConfirmationScreen> {
  ui.Image? _maskImage;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMaskImage();
  }

  Future<void> _loadMaskImage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final processedImageProvider = Provider.of<ProcessedImageProvider>(context, listen: false);
    final maskUrl = processedImageProvider.maskImageUrl;

    if (maskUrl != null && maskUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(maskUrl));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          ui.decodeImageFromList(bytes, (ui.Image img) {
            if (mounted) {
              setState(() {
                _maskImage = img;
                _isLoading = false;
              });
            }
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to load mask: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading mask: $e';
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No mask image available';
      });
    }
  }

  void _proceedToAnnotationPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PoseAnnotationChoiceScreen(
          imageName: widget.imageName,
        ),
      ),
    );
  }

  void _retryMaskGeneration() {
    // Navigate back to the home screen
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final processedImageProvider = Provider.of<ProcessedImageProvider>(context);
    final originalImageUrl = processedImageProvider.originalImageUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Mask'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5AC8FA), Color(0xFFA8D97F)],
          ),
        ),
        child: _isLoading 
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Loading mask...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      // Explanation card
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          color: Colors.white.withOpacity(0.9),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Review the Mask',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'We\'ve generated a mask for your image. Please check if it correctly identifies the figure you want to animate.',
                                  style: TextStyle(fontSize: 15),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'If the mask looks good, proceed to the next step. If not, you can try again.',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Image and mask display area
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Center(
                                child: Container(
                                  width: constraints.maxWidth,
                                  height: constraints.maxWidth,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Stack(
                                      children: [
                                        // Texture image
                                        if (processedImageProvider.textureImageUrl != null && processedImageProvider.textureImageUrl!.isNotEmpty)
                                          Image.network(
                                            processedImageProvider.textureImageUrl!,
                                            fit: BoxFit.contain,
                                            width: constraints.maxWidth,
                                            height: constraints.maxWidth,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded / 
                                                          loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                          )
                                        else if (originalImageUrl != null && originalImageUrl.isNotEmpty)
                                          Image.network(
                                            originalImageUrl,
                                            fit: BoxFit.contain,
                                            width: constraints.maxWidth,
                                            height: constraints.maxWidth,
                                          )
                                        else
                                          const Center(child: Text('No image available', style: TextStyle(color: Colors.white))),
                                        
                                        // Mask overlay
                                        if (_maskImage != null)
                                          Opacity(
                                            opacity: 0.5, // Semi-transparent overlay
                                            child: SizedBox(
                                              width: constraints.maxWidth,
                                              height: constraints.maxWidth,
                                              child: CustomPaint(
                                                painter: _MaskPainter(maskImage: _maskImage!),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              onPressed: _retryMaskGeneration,
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              label: const Text('Go Back', style: TextStyle(color: Colors.white)),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              onPressed: _proceedToAnnotationPicker,
                              icon: const Icon(Icons.check_circle, color: Colors.white),
                              label: const Text('Looks Good', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

class _MaskPainter extends CustomPainter {
  final ui.Image maskImage;
  
  _MaskPainter({required this.maskImage});

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(
      canvas: canvas, 
      rect: Rect.fromLTWH(0, 0, size.width, size.height), 
      image: maskImage, 
      fit: BoxFit.contain
    );
  }

  @override
  bool shouldRepaint(_MaskPainter oldDelegate) {
    return oldDelegate.maskImage != maskImage;
  }
}
