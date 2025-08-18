import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

// Data model for a single crop, updated to match the new JSON structure.
class Crop {
  final String name;
  final String variety;
  final String msp2025_26;
  final String costOfProduction;
  final String marginOverCost;
  final String increaseFrom2024_25;
  final String season;

  const Crop({
    required this.name,
    required this.variety,
    required this.msp2025_26,
    required this.costOfProduction,
    required this.marginOverCost,
    required this.increaseFrom2024_25,
    required this.season,
  });

  // Factory constructor to parse JSON map into a Crop object.
  // Handles both English and Hindi keys correctly.
  factory Crop.fromJson(Map<String, dynamic> json, bool isEnglish) {
    // Helper to format values consistently and handle nulls.
    String getValue(String key, {String prefix = '', String suffix = ''}) {
      return '$prefix${json[key]?.toString() ?? 'N/A'}$suffix';
    }

    return Crop(
      name: getValue(isEnglish ? 'crop' : 'फसल'),
      variety: getValue(isEnglish ? 'variety' : 'किस्म'),
      msp2025_26: getValue(isEnglish ? 'msp_2025_26' : 'एमएसपी_2025_26', prefix: '₹'),
      costOfProduction: getValue(isEnglish ? 'cost_of_production' : 'उत्पादन_लागत', prefix: '₹'),
      marginOverCost: getValue(isEnglish ? 'margin_over_cost_percent' : 'लागत_पर_मुनाफा_प्रतिशत', suffix: '%'),
      increaseFrom2024_25: getValue(isEnglish ? 'increase_from_2024_25' : '2024_25_से_वृद्धि', prefix: '₹'),
      season: getValue(isEnglish ? 'season' : 'मौसम'),
    );
  }
}

class MspScreen extends StatefulWidget {
  final String selectedLanguage;
  const MspScreen({super.key, required this.selectedLanguage});

  @override
  State<MspScreen> createState() => _MspScreenState();
}

class _MspScreenState extends State<MspScreen> {
  List<Crop> _allCrops = [];
  List<Crop> _displayedCrops = [];
  final TextEditingController _searchController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  // Manual mapping for transliterations and common aliases to improve search.
  final Map<String, List<String>> _cropAliases = {
    'धान': ['dhan', 'chawal', 'paddy'],
    'गेहूं': ['gehun', 'wheat'],
    'ज्वार': ['jowar', 'sorghum'],
    'बाजरा': ['bajra', 'pearl millet'],
    'मक्का': ['makka', 'maize', 'corn'],
    'तूर/अरहर': ['tur', 'arhar', 'pigeon pea'],
    'मूंग': ['moong', 'mung'],
    'उड़द': ['urad'],
    'मूंगफली': ['moongfali', 'groundnut', 'peanut'],
    'सोयाबीन': ['soyabean'],
    'कपास': ['kapas', 'cotton'],
    'चना': ['chana', 'gram', 'chickpea'],
  };

  @override
  void initState() {
    super.initState();
    _loadMspData();
    _initSpeech();
  }

  // Loads and decodes the MSP data from the local JSON asset.
  Future<void> _loadMspData() async {
    final String response = await rootBundle.loadString('assets/msp.json');
    final data = await json.decode(response);
    bool isEnglish = widget.selectedLanguage == 'English';
    // Uses the corrected top-level keys from the updated JSON.
    final key = isEnglish ? 'msp_en' : 'msp_hi';

    if (mounted) {
      setState(() {
        _allCrops = (data[key] as List).map((cropJson) => Crop.fromJson(cropJson, isEnglish)).toList();
        _displayedCrops = _allCrops;
      });
    }
  }

  // Initializes the speech-to-text engine.
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (mounted) setState(() {});
  }

  // Starts listening for voice input, specifying the correct language.
  void _startListening() async {
    String localeId = widget.selectedLanguage == 'English' ? 'en_US' : 'hi_IN';

    await _speechToText.listen(
      onResult: (result) {
        _searchController.text = result.recognizedWords;
        _filterCrops(result.recognizedWords);
      },
      // Ensures voice input in Hindi is recognized in Devanagari script.
      localeId: localeId,
    );
    setState(() => _isListening = true);
  }

  // Stops the voice input listener.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  // Filters the crop list based on a search query.
  // This enhanced version checks the crop name, variety, and a list of aliases.
  void _filterCrops(String query) {
    if (query.isEmpty) {
      setState(() => _displayedCrops = _allCrops);
      return;
    }

    final lowerCaseQuery = query.toLowerCase();

    setState(() {
      _displayedCrops = _allCrops.where((crop) {
        // 1. Check the crop's actual name.
        final nameMatches = crop.name.toLowerCase().contains(lowerCaseQuery);
        // 2. Check the crop's variety.
        final varietyMatches = crop.variety.toLowerCase().contains(lowerCaseQuery);

        if (nameMatches || varietyMatches) {
          return true;
        }

        // 3. If the language is Hindi, check our alias map for transliterations.
        if (widget.selectedLanguage != 'English') {
          final aliases = _cropAliases[crop.name];
          if (aliases != null) {
            // Check if any alias in the list contains the search query.
            return aliases.any((alias) => alias.toLowerCase().contains(lowerCaseQuery));
          }
        }

        return false;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedLanguage == 'English' ? 'MSP Rates' : 'एमएसपी रेट'),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search text field
            TextField(
              controller: _searchController,
              onChanged: _filterCrops,
              decoration: InputDecoration(
                hintText: widget.selectedLanguage == 'English' ? 'Search Crop...' : 'फसल खोजें...',
                prefixIcon: Icon(Icons.search, color: Colors.green[800]),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic_off : Icons.mic,
                    color: Colors.green[800],
                  ),
                  onPressed: _speechEnabled ? (_isListening ? _stopListening : _startListening) : null,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green.shade600, width: 2),
                ),
                filled: true,
                fillColor: Colors.green.shade50,
              ),
            ),
            const SizedBox(height: 20),
            // List of crops
            Expanded(
              child: _allCrops.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _displayedCrops.isEmpty
                      ? Center(child: Text(widget.selectedLanguage == 'English' ? 'No crops found' : 'कोई फसल नहीं मिली'))
                      : ListView.builder(
                          itemCount: _displayedCrops.length,
                          itemBuilder: (context, index) {
                            final crop = _displayedCrops[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              color: Colors.green.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${crop.name} (${crop.variety})',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade900,
                                      ),
                                    ),
                                    _buildInfoRow(widget.selectedLanguage == 'English' ? 'Season' : 'मौसम', crop.season),
                                    Divider(
                                      height: 24,
                                      color: Colors.green.shade200,
                                    ),
                                    _buildInfoRow(widget.selectedLanguage == 'English' ? 'MSP (2025-26)' : 'एमएसपी (2025-26)', crop.msp2025_26),
                                    _buildInfoRow(widget.selectedLanguage == 'English' ? 'Cost of Production' : 'उत्पादन लागत', crop.costOfProduction),
                                    _buildInfoRow(widget.selectedLanguage == 'English' ? 'Margin Over Cost' : 'लागत पर मार्जिन', crop.marginOverCost),
                                    _buildInfoRow(widget.selectedLanguage == 'English' ? 'Increase from 2024-25' : '2024-25 से वृद्धि', crop.increaseFrom2024_25),
                                  ],
                                ),
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

  // Helper widget to build a labeled row of information.
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}