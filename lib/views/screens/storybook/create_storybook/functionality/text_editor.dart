import 'package:flutter/material.dart';
import '../widgets/draggable_scalable_widget.dart';
import 'color_circle.dart';
import 'package:google_fonts/google_fonts.dart';

class TextEditor {
  static void showTextDialog(BuildContext context, Function(String, Color, int, double, bool) onTextAdded) {
    showDialog(
      context: context,
      builder: (context) {
        return _AddTextDialog(onTextAdded: onTextAdded);
      },
    );
  }

  static Widget buildTextWidget(
    String text,
    Color color,
    double x,
    double y,
    double scale,
    String uniqueId,
    Function(double x, double y, double scale) onPositionChanged,
    {int fontStyle = 0, double fontSize = 24, bool isBold = false}
  ) {
    TextStyle textStyle;
    FontWeight weight = isBold ? FontWeight.bold : FontWeight.normal;
    
    switch (fontStyle) {
      case 1: // Playful
        textStyle = GoogleFonts.indieFlower(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
        );
        break;
      case 2: // Bold
        textStyle = GoogleFonts.roboto(
          fontSize: fontSize,
          fontWeight: FontWeight.bold, // Always bold for this style
          color: color,
        );
        break;
      case 3: // Fancy
        textStyle = GoogleFonts.dancingScript(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
        );
        break;
      case 0: // Default
      default:
        textStyle = TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
        );
    }
    
    return DraggableScalableWidget(
      uniqueId: uniqueId,
      initialX: x,
      initialY: y,
      initialScale: scale,
      onPositionChanged: onPositionChanged,
      child: Text(
        text,
        style: textStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _AddTextDialog extends StatefulWidget {
  final Function(String, Color, int, double, bool) onTextAdded;

  const _AddTextDialog({required this.onTextAdded});

  @override
  State<_AddTextDialog> createState() => _AddTextDialogState();
}

class _AddTextDialogState extends State<_AddTextDialog> {
  TextEditingController textController = TextEditingController();
  Color _selectedColor = Colors.black;
  FontWeight _selectedWeight = FontWeight.normal;
  double _fontSize = 24.0;
  int _selectedFontIndex = 0;
  
  final List<String> _fontOptions = [
    'Default',
    'Playful',
    'Bold',
    'Fancy',
  ];
  
  final List<Color> _colorOptions = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
  ];

  void _selectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }
  
  void _toggleBold() {
    setState(() {
      _selectedWeight = _selectedWeight == FontWeight.bold ? FontWeight.normal : FontWeight.bold;
    });
  }
  
  void _increaseFontSize() {
    setState(() {
      _fontSize = _fontSize + 2 > 48 ? 48 : _fontSize + 2;
    });
  }
  
  void _decreaseFontSize() {
    setState(() {
      _fontSize = _fontSize - 2 < 16 ? 16 : _fontSize - 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.text_fields, color: Colors.green.shade700, size: 28),
                const SizedBox(width: 10),
                Text(
                  "Add Your Text",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 20),
            
            // Text Preview
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: textController.text.isEmpty
                ? Text(
                    "Type your text below",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    textController.text,
                    style: _getTextStyle(),
                    textAlign: TextAlign.center,
                  ),
            ),
            
            // Text Input
            TextField(
              controller: textController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                labelText: "Enter your text",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green.shade300),
                ),
                prefixIcon: const Icon(Icons.edit, color: Colors.grey),
              ),
              onChanged: (value) {
                setState(() {}); // Update preview
              },
            ),
            const SizedBox(height: 20),
            
            // Font Style Options
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Font Style:", style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _fontOptions.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFontIndex = index;
                          });
                        },
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _selectedFontIndex == index
                                ? Colors.green.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _selectedFontIndex == index
                                  ? Colors.green.shade400
                                  : Colors.transparent,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _fontOptions[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedFontIndex == index ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Font Size
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Font Size:", style: TextStyle(color: Colors.grey.shade700)),
                const Spacer(),
                IconButton(
                  onPressed: _decreaseFontSize,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.grey.shade700,
                ),
                Text(
                  _fontSize.toInt().toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _increaseFontSize,
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                // Bold toggle
                IconButton(
                  onPressed: _toggleBold,
                  icon: Icon(
                    Icons.format_bold,
                    color: _selectedWeight == FontWeight.bold
                        ? Colors.green.shade700
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Colors
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Text Color:", style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colorOptions.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final color = _colorOptions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: GestureDetector(
                          onTap: () => _selectColor(color),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == color
                                    ? Colors.green.shade400
                                    : Colors.grey.shade400,
                                width: _selectedColor == color ? 3 : 1,
                              ),
                              boxShadow: _selectedColor == color
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: _selectedColor == color
                                ? const Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onTextAdded(
                      textController.text,
                      _selectedColor,
                      _selectedFontIndex,
                      _fontSize,
                      _selectedWeight == FontWeight.bold
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("Add Text"),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }
  
  TextStyle _getTextStyle() {
    switch (_selectedFontIndex) {
      case 1: // Playful
        return GoogleFonts.indieFlower(
          fontSize: _fontSize,
          fontWeight: _selectedWeight,
          color: _selectedColor,
        );
      case 2: // Bold
        return GoogleFonts.roboto(
          fontSize: _fontSize,
          fontWeight: FontWeight.bold,
          color: _selectedColor,
        );
      case 3: // Fancy
        return GoogleFonts.dancingScript(
          fontSize: _fontSize,
          fontWeight: _selectedWeight,
          color: _selectedColor,
        );
      case 0: // Default
      default:
        return TextStyle(
          fontSize: _fontSize,
          fontWeight: _selectedWeight,
          color: _selectedColor,
        );
    }
  }
}