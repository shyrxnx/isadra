import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import '../../../core/state/processed_image.dart';
import '../../../core/services/api_service.dart';
import '../animation/animation_picker.dart';
import '../../../core/services/supabase_storage.dart';

class ManualPoseAnnotationScreen extends StatefulWidget {
  final String imageName;
  const ManualPoseAnnotationScreen({super.key, required this.imageName});

  @override
  _ManualPoseAnnotationScreenState createState() => _ManualPoseAnnotationScreenState();
}

class _ManualPoseAnnotationScreenState extends State<ManualPoseAnnotationScreen> {
  List<Offset> _keypoints = [];
  List<List<Offset>> _history = [];
  List<List<Offset>> _redoStack = [];
  final int _maxPoints = 16;
  final int _visiblePoints = 15;
  int _currentPointIndex = 0;
  ui.Image? _maskImage;
  final GlobalKey _imageStackKey = GlobalKey();
  String? _currentImageName;
  final SupabaseStorageService _storageService = SupabaseStorageService();

  final List<String> _keypointNames = const [
    "Root", "Hip", "Torso", "Neck",
    "Left Shoulder", "Left Elbow", "Left Hand",
    "Right Shoulder", "Right Elbow", "Right Hand",
    "Left Hip", "Left Knee", "Left Foot",
    "Right Hip", "Right Knee", "Right Foot"
  ];

  bool _showInstructions = true; // Flag to show/hide instructions

  String? _textureImageUrl;
  String? _originalImageUrl;

  Future<void> _loadTextureImage() async {
    try {
      final url = await _storageService.getCharacterTextureUrl(widget.imageName);
      if (url != null && mounted) {
        setState(() {
          _textureImageUrl = url;
        });
      }
    } catch (e) {
      print('Error loading texture image: $e');
    }
  }
  
  Future<void> _loadOriginalImage() async {
    try {
      final url = await _storageService.getCharacterOriginalImageUrl(widget.imageName);
      if (url != null && mounted) {
        setState(() {
          _originalImageUrl = url;
        });
      }
    } catch (e) {
      print('Error loading original image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMaskImage();
    _loadTextureImage();
    _loadOriginalImage();
    _currentImageName = widget.imageName;
  }

  Future<void> _loadMaskImage() async {
    try {
      // Get the mask URL from Supabase
      final maskUrl = await _storageService.getCharacterMaskUrl(widget.imageName);
      
      print('Loading mask from URL: $maskUrl'); // Debug log
      
      if (maskUrl != null && maskUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(maskUrl));
        print('Response status: ${response.statusCode}'); // Debug log
        
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          ui.decodeImageFromList(bytes, (ui.Image img) {
            if (mounted) {
              setState(() {
                _maskImage = img;
              });
            }
          });
        } else {
          print('Oops! We couldn\'t load the mask image. Please try again later. Status: ${response.statusCode}');
        }
      } else {
        print('No mask URL available');
      }
    } catch (e) {
      print('Oops! Something went wrong while loading the mask image: $e');
    }
  }

  Future<bool> _onWillPop() async {
    if (_keypoints.isNotEmpty) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('If you go back now, any unsaved progress will be lost.'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No, Stay!')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes, Go Back!')),
          ],
        ),
      ) ?? false;
      return shouldPop;
    }
    return true;
  }

  void _handleTap(TapUpDetails details) async {
    final RenderBox? stackBox = _imageStackKey.currentContext?.findRenderObject() as RenderBox?;
    final localPosition = details.localPosition;
    final Size? widgetSize = stackBox?.size;
    double? adjustedX, adjustedY;

    if (_maskImage != null && widgetSize != null) {
      final img = _maskImage!;
      final double imageAspect = img.width / img.height;
      final double widgetAspect = widgetSize.width / widgetSize.height;
      double scale, dx = 0, dy = 0;
      Size displaySize;

      if (imageAspect > widgetAspect) {
        scale = widgetSize.width / img.width;
        displaySize = Size(widgetSize.width, img.height * scale);
        dy = (widgetSize.height - displaySize.height) / 2;
      } else {
        scale = widgetSize.height / img.height;
        displaySize = Size(img.width * scale, widgetSize.height);
        dx = (widgetSize.width - displaySize.width) / 2;
      }

      adjustedX = ((localPosition.dx - dx) / scale).clamp(0, img.width - 1);
      adjustedY = ((localPosition.dy - dy) / scale).clamp(0, img.height - 1);

      try {
        final pixelData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (pixelData != null) {
          final index = (adjustedY.toInt() * img.width + adjustedX.toInt()) * 4;
          if (index >= 0 && index + 2 < pixelData.lengthInBytes) {
            final r = pixelData.getUint8(index);
            final g = pixelData.getUint8(index + 1);
            final b = pixelData.getUint8(index + 2);
            final isWhite = (r > 250 && g > 250 && b > 250);
            if (!isWhite) {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Oops! Place your point on the white area!')));
              return;
            }
          } else {
            print('Error: Pixel index out of bounds.');
            return;
          }
        }
      } catch (e) {
        print('Error accessing pixel data: $e');
        return;
      }
    }

    setState(() {
      _history.add(List.from(_keypoints));
      _redoStack.clear();
      if (adjustedX != null && adjustedY != null) {
        final x = adjustedX!;
        final y = adjustedY!;
        final newPoint = Offset(x, y);

        if (_keypoints.isEmpty) {
          _keypoints.add(newPoint); // Root
        }

        _keypoints.add(newPoint); // Hip or next point

        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _keypoints.length < _maxPoints
                    ? 'Great job! You placed a point at (${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})! (${_keypoints.isEmpty ? 0 : _keypoints.length - 1} / $_visiblePoints)'
                    : 'Awesome! All keypoints are selected!',
              ),
            ),
          );
        });

        _currentPointIndex = _keypoints.length > 0 ? _keypoints.length - 1 : 0;

        if (_keypoints.length == 2) {
          _showInstructions = false;
        }
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oops! Error placing point.')),
        );
      }
    });
  }

  void _undoPoint() {
    if (_history.isNotEmpty) {
      setState(() {
        _redoStack.add(List.from(_keypoints));
        _keypoints = _history.removeLast();
        _currentPointIndex = _keypoints.length > 0 ? _keypoints.length - 1 : 0;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You undid the last point!')));
      });
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing to undo!')));
    }
  }

  void _redoPoint() {
    if (_redoStack.isNotEmpty) {
      setState(() {
        _history.add(List.from(_keypoints));
        _keypoints = _redoStack.removeLast();
        _currentPointIndex = _keypoints.length > 0 ? _keypoints.length - 1 : 0;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You redid the last point!')));
      });
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing to redo!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Supabase URLs instead of ProcessedImageProvider
    final textureImageUrl = _textureImageUrl;
    final originalImageUrl = _originalImageUrl;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manual Pose Annotation'),
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            IconButton(icon: const Icon(Icons.undo), onPressed: _undoPoint),
            IconButton(icon: const Icon(Icons.redo), onPressed: _redoPoint),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF5AC8FA), Color(0xFFA8D97F)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final Size? painterSize = constraints.maxWidth > 0 && constraints.maxHeight > 0
                              ? Size(constraints.maxWidth, constraints.maxHeight)
                              : null;

                          return GestureDetector(
                            onTapUp: _handleTap,
                            child: Stack(
                              key: _imageStackKey,
                              alignment: Alignment.center,
                              children: [
                                if (textureImageUrl != null && textureImageUrl.isNotEmpty)
                                  Image.network(textureImageUrl, fit: BoxFit.contain, width: constraints.maxWidth, height: constraints.maxHeight)
                                else if (originalImageUrl != null && originalImageUrl.isNotEmpty)
                                  Image.network(originalImageUrl, fit: BoxFit.contain, width: constraints.maxWidth, height: constraints.maxHeight)
                                else
                                  const Center(child: Text('No base image to display')),
                                if (_maskImage != null)
                                  Opacity(
                                    opacity: 0.5,
                                    child: SizedBox(
                                      width: constraints.maxWidth,
                                      height: constraints.maxHeight,
                                      child: CustomPaint(painter: _MaskPainter(maskImage: _maskImage!)),
                                    ),
                                  ),
                                if (painterSize != null && _maskImage != null)
                                  CustomPaint(
                                    painter: _KeypointPainter(keypoints: _keypoints, image: _maskImage, widgetSize: painterSize),
                                    size: painterSize,
                                  ),
                                // Show instructions overlay if applicable
                                if (_showInstructions)
                                  Positioned(
                                    top: 20,
                                    left: 20,
                                    right: 20,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      color: Colors.white.withOpacity(0.8),
                                      child: Text(
                                        'Tap on the white area to place the point for center hip!',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        double progress = _keypoints.length / _maxPoints;
                        return Stack(
                          children: [
                            // Background bar (gray)
                            Container(
                              width: double.infinity,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            // Foreground bar (rainbow progress)
                            Container(
                              width: constraints.maxWidth * progress,
                              height: 10,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.red,
                                    Colors.orange,
                                    Colors.yellow,
                                    Colors.green,
                                    Colors.blue,
                                    Colors.indigo,
                                    Colors.purple,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_keypoints.isEmpty ? 0 : _keypoints.length - 1} / $_visiblePoints points placed',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    if (_keypoints.length < _maxPoints)
                      Text(
                        'Tap to place: ${_currentPointIndex + 1 == 1 ? "Center Hip" : _keypointNames[_currentPointIndex + 1]} (${_keypoints.isEmpty ? 0 : _keypoints.length - 1}/$_visiblePoints)',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    if (_keypoints.length == _maxPoints)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            if (_currentImageName != null) {
                              final List<Map<String, double>> keypointData = _keypoints.map((offset) => {'dx': offset.dx, 'dy': offset.dy}).toList();
                              final response = await http.post(
                                Uri.parse('${ApiService.imageProcessingBaseUrl}/save_keypoints'),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({'keypoints': keypointData, 'image_name': _currentImageName}),
                              );

                              if (response.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yay! Pose saved successfully!')));
                                print('Keypoints saved successfully!');
                                if (textureImageUrl != null && textureImageUrl.isNotEmpty) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AnimationPicker(textureImageUrl: textureImageUrl, imageName: widget.imageName)));
                                } else if (originalImageUrl != null && originalImageUrl.isNotEmpty) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AnimationPicker(textureImageUrl: originalImageUrl, imageName: widget.imageName)));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Oops! No texture or original image URL available to proceed.')));
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Oops! Failed to save pose: ${response.body}')));
                                print('Failed to save keypoints: ${response.body}');
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Oops! Image information not available. Please try again.')));
                              print('Error: _currentImageName is null');
                            }
                          },
                          child: const Text('Save Pose', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
    paintImage(canvas: canvas, rect: Rect.fromLTWH(0, 0, size.width, size.height), image: maskImage, fit: BoxFit.contain);
  }

  @override
  bool shouldRepaint(_MaskPainter oldDelegate) {
    return oldDelegate.maskImage != maskImage;
  }
}

class _KeypointPainter extends CustomPainter {
  final List<Offset> keypoints;
  final ui.Image? image;
  final Size widgetSize;

  // Define the connections between keypoints
  final List<List<int>> connections = [
    [0, 1], // Root to Hip
    [1, 2], // Hip to Torso
    [2, 3], // Torso to Neck
    [3, 4], // Neck to Left Shoulder
    [4, 5], // Left Shoulder to Left Elbow
    [5, 6], // Left Elbow to Left Hand
    [3, 7], // Neck to Right Shoulder
    [7, 8], // Right Shoulder to Right Elbow
    [8, 9], // Right Elbow to Right Hand
    [1, 10], // Hip to Left Hip
    [10, 11], // Left Hip to Left Knee
    [11, 12], // Left Knee to Left Foot
    [1, 13], // Hip to Right Hip
    [13, 14], // Right Hip to Right Knee
    [14, 15], // Right Knee to Right Foot
  ];

  _KeypointPainter({required this.keypoints, this.image, required this.widgetSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null || widgetSize.isEmpty) return;

    final double imageAspectRatio = image!.width / image!.height;
    final double widgetAspectRatio = widgetSize.width / widgetSize.height;
    double scale;
    double offsetX = 0;
    double offsetY = 0;

    if (imageAspectRatio > widgetAspectRatio) {
      scale = widgetSize.width / image!.width;
      offsetY = (widgetSize.height - image!.height * scale) / 2;
    } else {
      scale = widgetSize.height / image!.height;
      offsetX = (widgetSize.width - image!.width * scale) / 2;
    }

    final Paint paint = Paint()
      ..color = Colors.lightBlue
      ..style = PaintingStyle.fill;

    // Draw lines between connected keypoints
    for (final connection in connections) {
      if (connection[0] < keypoints.length && connection[1] < keypoints.length) {
        final startPoint = keypoints[connection[0]];
        final endPoint = keypoints[connection[1]];
        final startX = startPoint.dx * scale + offsetX;
        final startY = startPoint.dy * scale + offsetY;
        final endX = endPoint.dx * scale + offsetX;
        final endY = endPoint.dy * scale + offsetY;

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), Paint()..color = Colors.white..strokeWidth = 4.0);
      }
    }

    // Draw keypoints
    for (final Offset point in keypoints) {
      final double scaledX = point.dx * scale;
      final double scaledY = point.dy * scale;
      final double drawX = scaledX + offsetX;
      final double drawY = scaledY + offsetY;

      canvas.drawCircle(Offset(drawX, drawY), 6.0, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3.0);
      canvas.drawCircle(Offset(drawX, drawY), 6.0, paint);
    }
  }

  @override
  bool shouldRepaint(_KeypointPainter oldDelegate) {
    return oldDelegate.keypoints != keypoints || oldDelegate.image != image || oldDelegate.widgetSize != widgetSize;
  }
}