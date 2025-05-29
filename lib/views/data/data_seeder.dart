import 'package:flutter/material.dart';
import 'package:back2u/services/data_upload_service.dart';

class DataSeederPage extends StatefulWidget {
  const DataSeederPage({super.key});

  @override
  State<DataSeederPage> createState() => _DataSeederPageState();
}

class _DataSeederPageState extends State<DataSeederPage> {
  final DataUploadService _dataUploadService = DataUploadService();
  final List<String> _logs = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _dataUploadService.logs.listen((log) {
      setState(() {
        _logs.add(log);
      });
    });
  }

  @override
  void dispose() {
    _dataUploadService.dispose();
    super.dispose();
  }

  Future<void> _setDummyData() async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
      _logs.clear();
      _logs.add('Initiating dummy data upload...');
      _logs.add('-----------------------------------');
      _logs.add('This will upload:');
      _logs.add(' - App Information (Document: /Back2u/app_info)');
      _logs.add(' - Country Data for Cameroon (Document: /Back2u/countries/cameroon)'); // Updated description
      _logs.add(' - Cameroon Regions and their towns (Collection: /Back2u/countries/cameroon/data/locations)');
      _logs.add(' - Document Categories and their subcategories (Collection: /Back2u/countries/cameroon/data/categories)');
      _logs.add('Data will only be uploaded if it does not already exist.');
      _logs.add('-----------------------------------');
    });

    try {
      await _dataUploadService.uploadAllDummyData();
      setState(() {
        _logs.add('Dummy data upload process finished!');
      });
    } catch (e) {
      setState(() {
        _logs.add('An error occurred during upload: $e');
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Dummy Data for Firestore'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _setDummyData,
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(_isUploading ? 'Uploading Data...' : 'Set Dummy Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Upload Logs:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      _logs[index],
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: _logs[index].contains('Error')
                            ? Colors.red
                            : _logs[index].contains('Skipping')
                                ? Colors.orange
                                : Colors.black87,
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
}