import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImageLabelingScreen(),
    );
  }
}

class ImageLabelingScreen extends StatefulWidget {
  @override
  _ImageLabelingScreenState createState() => _ImageLabelingScreenState();
}

class _ImageLabelingScreenState extends State<ImageLabelingScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List<ImageLabel> _imageLabels = [];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      _labelImage(pickedFile.path);
    }
  }

  Future<void> _labelImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));

    try {
      final labels = await imageLabeler.processImage(inputImage);
      setState(() {
        _imageLabels = labels;
      });
    } catch (e) {
      print("Error during image labeling: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Labeling Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imageFile == null
                  ? Text('No image selected.')
                  : Image.file(_imageFile!, height: 300, fit: BoxFit.cover),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick an Image'),
              ),
              SizedBox(height: 20),
              _imageLabels.isEmpty
                  ? Text('No labels detected yet.')
                  : Column(
                      children: _imageLabels.map((label) {
                        return ListTile(
                          title: Text(label.label),
                          subtitle: Text('Confidence: ${(label.confidence * 100).toStringAsFixed(2)}%'),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
