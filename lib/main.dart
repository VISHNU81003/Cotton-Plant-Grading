import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ObjectDetectionScreen(),
    );
  }
}

class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({super.key});

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  List<dynamic>? _recognitions;
  String resultText = "";

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  // Load TensorFlow Lite model
  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
      );
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = image;
          file = File(image.path);
        });
        detectImage(file!);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // Capture image with camera
  Future<void> _captureImageWithCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _image = image;
          file = File(image.path);
        });
        detectImage(file!);
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  // Detect and classify leaves in the plant image
  Future<void> detectImage(File image) async {
    try {
      var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 6,
        threshold: 0.05,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        Map<String, int> classCounts = {};
        for (var rec in recognitions) {
          String label = rec['label'];
          classCounts[label] = (classCounts[label] ?? 0) + 1;
        }

        String majorityClass = classCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

        setState(() {
          _recognitions = recognitions;
          resultText = "Plant Grade: $majorityClass";
        });
      } else {
        setState(() {
          resultText = "No objects detected!";
        });
      }
    } catch (e) {
      print("Error running model: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 86, 197, 216),
      appBar: AppBar(
        toolbarHeight: 100,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 60,
              width: 60,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Plant grading App',
                style: GoogleFonts.poppins(
                  color: const Color.fromARGB(255, 255, 252, 64),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 10),
            Image.asset(
              'assets/logo2.png',
              height: 60,
              width: 60,
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 86, 197, 216),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'COTTON PLANT GRADING BASED ON JASSID INFESTATION',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 255, 252, 64),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  if (_image != null)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade400,
                            Colors.deepPurple.shade800,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_image!.path),
                          height: 250,
                          width: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    const Text(
                      ' ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  const SizedBox(height: 20),

                  // Pick Image from Gallery Button
                  ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(
                      Icons.image,
                      size: 24,
                    ),
                    label: const Text(
                      'Pick Image from Gallery',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Capture Image with Camera Button
                  ElevatedButton.icon(
                    onPressed: _captureImageWithCamera,
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 20,
                    ),
                    label: const Text(
                      'Capture Image with Camera',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_recognitions != null)
                    Card(
                      elevation: 8,
                      shadowColor: Colors.deepPurple.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Plant Grade',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple.shade700,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Display the result
                            Text(
                              resultText,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.deepPurple.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      // Bottom content bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(1),
        color: const Color.fromARGB(255, 86, 197, 216),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [        
            const SizedBox(height: 4),
            Text(
              'Vishnu S\n© Copyright 2025. All rights Reserved.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 252, 64),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
