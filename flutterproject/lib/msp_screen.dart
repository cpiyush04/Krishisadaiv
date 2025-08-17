import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Crop {
  final String name;
  final String variety;
  final String msp2025_26;
  final String costOfProduction;
  final String marginOverCost;
  final String increaseFrom2024_25;
  final String mspIn2013_14;
  final String increaseFrom2013_14;

  const Crop({
    required this.name,
    required this.variety,
    required this.msp2025_26,
    required this.costOfProduction,
    required this.marginOverCost,
    required this.increaseFrom2024_25,
    required this.mspIn2013_14,
    required this.increaseFrom2013_14,
  });

  factory Crop.fromJson(Map<String, dynamic> json, bool isEnglish) {
    // Helper to format values consistently
    String getValue(String key, {String prefix = '', String suffix = ''}) {
      return '$prefix${json[key]?.toString() ?? 'N/A'}$suffix';
    }

    return Crop(
      name: getValue(isEnglish ? 'crop' : 'fasal'),
      variety: getValue(isEnglish ? 'variety' : 'kism'),
      msp2025_26: getValue(isEnglish ? 'msp_2025_26' : 'msp_2025_26', prefix: '₹'),
      costOfProduction: getValue(isEnglish ? 'cost_of_production' : 'utpadan_lagat', prefix: '₹'),
      marginOverCost: getValue(isEnglish ? 'margin_over_cost_percent' : 'lagat_par_margin_pratishat', suffix: '%'),
      increaseFrom2024_25: getValue(isEnglish ? 'increase_from_2024_25' : '2024_25_se_vriddhi', prefix: '₹'),
      mspIn2013_14: getValue(isEnglish ? 'msp_in_2013_14' : 'msp_2013_14_mein', prefix: '₹'),
      increaseFrom2013_14: getValue(isEnglish ? 'increase_from_2013_14_percent' : '2013_14_se_vriddhi_pratishat', suffix: '%'),
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

  @override
  void initState() {
    super.initState();
    _loadMspData();
    _initSpeech();
  }

  Future<void> _loadMspData() async {
    final String response = await rootBundle.loadString('assets/msp.json');
    final data = await json.decode(response);
    bool isEnglish = widget.selectedLanguage == 'English';
    final key = isEnglish ? 'kharif_msp_2025_26_english' : 'kharif_msp_2025_26_hindi';

    if (mounted) {
      setState(() {
        _allCrops = (data[key] as List).map((cropJson) => Crop.fromJson(cropJson, isEnglish)).toList();
        _displayedCrops = _allCrops;
      });
    }
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (mounted) setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: (result) {
      _searchController.text = result.recognizedWords;
      _filterCrops(result.recognizedWords);
    });
    setState(() => _isListening = true);
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _filterCrops(String query) {
    if (query.isEmpty) {
      setState(() => _displayedCrops = _allCrops);
      return;
    }
    setState(() {
      _displayedCrops = _allCrops.where((crop) => crop.name.toLowerCase().contains(query.toLowerCase())).toList();
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
            // --- UPDATED TEXTFIELD ---
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
            Expanded(
              child: _allCrops.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _displayedCrops.isEmpty
                      ? Center(child: Text(widget.selectedLanguage == 'English' ? 'No crops found' : 'कोई फसल नहीं मिली'))
                      : ListView.builder(
                          itemCount: _displayedCrops.length,
                          itemBuilder: (context, index) {
                            final crop = _displayedCrops[index];
                            // --- UPDATED CARD ---
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
                                    Divider(
                                      height: 24,
                                      color: Colors.green.shade200,
                                    ),
                                    _buildInfoRow(widget.selectedLanguage == 'English' ? 'MSP (2025-26)' : 'एमएसपी (2025-26)', crop.msp2025_26),
                                    _buildInfoRow(widget.selectedLanguage == 'English' ? 'Cost of Production' : 'उत्पादन लागत', crop.costOfProduction),
                                    _buildInfoRow(widget.selectedLanguage == 'English' ? 'Margin Over Cost' : 'लागत पर मार्जिन', crop.marginOverCost),
                                    const SizedBox(height: 10),
                                    _buildInfoRow(widget.selectedLanguage == 'English' ? 'Increase from 2024-25' : '2024-25 से वृद्धि', crop.increaseFrom2024_25),
                                    _buildInfoRow(widget.selectedLanguage == 'English' ? 'MSP in 2013-14' : '2013-14 में एमएसपी', crop.mspIn2013_14),
                                    _buildInfoRow(widget.selectedLanguage == 'English' ? '% Increase from 2013-14' : '2013-14 से % वृद्धि', crop.increaseFrom2013_14),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])), // Slightly darker grey for better contrast
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}