import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FaqsScreen extends StatefulWidget {
  final String selectedLanguage;
  const FaqsScreen({super.key, required this.selectedLanguage});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  List _faqs = [];

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    final String response = await rootBundle.loadString('assets/faqs.json');
    final data = await json.decode(response);
    final key = widget.selectedLanguage == 'English' ? 'faq_english' : 'faq_hindi';

    if (mounted) {
      setState(() {
        _faqs = data[key];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedLanguage == 'English' ? 'General FAQs' : 'सामान्य अक्सर पूछे जाने वाले प्रश्न'),
      ),
      body: _faqs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8.0), // Add padding to the whole list
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                // Each FAQ is a styled ExpansionTile
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ExpansionTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.green.shade50,
                    collapsedBackgroundColor: Colors.green.shade50,
                    textColor: Colors.green.shade900,
                    collapsedTextColor: Colors.green.shade900,
                    iconColor: Colors.green.shade900,
                    collapsedIconColor: Colors.green.shade900,
                    title: Text(
                      _faqs[index]['question'],
                      // The fontWeight has been removed from here
                    ),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                        child: Text(
                          _faqs[index]['answer'],
                          style: TextStyle(color: Colors.grey.shade800, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}