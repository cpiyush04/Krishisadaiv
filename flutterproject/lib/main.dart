import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:flutterproject/msp_screen.dart';
import 'dart:typed_data';
import 'package:flutterproject/general_faqs_screen.dart';
import 'package:flutterproject/weather_screen.dart';
import 'package:flutterproject/fertilizer_screen.dart'; // Import the new screen

// Data model for holding detailed disease information
class DiseaseInfo {
  final String name;
  final String description;
  final String preventiveMeasures;

  DiseaseInfo({
    required this.name,
    required this.description,
    required this.preventiveMeasures,
  });
}

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
        useMaterial3: true,
        // Define a color scheme seeded with a nice shade of green
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green.shade800, // A deep, earthy green
          brightness: Brightness.light,
        ),
        // Customize AppBar theme for a consistent look
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green.shade800,
          foregroundColor: Colors.white, // Ensures title and icons are white
        ),
        // Define a global style for all ElevatedButtons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700, // Button color
            foregroundColor: Colors.white, // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
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
  // State variables
  File? _selectedImage;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _modelLoading = true;
  String _selectedLanguage = 'English';

  // Model and Image Picker
  ClassificationModel? _model;
  final ImagePicker _picker = ImagePicker();

  // Disease information state
  Map<String, dynamic> _diseaseData = {};
  DiseaseInfo? _detectedDiseaseInfo;


  @override
  void initState() {
    super.initState();
    _loadModel();
    _loadDiseaseData(); // Load disease data on start
  }

  // Load the diseases.json file from assets
  Future<void> _loadDiseaseData() async {
    final String response = await rootBundle.loadString('assets/diseases.json');
    final data = await json.decode(response);
    if (mounted) {
      setState(() {
        _diseaseData = data;
      });
    }
  }

  // Load the machine learning model
  Future<void> _loadModel() async {
    try {
      _model = await PytorchLite.loadClassificationModel(
        "assets/models/model.ptl", 224, 224, 13,
        labelPath: "assets/models/labels.txt",
      );
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Error loading model: $e');
    } finally {
      if (mounted) setState(() => _modelLoading = false);
    }
  }

  // Pick an image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _detectedDiseaseInfo = null;
          _errorMessage = '';
        });
        await _analyzeImage();
      }
    } catch (e) {
       if (mounted) setState(() => _errorMessage = 'Error picking image: $e');
    }
  }

  // Analyze the image and display detailed disease information
  Future<void> _analyzeImage() async {
    if (_selectedImage == null || _model == null || _diseaseData.isEmpty) return;

    setState(() {
      _isLoading = true;
      _detectedDiseaseInfo = null;
      _errorMessage = '';
    });

    try {
      final String resultLabel = await _model!.getImagePrediction(
        await _selectedImage!.readAsBytes(),
        mean: [0.5, 0.5, 0.5], std: [0.5, 0.5, 0.5],
      );

      if (resultLabel.isNotEmpty) {
        final englishList = _diseaseData['crop_statuses_english'] as List;
        final diseaseJson = englishList.firstWhere(
            (d) => d['item_name'] == resultLabel, orElse: () => null);

        if (diseaseJson != null) {
          final diseaseId = diseaseJson['id'];
          final hindiList = _diseaseData['crop_statuses_hindi'] as List;
          final hindiJson = hindiList.firstWhere((d) => d['id'] == diseaseId, orElse: () => null);

          if (hindiJson != null && mounted) {
            setState(() {
              _detectedDiseaseInfo = DiseaseInfo(
                name: _selectedLanguage == 'English' ? diseaseJson['item_name'] : hindiJson['item_name'],
                description: _selectedLanguage == 'English' ? diseaseJson['description'] : hindiJson['description'],
                preventiveMeasures: _selectedLanguage == 'English' ? diseaseJson['detailed_action'] : hindiJson['detailed_action'],
              );
            });
          }
        } else {
           _errorMessage = 'Could not find details for the detected disease.';
        }
      } else {
        _errorMessage = 'Model failed to return a valid prediction.';
      }
    } catch (e) {
      _errorMessage = 'Error analyzing image: $e';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Show the image picker modal
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
        title: Text(
                  _selectedLanguage == 'English' ? 'Krishi-Sadev' : 'कृषि-सदैव',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        elevation: 2,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                _selectedLanguage == 'English' ? 'Menu' : 'मेनू',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(_selectedLanguage == 'English' ? 'Home' : 'होम'),
              onTap: () {
                setState(() => _selectedImage = null);
                Navigator.pop(context);
              },
            ),
             ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(_selectedLanguage == 'English' ? 'Know MSP' : 'एमएसपी जानें'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => MspScreen(selectedLanguage: _selectedLanguage)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.science_outlined),
              title: Text(_selectedLanguage == 'English' ? 'Know About Fertilizers' : 'उर्वरकों के बारे में जानें'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FertilizerScreen(selectedLanguage: _selectedLanguage)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: Text(_selectedLanguage == 'English' ? 'Know Weather Report' : 'मौसम रिपोर्ट जानें'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => WeatherScreen(selectedLanguage: _selectedLanguage)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_answer),
              title: Text(_selectedLanguage == 'English' ? 'General FAQs' : 'सामान्य अक्सर पूछे जाने वाले प्रश्न'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => FaqsScreen(selectedLanguage: _selectedLanguage)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_selectedLanguage == 'English' ? 'Language' : 'भाषा'),
                  DropdownButton<String>(
                    value: _selectedLanguage,
                    items: <String>['English', 'Hindi'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) setState(() => _selectedLanguage = newValue);
                    },
                  ),
                ],
              ),
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

  // The screen shown after an image is selected
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
                  image: DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_detectedDiseaseInfo != null)
                _buildDiseaseInfoWidget(_detectedDiseaseInfo!)
              else if (_errorMessage.isNotEmpty)
                _buildErrorWidget(_errorMessage),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showPicker(context),
            child: Text(
              _selectedLanguage == 'English' ? 'Take/Add Another Photo' : 'दूसरी तस्वीर लें/जोड़ें',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // Widget to display the detailed disease information
  Widget _buildDiseaseInfoWidget(DiseaseInfo info) {
    bool isEnglish = _selectedLanguage == 'English';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(info.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildInfoSection(isEnglish ? 'Description' : 'विवरण', info.description),
        const SizedBox(height: 16),
        _buildInfoSection(isEnglish ? 'Preventive Measures' : 'निवारक उपाय', info.preventiveMeasures),
      ],
    );
  }

  // Helper for styling sections
  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
      ],
    );
  }

  // Helper for displaying error messages
  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 16, color: Colors.red.shade800),
        textAlign: TextAlign.center,
      ),
    );
  }

  // The initial welcome screen
  Widget buildWelcomeScreen(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _selectedLanguage == 'English' ? 'Welcome, Dear Farmer!' : 'प्रिय कृषक, आपका स्वागत है!',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _selectedLanguage == 'English' ? 'Krishi-Sadev, available at your service.' : 'कृषि-सदैव, आपकी सेवा में उपस्थित है।',
          style: const TextStyle(fontSize: 18, color: Colors.black54),
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
                  border: Border.all(color: Colors.green.shade200, width: 2),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.green.shade50,
                      child: Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedLanguage == 'English' ? 'Upload crop photo here...' : 'फसल की तस्वीर यहां अपलोड करें...',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _modelLoading ? null : () => _showPicker(context),
            child: Text(
              _selectedLanguage == 'English' ? 'Take/Add Photo' : 'फोटो लें/अपलोड करें',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}