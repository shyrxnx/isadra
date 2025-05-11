import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BackgroundPicker {
  static Future<XFile?> pickBackgroundImage(ImagePicker picker) async {
    return await picker.pickImage(source: ImageSource.gallery);
  }

  static Widget buildBackgroundWidget(File imageFile) {
    return Container(
      width: double.infinity,
      height: 360,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple),
        image: DecorationImage(
          image: FileImage(imageFile),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}