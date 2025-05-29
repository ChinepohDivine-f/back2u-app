import 'dart:io';
import 'package:back2u/views/report/contact.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:back2u/models/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportForm extends StatefulWidget {
  final Report report;

  const ReportForm({super.key, required this.report});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _ownerNameController;
  late TextEditingController _documentNameController;
  late TextEditingController _rewardAmountController;
  late TextEditingController _notesController;

  String? _selectedCategory;
  String? _selectedSubcategory;
  DateTime? _incidentDate;
  String? _selectedLocation;
  String? _selectedSubLocation;
  List<XFile> _selectedLocalImages = [];
  bool _addReward = false;

  final List<String> _categories = ['Legal', 'Identification', 'Education Documents', 'Electronics', 'Keys', 'Bags', 'Other'];
  final Map<String, List<String>> _subcategories = {
    'Legal': ['Bank statement', 'Land Document', 'Deed'],
    'Identification': ['National ID', 'School ID', 'Passport', 'Driving License', 'Voter ID'],
    'Education Documents': ['Certificate', 'Transcript', 'Diploma'],
    'Electronics': ['Phone', 'Laptop', 'Tablet', 'Headphones'],
    'Keys': ['Car Keys', 'House Keys', 'Office Keys'],
    'Bags': ['Backpack', 'Handbag', 'Wallet'],
    'Other': ['Umbrella', 'Jewelry', 'Watch'],
  };
  final List<String> _locations = ['Buea', 'Limbe', 'Kumba', 'Douala', 'Yaounde'];
  final Map<String, List<String>> _subLocations = {
    'Buea': ['Molyko', 'Great Soppo', 'Mile 17', 'Mile 4', 'UB'],
    'Limbe': ['Down Beach', 'Mile 1', 'Mile 2', 'Mile 4', 'Bonadikombo'],
    'Kumba': ['Kumba Town', 'Mabanda', 'Kosala'],
    'Douala': ['Bonanjo', 'Akwa', 'Bali', 'Japoma'],
    'Yaounde': ['Ngoa-Ekelle', 'Mokolo', 'Mfandena'],
  };

  @override
  void initState() {
    super.initState();
    _ownerNameController = TextEditingController(text: widget.report.ownerName);
    _documentNameController = TextEditingController(text: widget.report.documentName);
    _rewardAmountController = TextEditingController(text: widget.report.reward == '0' ? '' : widget.report.reward);
    _notesController = TextEditingController(text: widget.report.notes);

    _selectedCategory = widget.report.category.isNotEmpty ? widget.report.category : null;
    _selectedSubcategory = widget.report.subcategory.isNotEmpty ? widget.report.subcategory : null;
    // Ensure _incidentDate is valid before assigning, otherwise default to null
    _incidentDate = widget.report.reportedDate.toDate().year > 2000 ? widget.report.reportedDate.toDate() : null;
    _selectedLocation = widget.report.locationLost.isNotEmpty ? widget.report.locationLost : null;
    _selectedSubLocation = widget.report.subLocationLost.isNotEmpty ? widget.report.subLocationLost : null;

    _addReward = widget.report.reward.isNotEmpty && widget.report.reward != '0';
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _documentNameController.dispose();
    _rewardAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _incidentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
        // Limit to max 2 images
        if ((_selectedLocalImages.length + images.length) > 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only upload a maximum of 2 images.')),
          );
          // Add only up to the limit
          setState(() {
            _selectedLocalImages.addAll(images.take(2 - _selectedLocalImages.length));
          });
        } else {
          setState(() {
            _selectedLocalImages.addAll(images);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedLocalImages.removeAt(index);
    });
  }

  void _showNotesDialog(BuildContext context) {
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
                'Additional Notes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
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

  void _navigateToContactPage() {
    // Manually trigger validation for the date picker if it's not handled by DropdownButtonFormField
    if (_incidentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the incident date.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Image validation for "Found" reports
    if (widget.report.type == 'Found' && _selectedLocalImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one image is required for Found reports.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final updatedReport = widget.report.copyWith(
        ownerName: _ownerNameController.text,
        documentName: _documentNameController.text,
        category: _selectedCategory!,
        subcategory: _selectedSubcategory!,
        reportedDate: Timestamp.fromDate(_incidentDate!),
        locationLost: _selectedLocation!,
        subLocationLost: _selectedSubLocation ?? '',
        notes: _notesController.text,
        reward: _addReward ? _rewardAmountController.text : '0',
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ContactPage(report: updatedReport, localImageFiles: _selectedLocalImages)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields and fix errors.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _ownerNameController.clear();
      _documentNameController.clear();
      _rewardAmountController.clear();
      _notesController.clear();
      _selectedCategory = null;
      _selectedSubcategory = null;
      _incidentDate = null;
      _selectedLocation = null;
      _selectedSubLocation = null;
      _selectedLocalImages = [];
      _addReward = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.report.type} Report - Details'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: colorScheme.primary,
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
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(15.0),
            physics: const BouncingScrollPhysics(),
            children: <Widget>[
              // Owner's Name Field (Required)
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(
                  labelText: "Owner's Name (or Name on Document)*",
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the owner\'s name or name on document';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Document Name/Item Name Field (Required)
              // TextFormField(
              //   controller: _documentNameController,
              //   decoration: const InputDecoration(
              //     labelText: "Document Name/Item Name (e.g., 'National ID', 'Blue Backpack')*",
              //     border: OutlineInputBorder(),
              //   ),
              //   textInputAction: TextInputAction.next,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter the document/item name';
              //     }
              //     return null;
              //   },
              // ),
              // const SizedBox(height: 16),

              // Category Dropdown (Required)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category*',
                  border: OutlineInputBorder(),
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
                    _selectedSubcategory = null;
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

              // Subcategory Dropdown (Required)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Subcategory*',
                  border: OutlineInputBorder(),
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
                  if (value == null || value.isEmpty) {
                    return 'Please select a subcategory';
                  }
                  return null;
                },
                disabledHint: const Text('Select a category first'),
              ),
              const SizedBox(height: 16),

              // Incident Date Picker (Required)
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Incident Date*',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                    errorText: _incidentDate == null && (_formKey.currentState?.validate() ?? false)
                        ? 'Please select the incident date'
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        _incidentDate != null
                            ? DateFormat('MMM dd, yyyy').format(_incidentDate!)
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
              const SizedBox(height: 16),

              // Location Dropdown (Required)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Main Location*',
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
                    _selectedSubLocation = null;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a main location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sub-Location Dropdown (Required)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Sub-Location*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                value: _selectedSubLocation,
                items: (_selectedLocation != null && _subLocations.containsKey(_selectedLocation))
                    ? _subLocations[_selectedLocation]!.map((sublocation) {
                        return DropdownMenuItem<String>(
                          value: sublocation,
                          child: Text(sublocation),
                        );
                      }).toList()
                    : [],
                onChanged: _selectedLocation != null && _subLocations.containsKey(_selectedLocation)
                    ? (value) {
                        setState(() {
                          _selectedSubLocation = value;
                        });
                      }
                    : null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a sub-location';
                  }
                  return null;
                },
                disabledHint: const Text('Select a main location first'),
              ),
              const SizedBox(height: 24),

              // Image Picker Section (no Card)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Images (${widget.report.type == 'Found' ? 'Required, ' : ''}Max 2)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _selectedLocalImages.length < 2 ? _pickImages : null, // Disable if 2 images already
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(_selectedLocalImages.length < 2 ? 'Add Image' : 'Max 2 Images Uploaded'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                    if (widget.report.type == 'Found' && _selectedLocalImages.isEmpty && (_formKey.currentState?.validate() ?? false))
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'At least one image is required for Found reports.',
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                        ),
                      ),
                    if (_selectedLocalImages.isNotEmpty) const SizedBox(height: 16),
                    if (_selectedLocalImages.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedLocalImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8.0),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_selectedLocalImages[index].path),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 18, color: Colors.white),
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
              const SizedBox(height: 16),

              // Additional Notes Button
              ElevatedButton.icon(
                onPressed: () => _showNotesDialog(context),
                icon: const Icon(Icons.notes),
                label: Text(
                  _notesController.text.isNotEmpty
                      ? 'Edit Additional Notes'
                      : 'Add Additional Notes (Optional)',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: colorScheme.onSurface,
                ),
              ),
              if (_notesController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Text(
                    'Notes added: "${_notesController.text.length > 50 ? _notesController.text.substring(0, 47) + '...' : _notesController.text}"',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Reward Section (no Card)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
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
                          activeColor: colorScheme.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Offer Reward?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (_addReward) const SizedBox(height: 12),
                    if (_addReward)
                      TextFormField(
                        controller: _rewardAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Reward Amount (XAF)',
                          border: const OutlineInputBorder(),
                          prefixText: 'XAF ',
                          filled: true,
                          fillColor: colorScheme.surface,
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
              const SizedBox(height: 24),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _navigateToContactPage,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('NEXT: Contact Information'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
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