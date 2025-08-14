// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'dart:convert';
//
// void main() {
//   runApp(const CropDiseaseApp());
// }
//
// class CropDiseaseApp extends StatelessWidget {
//   const CropDiseaseApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Crop Disease Diagnosis',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.green,
//           brightness: Brightness.light,
//         ),
//         useMaterial3: true,
//       ),
//       home: const CropDiseaseScreen(),
//     );
//   }
// }
//
// class CropDiseaseScreen extends StatefulWidget {
//   const CropDiseaseScreen({super.key});
//
//   @override
//   State<CropDiseaseScreen> createState() => _CropDiseaseScreenState();
// }
//
// class _CropDiseaseScreenState extends State<CropDiseaseScreen> {
//   File? _selectedImage;
//   bool _isLoading = false;
//   String _diagnosisResult = '';
//   String _errorMessage = '';
//
//   // Hugging Face API configuration
//   static const String _apiUrl = 'https://api-inference.huggingface.co/models/wambugu71/crop_leaf_diseases_vit';
//   // Note: In a real app, you would store this securely
//   static const String _apiToken = 'YOUR_HUGGING_FACE_API_TOKEN';
//
//   final ImagePicker _picker = ImagePicker();
//
//   /// Pick an image from the gallery
//   Future<void> _pickImageFromGallery() async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );
//
//       if (image != null) {
//         setState(() {
//           _selectedImage = File(image.path);
//           _diagnosisResult = '';
//           _errorMessage = '';
//         });
//         await _analyzeImage();
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error picking image from gallery: $e';
//       });
//     }
//   }
//
//   /// Take a picture using the camera
//   Future<void> _takePicture() async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: ImageSource.camera,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         imageQuality: 85,
//       );
//
//       if (image != null) {
//         setState(() {
//           _selectedImage = File(image.path);
//           _diagnosisResult = '';
//           _errorMessage = '';
//         });
//         await _analyzeImage();
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error taking picture: $e';
//       });
//     }
//   }
//
//   /// Send image to Hugging Face model for analysis
//   Future<void> _analyzeImage() async {
//     if (_selectedImage == null) return;
//
//     setState(() {
//       _isLoading = true;
//       _diagnosisResult = '';
//       _errorMessage = '';
//     });
//
//     try {
//       // Read image file as bytes
//       final bytes = await _selectedImage!.readAsBytes();
//
//       // Prepare the request
//       final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
//       request.headers['Authorization'] = 'Bearer $_apiToken';
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           'file',
//           bytes,
//           filename: 'image.jpg',
//         ),
//       );
//
//       // Send the request
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//
//       if (response.statusCode == 200) {
//         final List<dynamic> result = json.decode(responseBody);
//         if (result.isNotEmpty) {
//           final prediction = result[0];
//           setState(() {
//             _diagnosisResult = 'Disease: ${prediction['label']}\nConfidence: ${(prediction['score'] * 100).toStringAsFixed(2)}%';
//             _isLoading = false;
//           });
//         } else {
//           setState(() {
//             _errorMessage = 'No prediction result received';
//             _isLoading = false;
//           });
//         }
//       } else {
//         setState(() {
//           _errorMessage = 'API Error: ${response.statusCode} - $responseBody';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error analyzing image: $e';
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Crop Disease Assistant',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         elevation: 2,
//       ),
//       // Add the Drawer here
//       drawer: Drawer(
//         child: ListView(
//           // Important: Remove any padding from the ListView.
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             const DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.green,
//               ),
//               child: Text(
//                 'Menu',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.home),
//               title: const Text('Home'),
//               onTap: () {
//                 // Handle the tap
//                 Navigator.pop(context); // Close the drawer
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.info_outline),
//               title: const Text('Know MSP'),
//               onTap: () {
//                 // Handle the tap
//                 Navigator.pop(context); // Close the drawer
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.wb_sunny),
//               title: const Text('Know Weather Report'),
//               onTap: () {
//                 // Handle the tap
//                 Navigator.pop(context); // Close the drawer
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.question_answer),
//               title: const Text('General FAQs'),
//               onTap: () {
//                 // Handle the tap
//                 Navigator.pop(context); // Close the drawer
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.language),
//               title: const Text('Language Support'),
//               onTap: () {
//                 // Handle the tap
//                 Navigator.pop(context); // Close the drawer
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Image selection buttons
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _isLoading ? null : _pickImageFromGallery,
//                     icon: const Icon(Icons.photo_library),
//                     label: const Text('Pick from Gallery'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _isLoading ? null : _takePicture,
//                     icon: const Icon(Icons.camera_alt),
//                     label: const Text('Take Picture'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 24),
//
//             // Selected image display
//             if (_selectedImage != null) ...[
//               Container(
//                 width: double.infinity,
//                 height: 300,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.file(
//                     _selectedImage!,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               // Loading indicator or result
//               if (_isLoading) ...[
//                 const Column(
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 16),
//                     Text(
//                       'Analyzing image...',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ] else if (_diagnosisResult.isNotEmpty) ...[
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade50,
//                     border: Border.all(color: Colors.green.shade200),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Diagnosis Result:',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         _diagnosisResult,
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ),
//               ] else if (_errorMessage.isNotEmpty) ...[
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade50,
//                     border: Border.all(color: Colors.red.shade200),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Error:',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.red,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         _errorMessage,
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ] else ...[
//               // Placeholder when no image is selected
//               Expanded(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.image,
//                         size: 80,
//                         color: Colors.grey.shade400,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Select an image to diagnose',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Use the buttons above to pick an image from your gallery or take a new picture',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey.shade500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:flutterproject/msp_screen.dart';

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

  static const String _apiUrl = 'https://api-inference.huggingface.co/models/wambugu71/crop_leaf_diseases_vit';
  static const String _apiToken = 'YOUR_HUGGING_FACE_API_TOKEN';

  final ImagePicker _picker = ImagePicker();

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
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _diagnosisResult = '';
      _errorMessage = '';
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.headers['Authorization'] = 'Bearer $_apiToken';
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'image.jpg',
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final List<dynamic> result = json.decode(responseBody);
        if (result.isNotEmpty) {
          final prediction = result[0];
          setState(() {
            _diagnosisResult =
                'Disease: ${prediction['label']}\n\nConfidence: ${(prediction['score'] * 100).toStringAsFixed(2)}%';
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'No prediction result received.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'API Error: ${response.statusCode} - $responseBody';
          _isLoading = false;
        });
      }
    } catch (e) {
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
                // This now correctly resets to the welcome screen
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
                // This is the change
                Navigator.pop(context); // Close the drawer first
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
            onPressed: () => _showPicker(context),
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
            // This is the main change
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