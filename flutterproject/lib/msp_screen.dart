// import 'package:flutter/material.dart';
//
// // A model to hold data for each crop
// class Crop {
//   final String name;
//   final String msp;
//   final String imageUrl;
//
//   const Crop({required this.name, required this.msp, required this.imageUrl});
// }
//
// // Sample data for crops.
// const List<Crop> allCrops = [
//   Crop(name: 'Wheat', msp: '₹2125', imageUrl: 'https://i.imgur.com/example_wheat.png'),
//   Crop(name: 'Paddy', msp: '₹2040', imageUrl: 'https://i.imgur.com/example_paddy.png'),
//   Crop(name: 'Maize', msp: '₹1962', imageUrl: 'https://i.imgur.com/example_maize.png'),
//   Crop(name: 'Mustard', msp: '₹5450', imageUrl: 'https://i.imgur.com/example_mustard.png'),
//   Crop(name: 'Sugarcane', msp: '₹3050', imageUrl: 'https://i.imgur.com/example_sugarcane.png'),
//   Crop(name: 'Cotton', msp: '₹6080', imageUrl: 'https://i.imgur.com/example_cotton.png'),
// ];
//
//
// class MspScreen extends StatefulWidget {
//   const MspScreen({super.key});
//
//   @override
//   State<MspScreen> createState() => _MspScreenState();
// }
//
// class _MspScreenState extends State<MspScreen> {
//   // This list will hold the crops displayed in the grid
//   List<Crop> _displayedCrops = allCrops;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('MSP'),
//         elevation: 2,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Combined Search and Dropdown using Autocomplete
//             Autocomplete<Crop>(
//               optionsBuilder: (TextEditingValue textEditingValue) {
//                 // If the field is empty, show all crops as suggestions.
//                 if (textEditingValue.text.isEmpty) {
//                   return allCrops.toList();
//                 }
//                 // Otherwise, filter the list based on what the user has typed.
//                 return allCrops.where((Crop crop) {
//                   return crop.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
//                 });
//               },
//               displayStringForOption: (Crop crop) => crop.name,
//               fieldViewBuilder: (BuildContext context, TextEditingController fieldController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
//                 return TextField(
//                   controller: fieldController,
//                   focusNode: fieldFocusNode,
//                   decoration: InputDecoration(
//                     hintText: 'Search or Select Crop...',
//                     prefixIcon: const Icon(Icons.search),
//                     // Add a clear button to reset the search and grid
//                     suffixIcon: IconButton(
//                       icon: const Icon(Icons.clear),
//                       onPressed: () {
//                         fieldController.clear();
//                         setState(() {
//                           _displayedCrops = allCrops;
//                         });
//                         // Hide the keyboard
//                         FocusScope.of(context).unfocus();
//                       },
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey[200],
//                   ),
//                 );
//               },
//               onSelected: (Crop selection) {
//                 // When a user selects a crop, update the grid to show only that crop.
//                 setState(() {
//                   _displayedCrops = [selection];
//                 });
//                  // Hide the keyboard
//                 FocusScope.of(context).unfocus();
//               },
//             ),
//             const SizedBox(height: 20),
//
//             // Grid of Crops
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                   childAspectRatio: 0.8,
//                 ),
//                 itemCount: _displayedCrops.length,
//                 itemBuilder: (context, index) {
//                   final crop = _displayedCrops[index];
//                   return Card(
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     clipBehavior: Clip.antiAlias,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Expanded(
//                           child: Container(
//                             color: Colors.grey.shade300,
//                             child: const Icon(Icons.image, size: 50, color: Colors.grey),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(crop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
//                               Text(crop.msp, style: const TextStyle(color: Colors.black54)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

// A model to hold data for each crop
class Crop {
  final String name;
  final String msp;
  final String imageUrl;

  const Crop({required this.name, required this.msp, required this.imageUrl});
}

// Sample data for crops.
const List<Crop> allCrops = [
  Crop(name: 'Wheat', msp: '₹2125', imageUrl: 'https://i.imgur.com/example_wheat.png'),
  Crop(name: 'Paddy', msp: '₹2040', imageUrl: 'https://i.imgur.com/example_paddy.png'),
  Crop(name: 'Maize', msp: '₹1962', imageUrl: 'https://i.imgur.com/example_maize.png'),
  Crop(name: 'Mustard', msp: '₹5450', imageUrl: 'https://i.imgur.com/example_mustard.png'),
  Crop(name: 'Sugarcane', msp: '₹3050', imageUrl: 'https://i.imgur.com/example_sugarcane.png'),
  Crop(name: 'Cotton', msp: '₹6080', imageUrl: 'https://i.imgur.com/example_cotton.png'),
];


class MspScreen extends StatefulWidget {
  const MspScreen({super.key});

  @override
  State<MspScreen> createState() => _MspScreenState();
}

class _MspScreenState extends State<MspScreen> {
  List<Crop> _displayedCrops = allCrops;
  final TextEditingController _autocompleteController = TextEditingController();

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Initialize the speech-to-text service
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      // The status listener is now in the initialize method
      onStatus: (status) {
        // The status is a string, e.g., "listening", "notListening"
        if (status == 'notListening' && _isListening) {
          setState(() => _isListening = false);
          _autoSubmitSpeechResult();
        }
      },
      onError: (errorNotification) {
        // Handle errors here
        setState(() => _isListening = false);
      },
    );
    setState(() {});
  }

  /// Start a new speech recognition session
  void _startListening() async {
    setState(() => _isListening = true);
    await _speechToText.listen(
      onResult: (result) {
        _autocompleteController.text = result.recognizedWords;
      },
    );
  }

  /// Manually stop the active session
  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  /// Auto-submit logic
  void _autoSubmitSpeechResult() {
    final spokenText = _autocompleteController.text.trim().toLowerCase();
    if (spokenText.isEmpty) return;

    Crop? bestMatch;
    try {
      bestMatch = allCrops.firstWhere(
        (crop) => crop.name.toLowerCase().contains(spokenText),
      );
    } catch (e) {
      bestMatch = null;
    }

    if (bestMatch != null) {
      setState(() {
        _displayedCrops = [bestMatch!];
        _autocompleteController.text = bestMatch.name;
      });
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MSP'),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Autocomplete<Crop>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                final query = textEditingValue.text.toLowerCase();
                if (query.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _displayedCrops = allCrops);
                  });
                }

                if (textEditingValue.text.isEmpty) {
                  return allCrops.toList();
                }
                return allCrops.where((Crop crop) {
                  return crop.name.toLowerCase().contains(query);
                });
              },
              displayStringForOption: (Crop crop) => crop.name,
              fieldViewBuilder: (BuildContext context, TextEditingController fieldController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                _autocompleteController.addListener(() {
                  if (fieldController.text != _autocompleteController.text) {
                    fieldController.text = _autocompleteController.text;
                  }
                });

                return TextField(
                  controller: fieldController,
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search or Select Crop...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (fieldController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              fieldController.clear();
                              _autocompleteController.clear();
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        IconButton(
                          icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                          onPressed: _speechEnabled ? (_isListening ? _stopListening : _startListening) : null,
                          tooltip: 'Listen for crop name',
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                );
              },
              onSelected: (Crop selection) {
                setState(() => _displayedCrops = [selection]);
                FocusScope.of(context).unfocus();
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _displayedCrops.length,
                itemBuilder: (context, index) {
                  final crop = _displayedCrops[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(crop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(crop.msp, style: const TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}