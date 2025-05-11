import 'package:flutter/material.dart';
import '../widgets/draggable_scalable_widget.dart';
import 'color_circle.dart';

class TextEditor {
  static void showTextDialog(BuildContext context, Function(String, Color) onTextAdded) {
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
  ) {
    return DraggableScalableWidget(
      uniqueId: uniqueId,
      initialX: x,
      initialY: y,
      initialScale: scale,
      onPositionChanged: onPositionChanged,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _AddTextDialog extends StatefulWidget {
  final Function(String, Color) onTextAdded;

  const _AddTextDialog({required this.onTextAdded});

  @override
  State<_AddTextDialog> createState() => _AddTextDialogState();
}

class _AddTextDialogState extends State<_AddTextDialog> {
  TextEditingController textController = TextEditingController(text: "Sample Text");
  Color _selectedColor = Colors.black;

  void _selectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Text"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: textController,
            decoration: const InputDecoration(labelText: "Enter text"),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ColorCircle(color: Colors.black, selectedColor: _selectedColor, onColorSelected: _selectColor),
              ColorCircle(color: Colors.white, selectedColor: _selectedColor, onColorSelected: _selectColor),
              ColorCircle(color: Colors.red, selectedColor: _selectedColor, onColorSelected: _selectColor),
              ColorCircle(color: Colors.blue, selectedColor: _selectedColor, onColorSelected: _selectColor),
              ColorCircle(color: Colors.green, selectedColor: _selectedColor, onColorSelected: _selectColor),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text("Add"),
          onPressed: () {
            Navigator.pop(context);
            widget.onTextAdded(textController.text, _selectedColor);
          },
        ),
      ],
    );
  }
}