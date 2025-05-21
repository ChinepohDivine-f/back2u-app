import 'dart:io';
import 'package:back2u/views/report/contact.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ReportForm extends StatefulWidget {
  const ReportForm({super.key});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rewardAmountController = TextEditingController();
  final _detailsController = TextEditingController();
  
  String? _selectedCategory;
  String? _selectedSubcategory;
  DateTime? _incidentDate;
  String? _selectedLocation;
  List<XFile> _selectedImages = [];
  bool _addReward = false;

  // Dummy data for dropdowns
  final List<String> _categories = ['Legal', 'Identification', 'Education Documents'];
  final Map<String, List<String>> _subcategories = {
    'Legal': ['Bank statement', 'land document',],
    'Identification': ['National Id', 'School Id', 'Passport'],
    'Education Documents': ['Certificate', 'Transcript'],
  };
  final List<String> _locations = ['Buea', 'Limbe', 'Kumba', 'Douala', 'Yaounde'];

  @override
  void dispose() {
    _nameController.dispose();
    _rewardAmountController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _incidentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // Only allow dates up to current date
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null && pickedDate != _incidentDate) {
      setState(() {
        _incidentDate = pickedDate;
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? images = await picker.pickMultiImage();
      
      if (images != null && images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showAdditionalDetailsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Additional Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _detailsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter any extra information here...',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      // Gather all form data
      final reportData = {
        'name': _nameController.text,
        'category': _selectedCategory,
        'subcategory': _selectedSubcategory,
        'incidentDate': _incidentDate != null ? DateFormat('yyyy-MM-dd').format(_incidentDate!) : null,
        'location': _selectedLocation,
        'imageCount': _selectedImages.length,
        'additionalDetails': _detailsController.text,
        'hasReward': _addReward,
        'rewardAmount': _addReward ? _rewardAmountController.text : null,
      };

      // Log the report data (replace with your API call)
      debugPrint('Report data: $reportData');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // move to contact screen
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactPage()));


      // Reset form (optional)
      _resetForm();
    } else {
      // Show validation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _nameController.clear();
      _rewardAmountController.clear();
      _detailsController.clear();
      _selectedCategory = null;
      _selectedSubcategory = null;
      _incidentDate = null;
      _selectedLocation = null;
      _selectedImages = [];
      _addReward = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Lost document'),
         centerTitle: true,
        elevation: 1,
        backgroundColor: colorScheme.primary, // Use primary color from theme
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetForm,
            tooltip: 'Reset Form',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(15.0),
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Owner's name",
                  border: OutlineInputBorder(),
                  // prefixIcon: Icon(Icons.person_3),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Document category',
                  border: OutlineInputBorder(),
                  // prefixIcon: Icon(Icons.category_sharp),
                ),
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedSubcategory = null; // Reset subcategory when category changes
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Subcategory Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Subcategory',
                  border: OutlineInputBorder(),
                  // prefixIcon: Icon(Icons.subject),
                ),
                value: _selectedSubcategory,
                items: (_selectedCategory != null && _subcategories.containsKey(_selectedCategory))
                    ? _subcategories[_selectedCategory]!.map((subcategory) {
                        return DropdownMenuItem<String>(
                          value: subcategory,
                          child: Text(subcategory),
                        );
                      }).toList()
                    : [],
                onChanged: _selectedCategory != null && _subcategories.containsKey(_selectedCategory)
                    ? (value) {
                        setState(() {
                          _selectedSubcategory = value;
                        });
                      }
                    : null,
                validator: (value) {
                  if (_selectedCategory != null && (value == null || value.isEmpty)) {
                    return 'Please select a subcategory';
                  }
                  return null;
                },
                disabledHint: const Text('Select a category first'),
              ),
              const SizedBox(height: 16),

              // Incident Date Picker
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Incident Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        _incidentDate != null 
                            ? DateFormat('yyyy-MM-dd').format(_incidentDate!) 
                            : 'Select Date',
                        style: _incidentDate == null 
                            ? TextStyle(color: Colors.grey[600]) 
                            : null,
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              if (_incidentDate == null) 
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                  child: Text(
                    'Please select the incident date',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),

              // Location Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                value: _selectedLocation,
                items: _locations.map((location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Image Picker Section
              Container(
                // elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0,0,0,10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Images (Optional)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Images'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        ),
                      ),
                      if (_selectedImages.isNotEmpty) const SizedBox(height: 12),
                      if (_selectedImages.isNotEmpty)
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 8.0),
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(_selectedImages[index].path),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 13,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, size: 18, color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Additional Details Button
              ElevatedButton.icon(
                onPressed: () => _showAdditionalDetailsDialog(context),
                icon: const Icon(Icons.notes),
                label: Text(
                  _detailsController.text.isNotEmpty 
                      ? 'Edit Additional Details' 
                      : 'Add Additional Details',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              if (_detailsController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Text(
                    'Details added',
                    style: TextStyle(
                      // fontStyle: FontStyle.italic,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Reward Section
              Container(
                // elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0,0,0,10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Switch(
                            value: _addReward,
                            onChanged: (bool value) {
                              setState(() {
                                _addReward = value;
                                if (!value) {
                                  _rewardAmountController.clear();
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Offer Reward?',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      if (_addReward) const SizedBox(height: 12),
                      if (_addReward)
                        TextFormField(
                          controller: _rewardAmountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Reward Amount (Francs)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          validator: (value) {
                            if (_addReward) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the reward amount';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              if (double.parse(value) <= 0) {
                                return 'Amount must be greater than zero';
                              }
                            }
                            return null;
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                // height: 50,
                child: FilledButton(
                  onPressed: _submitReport,
                  // style: ElevatedButton.styleFrom(
                  //   foregroundColor: Colors.white,
                  //   backgroundColor: Theme.of(context).primaryColor,
                  //   textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  // ),
                  child: const Text('SUBMIT REPORT'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}