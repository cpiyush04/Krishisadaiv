import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:flutterproject/msp_screen.dart';
import 'dart:typed_data';

void main() {
  runApp(const CropDiseaseApp());
}

class CropDiseaseApp extends StatelessWidget {
  const CropDiseaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Disease Helper',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const CropDiseaseScreen(),
    );
  }
}

class CropDiseaseScreen extends StatefulWidget {
  const CropDiseaseScreen({super.key});

  @override
  State<CropDiseaseScreen> createState() => _CropDiseaseScreenState();
}

class _CropDiseaseScreenState extends State<CropDiseaseScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  String _diagnosisResult = '';
  String _errorMessage = '';
  bool _modelLoading = true;

  ClassificationModel? _model;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _model = await PytorchLite.loadClassificationModel(
        "assets/models/model.ptl",
        224,
        224,
        13, // Make sure this is the correct number of classes
        labelPath: "assets/models/labels.txt",
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading model: $e';
      });
    } finally {
      setState(() {
        _modelLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _diagnosisResult = '';
          _errorMessage = '';
        });
        await _analyzeImage();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
      if (_selectedImage == null || _model == null) {
        print("Model or image is null. Aborting analysis.");
        return;
      }

      setState(() {
        _isLoading = true;
        _diagnosisResult = '';
        _errorMessage = '';
      });

      try {
        print("Starting image analysis...");
        final Uint8List imageBytes = await _selectedImage!.readAsBytes();

        // The result can be a List on success or a String on failure.
        // So we declare it as 'dynamic' to hold either type.
        final String results = await _model!.getImagePrediction(
          imageBytes,
          mean: [0.5, 0.5, 0.5],
          std: [0.5, 0.5, 0.5],
        );

        print("Model results: $results");

        // Now, we check the type of the result.
        if (results.isNotEmpty) {
          // If it's a list, proceed as normal.
          setState(() {
            _diagnosisResult = 'Disease: $results';
            _isLoading = false;
          });
        }
        else {
          // If it's not a list (e.g., it's the "Invalid" string) or it's an empty list, show an error.
          print("No valid results received. The result was: $results");
          setState(() {
            _errorMessage = 'Model failed to return a valid prediction. Please ensure assets are configured correctly.';
            _isLoading = false;
          });
        }
      } catch (e) {
        print("An error occurred during analysis: $e");
        setState(() {
          _errorMessage = 'Error analyzing image: $e';
          _isLoading = false;
        });
      }
    }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Photo Library'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Krishi-Sadev',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 2,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                setState(() {
                  _selectedImage = null;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Know MSP'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MspScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: const Text('Know Weather Report'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('General FAQs'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language Support'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: _selectedImage == null
              ? buildWelcomeScreen(context)
              : buildResultScreen(context),
        ),
      ),
    );
  }

  Widget buildWelcomeScreen(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Welcome, Farmer!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Krishi-Sadev, at your service.',
          style: TextStyle(fontSize: 18, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (_modelLoading)
          const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading Model..."),
              ],
            ),
          )
        else
          Expanded(
            child: GestureDetector(
              onTap: () => _showPicker(context),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.black38,
                      child: Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Upload crop photo here...',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _modelLoading ? null : () => _showPicker(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Take/Add Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildResultScreen(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Krishi-Sadev',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Issue with the crop:',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_diagnosisResult.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    _diagnosisResult,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )
              else if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _showPicker(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Take/Add Another Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}