import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Data model to hold all information for a single fertilizer
class Fertilizer {
  final String name;
  final String activeComponent;
  final String primaryFunction;
  final String suitableCrops;
  final String applicationTiming;
  final String governmentScheme;

  const Fertilizer({
    required this.name,
    required this.activeComponent,
    required this.primaryFunction,
    required this.suitableCrops,
    required this.applicationTiming,
    required this.governmentScheme,
  });

  factory Fertilizer.fromJson(Map<String, dynamic> json, bool isEnglish) {
    return Fertilizer(
      name: json[isEnglish ? 'fertilizer_name_type' : 'urvarak_ka_naam_prakar'] ?? 'N/A',
      activeComponent: json[isEnglish ? 'active_component' : 'sakriya_ghatak'] ?? 'N/A',
      primaryFunction: json[isEnglish ? 'primary_function' : 'mukhya_karya'] ?? 'N/A',
      suitableCrops: json[isEnglish ? 'suitable_crops' : 'upayukt_faslein'] ?? 'N/A',
      applicationTiming: json[isEnglish ? 'application_timing_method' : 'upyog_ka_samay_vidhi'] ?? 'N/A',
      governmentScheme: json[isEnglish ? 'government_incentive_scheme' : 'sarkari_protsahan_yojana'] ?? 'N/A',
    );
  }
}

class FertilizerScreen extends StatefulWidget {
  final String selectedLanguage;
  const FertilizerScreen({super.key, required this.selectedLanguage});

  @override
  State<FertilizerScreen> createState() => _FertilizerScreenState();
}

class _FertilizerScreenState extends State<FertilizerScreen> {
  List<Fertilizer> _chemicalFertilizers = [];
  List<Fertilizer> _bioFertilizers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFertilizerData();
  }

  Future<void> _loadFertilizerData() async {
    try {
      final String response = await rootBundle.loadString('assets/fertilizers.json');
      final data = json.decode(response);
      bool isEnglish = widget.selectedLanguage == 'English';

      final chemicalKey = isEnglish ? 'chemical_fertilizers' : 'rasayanik_urvarak';
      final bioKey = isEnglish ? 'biological_fertilizers' : 'jaivik_urvarak';

      final chemicalData = data[chemicalKey] as List<dynamic>? ?? [];
      final bioData = data[bioKey] as List<dynamic>? ?? [];

      if (mounted) {
        setState(() {
          _chemicalFertilizers = chemicalData
              .map((item) => Fertilizer.fromJson(item, isEnglish))
              .toList();
          _bioFertilizers = bioData
              .map((item) => Fertilizer.fromJson(item, isEnglish))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading fertilizer data: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEnglish = widget.selectedLanguage == 'English';
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEnglish ? 'About Fertilizers' : 'उर्वरकों के बारे में जानें'),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: isEnglish ? 'Chemical' : 'रासायनिक'),
              Tab(text: isEnglish ? 'Bio' : 'जैव'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                : TabBarView(
                    children: [
                      _buildFertilizerList(_chemicalFertilizers),
                      _buildFertilizerList(_bioFertilizers),
                    ],
                  ),
      ),
    );
  }

  Widget _buildFertilizerList(List<Fertilizer> fertilizers) {
    bool isEnglish = widget.selectedLanguage == 'English';

    if (fertilizers.isEmpty) {
      return Center(
        child: Text(isEnglish ? 'No data available.' : 'कोई डेटा उपलब्ध नहीं है।'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: fertilizers.length,
      itemBuilder: (context, index) {
        final fertilizer = fertilizers[index];
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
                  fertilizer.name,
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
                _buildInfoRow(isEnglish ? 'Active Component' : 'सक्रिय घटक', fertilizer.activeComponent),
                _buildInfoRow(isEnglish ? 'Primary Function' : 'मुख्य कार्य', fertilizer.primaryFunction),
                _buildInfoRow(isEnglish ? 'Suitable Crops' : 'उपयुक्त फसलें', fertilizer.suitableCrops),
                _buildInfoRow(isEnglish ? 'Application' : 'आवेदन', fertilizer.applicationTiming),
                _buildInfoRow(isEnglish ? 'Govt. Scheme' : 'सरकारी योजना', fertilizer.governmentScheme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(color: Colors.grey[700]))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}