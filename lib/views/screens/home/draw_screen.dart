import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import '/core/services/api_service.dart';
import 'package:provider/provider.dart';
import '../../../core/state/processed_image.dart';
import '../animation/annotation_picker.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

class DrawScreen extends StatefulWidget {
  const DrawScreen({Key? key}) : super(key: key);

  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  final GlobalKey _boundaryKey = GlobalKey(); // Key for RepaintBoundary
  List<List<Offset?>> strokes = [];
  List<Color> strokeColors = [];
  List<double> strokeWidths = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 4.0;
  final ApiService _apiService = ApiService(); // For API calls
  bool _isLoading = false; // Loading state
  DrawingTool _currentTool = DrawingTool.brush; // Default to brush

  // Function to pick color
  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: BlockPicker(
          pickerColor: selectedColor,
          onColorChanged: (color) {
            setState(() {
              selectedColor = color;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // Start a new stroke
  Future<void> _startNewStroke(Offset localPosition) async {
    if (_currentTool == DrawingTool.brush) {
      setState(() {
        strokes.add([localPosition]);
        strokeColors.add(selectedColor);
        strokeWidths.add(8.0);
      });
    } else if (_currentTool == DrawingTool.fill) {
      await _floodFill(localPosition);
    }
  }

  // Update the current stroke
  void _updateStroke(Offset localPosition) {
    if (_currentTool == DrawingTool.brush) {
      setState(() {
        strokes.last.add(localPosition);
      });
    }
  }

  // Undo the last action (stroke or fill)
  void _undo() {
    if (strokes.isNotEmpty) {
      setState(() {
        strokes.removeLast();
        strokeColors.removeLast();
        strokeWidths.removeLast();
      });
    }
  }

  // Clear the canvas
  void _clearCanvas() {
    setState(() {
      strokes.clear();
      strokeColors.clear();
      strokeWidths.clear();
    });
  }

  // Flood fill algorithm
  Future<void> _floodFill(Offset startPoint) async {
    if (_boundaryKey.currentContext == null) return;

    final RenderRepaintBoundary boundary = _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return;

    final int width = image.width;
    final int height = image.height;
    final Uint8List bytes = byteData.buffer.asUint8List();

    int pointToOffset(Offset point) {
      int x = point.dx.toInt().clamp(0, width - 1);
      int y = point.dy.toInt().clamp(0, height - 1);
      return (y * width + x) * 4; // 4 bytes per pixel (RGBA)
    }

    Color getPixelColor(Offset point) {
      final int offset = pointToOffset(point);
      if (offset >= 0 && offset + 3 < bytes.length) {
        return Color.fromARGB(
          bytes[offset + 3], // Alpha
          bytes[offset],     // Red
          bytes[offset + 1], // Green
          bytes[offset + 2], // Blue
        );
      }
      return Colors.transparent; // Or some default invalid color
    }

    if (!_isWithinBounds(startPoint, width, height)) return;

    final Color targetColor = getPixelColor(startPoint);
    final Color replacementColor = selectedColor;

    if (targetColor == replacementColor) return;

    final List<Offset> queue = [startPoint];
    final Set<Offset> visited = {startPoint};
    final List<Offset?> fillPoints = [];
    final Color fillStrokeColor = selectedColor;
    const double fillStrokeWidth = 1.0; // Adjust as needed for visual representation

    while (queue.isNotEmpty) {
      final Offset currentPoint = queue.removeAt(0);
      fillPoints.add(currentPoint);

      final int x = currentPoint.dx.toInt();
      final int y = currentPoint.dy.toInt();

      // Check adjacent pixels
      final List<Offset> neighbors = [
        Offset(x + 1, y.toDouble()),
        Offset(x - 1, y.toDouble()),
        Offset(x.toDouble(), y + 1),
        Offset(x.toDouble(), y - 1),
      ];

      for (final neighbor in neighbors) {
        if (_isWithinBounds(neighbor, width, height) &&
            !visited.contains(neighbor) &&
            getPixelColor(neighbor) == targetColor) {
          visited.add(neighbor);
          queue.add(neighbor);
        }
      }
    }

    if (fillPoints.isNotEmpty) {
      setState(() {
        strokes.add(fillPoints);
        strokeColors.add(fillStrokeColor);
        strokeWidths.add(fillStrokeWidth);
      });
    }
  }

  bool _isWithinBounds(Offset point, int width, int height) {
    return point.dx >= 0 && point.dx < width && point.dy >= 0 && point.dy < height;
  }

  // Export drawing to an image file with a unique name and resize it
  Future<File> _exportDrawingToImage() async {
    RenderRepaintBoundary boundary = _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      final buffer = byteData.buffer;
      final directory = await getTemporaryDirectory();

      // Generate a unique filename using the current timestamp
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final originalFile = File('${directory.path}/drawing_$timestamp.png');

      // Write the original image to a file
      await originalFile.writeAsBytes(buffer.asUint8List());

      // Load the original image using the image package
      img.Image originalImage = img.decodeImage(await originalFile.readAsBytes())!;

      // Resize the image to 384x512
      img.Image resizedImage = img.copyResize(originalImage, width: 384, height: 512);

      // Create a new file for the resized image
      final resizedFile = File('${directory.path}/drawing_$timestamp.png');

      // Write the resized image to the new file
      await resizedFile.writeAsBytes(img.encodePng(resizedImage));

      return resizedFile; // Return the resized image file
    }
    throw Exception('Failed to export drawing');
  }

  // Process the drawing by sending it to the API and navigate to ManualPoseAnnotationScreen
  Future<void> _processDrawing(BuildContext context) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      File drawingFile = await _exportDrawingToImage();
      String? resultUrl = await _apiService.uploadImage(drawingFile);

      if (resultUrl != null) {
        print('API Response from DrawScreen: $resultUrl'); // Print raw response
        try {
          var decoded = json.decode(resultUrl);
          print('Decoded API Response from DrawScreen: $decoded'); // Print decoded
          if (decoded.containsKey('mask_url') && decoded.containsKey('texture_url') && decoded.containsKey('orig_image_url')) {
            final imageName = decoded['image_name'];
            // Update ProcessedImageProvider with the received URLs
            Provider.of<ProcessedImageProvider>(context, listen: false).setProcessedImageUrls(
              maskUrl: decoded['mask_url'],
              textureUrl: decoded['texture_url'],
              originalUrl: decoded['orig_image_url'],
            );
            print('Image uploaded successfully. Image Name: $imageName, URLs: ${decoded['mask_url']}');
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PoseAnnotationChoiceScreen(imageName: imageName),
                ));
          } else {
            print('Error: Unexpected JSON structure in API response from DrawScreen');
            _showErrorDialog(context);
          }
        } on FormatException catch (e) {
          // If decoding fails, assume it's a direct URL string
          print("FormatException in _processDrawing: $e");
          Provider.of<ProcessedImageProvider>(context, listen: false).setProcessedImageUrls(
            maskUrl: resultUrl,
            textureUrl: resultUrl, // Adjust as needed
            originalUrl: resultUrl, // Adjust as needed
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const PoseAnnotationChoiceScreen(
                  imageName: '',
                )),
          );
        } catch (e) {
          print('Error processing drawing in DrawScreen: $e');
          _showErrorDialog(context);
        }
      } else {
        _showErrorDialog(context);
      }
    } catch (e) {
      print('Error processing drawing in DrawScreen: $e');
      _showErrorDialog(context);
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  // Show error dialog
  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error ❌'),
        content: const Text('Failed to process the drawing.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canvas'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undo,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearCanvas,
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _processDrawing(context), // Trigger export & process
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: RepaintBoundary(
                  key: _boundaryKey, // Wrap canvas with a RepaintBoundary
                  child: GestureDetector(
                    onPanStart: (details) => _startNewStroke(details.localPosition),
                    onPanUpdate: (details) => _updateStroke(details.localPosition),
                    onTapDown: (details) {
                      if (_currentTool == DrawingTool.fill) {
                        _startNewStroke(details.localPosition);
                      }
                    },
                    child: Container(
                      color: Colors.white, // Set canvas background to white
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: DrawingPainter(strokes, strokeColors, strokeWidths),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.green,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.color_lens, color: selectedColor),
                      onPressed: _pickColor,
                    ),
                    _buildToolButton(DrawingTool.brush, Icons.brush), // Brush
                    _buildToolButton(DrawingTool.fill, Icons.format_color_fill), // Fill Bucket
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading) // Show loading indicator if loading
            Container(
              color: Colors.black26, // Optional: semi-transparent background
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.teal,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolButton(DrawingTool tool, IconData icon) {
    return IconButton(
      icon: Icon(icon, color: _currentTool == tool ? selectedColor : Colors.grey[600]),
      onPressed: () {
        setState(() {
          _currentTool = tool;
          // Optionally set stroke width based on the tool
          if (tool == DrawingTool.brush) {
            strokeWidth = 8.0;
          }
        });
      },
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset?>> strokes;
  final List<Color> strokeColors;
  final List<double> strokeWidths;

  DrawingPainter(this.strokes, this.strokeColors, this.strokeWidths);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < strokes.length; i++) {
      Paint paint = Paint()
        ..color = strokeColors[i]
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidths[i]
        ..style = PaintingStyle.stroke; // Default to stroke

      if (strokeWidths[i] == 1.0 && strokes[i].length > 1) {
        // For fill representation (single points), draw a point
        for (final point in strokes[i]) {
          if (point != null) {
            canvas.drawCircle(point, 1.0, paint..style = PaintingStyle.fill);
          }
        }
      } else {
        // For lines (brush)
        for (int j = 0; j < strokes[i].length - 1; j++) {
          if (strokes[i][j] != null && strokes[i][j + 1] != null) {
            canvas.drawLine(strokes[i][j]!, strokes[i][j + 1]!, paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

enum DrawingTool {
  brush,
  fill,
}