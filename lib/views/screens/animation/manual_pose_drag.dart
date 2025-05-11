import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import '../../../core/state/processed_image.dart';
import '../../../core/services/api_service.dart';
import '../animation/animation_picker.dart';

class ManualPoseDragScreen extends StatefulWidget {
  final String imageName;
  const ManualPoseDragScreen({super.key, required this.imageName});

  @override
  _ManualPoseDragScreenState createState() => _ManualPoseDragScreenState();
}

class _ManualPoseDragScreenState extends State<ManualPoseDragScreen> {
  List<Offset> _keypoints = [];
  List<List<Offset>> _history = []; // For undo functionality
  ui.Image? _maskImage;
  final GlobalKey _imageStackKey = GlobalKey();
  String? _currentImageName;
  bool _isLoading = true;
  
  // Index of the keypoint being dragged
  int? _draggingKeypointIndex; 
  
  // To track if any changes were made to the initial pose
  bool _poseModified = false;

  final List<String> _keypointNames = const [
    "Root", "Hip", "Torso", "Neck",
    "Left Shoulder", "Left Elbow", "Left Hand",
    "Right Shoulder", "Right Elbow", "Right Hand",
    "Left Hip", "Left Knee", "Left Foot",
    "Right Hip", "Right Knee", "Right Foot"
  ];
  
  // Track if this is a drawing from the drawing screen
  bool _isDrawingSource = false;

  @override
  void initState() {
    super.initState();
    _loadMaskImage();
    _currentImageName = widget.imageName;
    _initializeKeypoints(); // Initialize keypoints with default positions
  }

  // Initialize keypoints with default positions
  void _initializeKeypoints() {
    // Check if this is a drawing (based on the image name or metadata)
    _isDrawingSource = _checkIfDrawingSource();
    
    if (_isDrawingSource) {
      // Use the drawing-specific keypoints with the correct width/height ratio
      _keypoints = [
        Offset(141, 192), // Root
        Offset(141, 192), // Hip (same as Root)
        Offset(142, 136), // Torso
        Offset(149, 104), // Neck
        Offset(100, 131), // Left Shoulder (switched with right)
        Offset(64, 163),  // Left Elbow (switched with right)
        Offset(19, 191),  // Left Hand (switched with right)
        Offset(195, 130), // Right Shoulder (switched with left)
        Offset(237, 167), // Right Elbow (switched with left)
        Offset(263, 204), // Right Hand (switched with left)
        Offset(105, 199), // Left Hip (switched with right)
        Offset(94, 248),  // Left Knee (switched with right)
        Offset(67, 289),  // Left Foot (switched with right)
        Offset(180, 198), // Right Hip (switched with left)
        Offset(187, 252), // Right Knee (switched with left)
        Offset(202, 301), // Right Foot (switched with left)
      ];
    } else {
      // Use the default keypoints for uploaded/camera images
      _keypoints = [
        Offset(164, 274), // Root
        Offset(164, 274), // Hip (same as Root)
        Offset(163, 195), // Torso
        Offset(159, 149), // Neck
        Offset(109, 181), // Left Shoulder
        Offset(79, 232),  // Left Elbow
        Offset(19, 247),  // Left Hand
        Offset(200, 169), // Right Shoulder
        Offset(236, 216), // Right Elbow
        Offset(262, 249), // Right Hand
        Offset(133, 285), // Left Hip
        Offset(152, 340), // Left Knee
        Offset(156, 401), // Left Foot
        Offset(196, 278), // Right Hip
        Offset(199, 341), // Right Knee
        Offset(205, 399), // Right Foot
      ];
    }
    
    // Save initial state to history for undo
    _history.add(List.from(_keypoints));
  }

  // Check if the current image is from the drawing feature
  bool _checkIfDrawingSource() {
    // Check various indicators that this might be from the drawing screen
    if (_currentImageName != null) {
      // Check if the image name contains 'drawing' which is used in the DrawScreen
      if (_currentImageName!.toLowerCase().contains('drawing')) {
        return true;
      }
    }
    
    // If we have image dimensions, check if they match the drawing dimensions
    if (_maskImage != null) {
      // The drawing is resized to 384x512 in the DrawScreen
      if (_maskImage!.width == 384 && _maskImage!.height == 512) {
        return true;
      }
      
      // For drawings, we might also check the width/height ratio
      // Based on the provided skeleton data (width: 292, height: 331)
      final double ratio = _maskImage!.width / _maskImage!.height;
      if (ratio >= 0.85 && ratio <= 0.9) { // Approximately 292/331 = ~0.88
        return true;
      }
    }
    
    return false;
  }

  Future<void> _loadMaskImage() async {
    setState(() {
      _isLoading = true;
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
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Oops! We couldn\'t load the mask image. Please try again later.'))
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oops! Something went wrong: $e'))
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Detect which keypoint is being dragged
  void _onPanStart(DragStartDetails details) {
    final RenderBox? stackBox = _imageStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || _maskImage == null) return;
    
    final localPosition = stackBox.globalToLocal(details.globalPosition);
    final size = stackBox.size;
    
    // Calculate scale and offsets for proper coordinate transformation
    final scaleInfo = _calculateImageScaleAndOffset(size);
    final double scale = scaleInfo['scale']!;
    final double offsetX = scaleInfo['offsetX']!;
    final double offsetY = scaleInfo['offsetY']!;

    // Find the closest keypoint to the touch point
    int? closestIndex;
    double minDistance = 20.0; // Minimum distance to consider a touch on a keypoint

    for (int i = 0; i < _keypoints.length; i++) {
      final adjustedKeypoint = Offset(
        _keypoints[i].dx * scale + offsetX,
        _keypoints[i].dy * scale + offsetY,
      );

      final distance = (localPosition - adjustedKeypoint).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    if (closestIndex != null) {
      setState(() {
        _draggingKeypointIndex = closestIndex;
        // Save current state before modifying
        if (!_poseModified) {
          _poseModified = true;
        }
      });
    }
  }

  // Update position of keypoint being dragged
  void _onPanUpdate(DragUpdateDetails details) {
    if (_draggingKeypointIndex == null || _maskImage == null) return;
    
    final RenderBox? stackBox = _imageStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return;
    
    final localPosition = stackBox.globalToLocal(details.globalPosition);
    final size = stackBox.size;
    
    // Calculate scale and offsets
    final scaleInfo = _calculateImageScaleAndOffset(size);
    final double scale = scaleInfo['scale']!;
    final double offsetX = scaleInfo['offsetX']!;
    final double offsetY = scaleInfo['offsetY']!;

    // Transform screen coordinates to image coordinates
    final imageX = (localPosition.dx - offsetX) / scale;
    final imageY = (localPosition.dy - offsetY) / scale;
    
    // Constrain to image boundaries
    final constrainedX = imageX.clamp(0.0, _maskImage!.width.toDouble());
    final constrainedY = imageY.clamp(0.0, _maskImage!.height.toDouble());

    setState(() {
      _keypoints[_draggingKeypointIndex!] = Offset(constrainedX, constrainedY);
      
      // Special handling for Root and Hip points (keep them synchronized)
      if (_draggingKeypointIndex == 0) { // Root
        _keypoints[1] = _keypoints[0]; // Update Hip to match Root
      } else if (_draggingKeypointIndex == 1) { // Hip
        _keypoints[0] = _keypoints[1]; // Update Root to match Hip
      }
    });
  }

  // End dragging
  void _onPanEnd(DragEndDetails details) {
    if (_draggingKeypointIndex != null) {
      // Add current state to history for undo
      _history.add(List.from(_keypoints));
      
      setState(() {
        _draggingKeypointIndex = null;
      });
    }
  }

  // Helper to calculate image scaling and positioning
  Map<String, double> _calculateImageScaleAndOffset(Size containerSize) {
    if (_maskImage == null) {
      return {'scale': 1.0, 'offsetX': 0.0, 'offsetY': 0.0};
    }
    
    final imageWidth = _maskImage!.width.toDouble();
    final imageHeight = _maskImage!.height.toDouble();
    final imageAspect = imageWidth / imageHeight;
    final containerAspect = containerSize.width / containerSize.height;
    
    double scale, offsetX = 0, offsetY = 0;
    
    if (imageAspect > containerAspect) {
      // Image is wider than container
      scale = containerSize.width / imageWidth;
      offsetY = (containerSize.height - imageHeight * scale) / 2;
    } else {
      // Image is taller than container
      scale = containerSize.height / imageHeight;
      offsetX = (containerSize.width - imageWidth * scale) / 2;
    }
    
    return {
      'scale': scale,
      'offsetX': offsetX,
      'offsetY': offsetY
    };
  }

  // Reset pose to initial positions
  void _resetPose() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Pose'),
        content: const Text('Are you sure you want to reset all keypoints to their initial positions?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _initializeKeypoints();
                _poseModified = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pose has been reset'))
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  // Undo last change
  void _undoChange() {
    if (_history.length > 1) { // Keep at least the initial state
      setState(() {
        _keypoints = List.from(_history[_history.length - 2]);
        _history.removeLast();
        
        // If we're back to the initial state, reset modified flag
        if (_history.length == 1) {
          _poseModified = false;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Undid last change'))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to undo'))
      );
    }
  }

  // Confirmation dialog when attempting to leave
  Future<bool> _onWillPop() async {
    if (_poseModified) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('You have unsaved changes. Are you sure you want to go back?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No, Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, Go Back'),
            ),
          ],
        ),
      ) ?? false;
      return shouldPop;
    }
    return true;
  }

  // Save the pose
  Future<void> _savePose() async {
    if (_currentImageName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Image information not available'))
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, double>> keypointData = 
          _keypoints.map((offset) => {'dx': offset.dx, 'dy': offset.dy}).toList();
      
      final response = await http.post(
        Uri.parse('${ApiService.imageProcessingBaseUrl}/save_keypoints'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'keypoints': keypointData,
          'image_name': _currentImageName
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pose saved successfully!'))
        );
        
        // Reset modified flag since we saved
        _poseModified = false;
        
        // Get URLs for next screen
        final processedImageProvider = Provider.of<ProcessedImageProvider>(context, listen: false);
        final textureImageUrl = processedImageProvider.textureImageUrl;
        final originalImageUrl = processedImageProvider.originalImageUrl;
        
        // Navigate to animation picker
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimationPicker(
              textureImageUrl: textureImageUrl ?? originalImageUrl!,
              imageName: widget.imageName
            )
          )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save pose: ${response.body}'))
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving pose: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final processedImageProvider = Provider.of<ProcessedImageProvider>(context);
    final textureImageUrl = processedImageProvider.textureImageUrl;
    final originalImageUrl = processedImageProvider.originalImageUrl;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Drag Pose Adjustment'),
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
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: _undoChange,
              tooltip: 'Undo last change',
            ),
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: _resetPose,
              tooltip: 'Reset pose',
            ),
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
          child: _isLoading 
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              )
            : SafeArea(
                child: Column(
                  children: [
                    // Instructions card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        color: Colors.white.withOpacity(0.9),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instructions:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text('• Tap and drag each keypoint to adjust the pose'),
                              Text('• Use the undo button to revert changes'),
                              Text('• Use reset to start over'),
                              Text('• Save when you\'re happy with the pose'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Pose area - Takes most of the available space
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                key: _imageStackKey,
                                children: [
                                  // Background image
                                  if (textureImageUrl != null && textureImageUrl.isNotEmpty)
                                    Image.network(
                                      textureImageUrl,
                                      fit: BoxFit.contain,
                                      width: constraints.maxWidth,
                                      height: constraints.maxHeight,
                                    )
                                  else if (originalImageUrl != null && originalImageUrl.isNotEmpty)
                                    Image.network(
                                      originalImageUrl,
                                      fit: BoxFit.contain,
                                      width: constraints.maxWidth,
                                      height: constraints.maxHeight,
                                    )
                                  else
                                    const Center(child: Text('No base image to display')),
                                  
                                  // Mask overlay
                                  if (_maskImage != null)
                                    Opacity(
                                      opacity: 0.5,
                                      child: SizedBox(
                                        width: constraints.maxWidth,
                                        height: constraints.maxHeight,
                                        child: CustomPaint(
                                          painter: _MaskPainter(maskImage: _maskImage!),
                                        ),
                                      ),
                                    ),
                                  
                                  // Keypoints and skeleton
                                  if (_maskImage != null)
                                    CustomPaint(
                                      painter: _KeypointPainter(
                                        keypoints: _keypoints,
                                        image: _maskImage,
                                        widgetSize: constraints.biggest,
                                        keypointNames: _keypointNames,
                                        draggingKeypointIndex: _draggingKeypointIndex,
                                      ),
                                      size: constraints.biggest,
                                    ),
                                    
                                  // Active keypoint instruction
                                  if (_draggingKeypointIndex != null)
                                    Positioned(
                                      top: 20,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                        margin: const EdgeInsets.symmetric(horizontal: 40),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Moving: ${_keypointNames[_draggingKeypointIndex!]}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    
                                  // This transparent layer ensures gestures work over the entire pose area
                                  Positioned.fill(
                                    child: GestureDetector(
                                      onPanStart: _onPanStart,
                                      onPanUpdate: _onPanUpdate,
                                      onPanEnd: _onPanEnd,
                                      behavior: HitTestBehavior.translucent,
                                      child: Container(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    // Save button - At the very bottom, out of the way of the pose area
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _savePose,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text('Save Pose', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
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
  final List<String> keypointNames;
  final int? draggingKeypointIndex;

  // Define the connections between keypoints for skeleton
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

  _KeypointPainter({
    required this.keypoints,
    this.image,
    required this.widgetSize,
    required this.keypointNames,
    this.draggingKeypointIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null || widgetSize.isEmpty || keypoints.isEmpty) return;

    // Calculate image scaling and positioning
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

    // Draw the skeleton (connections between keypoints)
    final Paint linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (final connection in connections) {
      if (connection[0] < keypoints.length && connection[1] < keypoints.length) {
        final startPoint = keypoints[connection[0]];
        final endPoint = keypoints[connection[1]];
        
        final startX = startPoint.dx * scale + offsetX;
        final startY = startPoint.dy * scale + offsetY;
        final endX = endPoint.dx * scale + offsetX;
        final endY = endPoint.dy * scale + offsetY;

        canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          linePaint,
        );
      }
    }

    // Draw all keypoints
    for (int i = 0; i < keypoints.length; i++) {
      final Offset point = keypoints[i];
      final double x = point.dx * scale + offsetX;
      final double y = point.dy * scale + offsetY;
      
      // Determine if this point is currently being dragged
      final bool isDragging = i == draggingKeypointIndex;
      
      // Outer circle (white border)
      canvas.drawCircle(
        Offset(x, y),
        isDragging ? 12.0 : 8.0, // Larger if being dragged
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      );
      
      // Inner circle
      canvas.drawCircle(
        Offset(x, y),
        isDragging ? 10.0 : 6.0, // Larger if being dragged
        Paint()
          ..color = isDragging ? Colors.red : Colors.lightBlue
          ..style = PaintingStyle.fill,
      );

      // Draw the keypoint name for all points when hovering/dragging
      if (isDragging || draggingKeypointIndex != null) {
        final textStyle = TextStyle(
          color: Colors.white,
          fontSize: isDragging ? 16 : 12,
          fontWeight: isDragging ? FontWeight.bold : FontWeight.normal,
          shadows: [
            Shadow(
              blurRadius: 3.0,
              color: Colors.black,
              offset: Offset(1.0, 1.0),
            ),
          ],
        );
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: keypointNames[i],
            style: textStyle,
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        
        // Position text above the point
        final textX = x - textPainter.width / 2;
        final textY = y - textPainter.height - (isDragging ? 20 : 12);
        
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
  }

  @override
  bool shouldRepaint(_KeypointPainter oldDelegate) {
    return oldDelegate.keypoints != keypoints || 
           oldDelegate.image != image || 
           oldDelegate.widgetSize != widgetSize || 
           oldDelegate.draggingKeypointIndex != draggingKeypointIndex;
  }
}
