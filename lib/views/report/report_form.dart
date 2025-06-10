// lib/views/report/report_form.dart
import 'dart:io';
import 'package:back2u/views/report/contact.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:back2u/models/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart'; // For creating dummy XFile for existing images

// Import your category and location models
import 'package:back2u/models/category_model.dart';
import 'package:back2u/models/location_model.dart';

// Import the new data fetching service
import 'package:back2u/services/form_data_fetch_service.dart';

class ReportForm extends StatefulWidget {
  final Report report; // The report to be edited (or a new empty report)

  const ReportForm({super.key, required this.report});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController? _ownerNameController;
  late TextEditingController? _rewardAmountController;
  late TextEditingController? _notesController;

  String? _selectedCategoryName;
  String? _selectedSubcategoryName;
  DateTime? _incidentDate;
  String? _selectedLocationName;
  String? _selectedSubLocationName;

  // For managing images:
  // List to hold NEWLY picked images (XFile objects)
  List<XFile> _newlySelectedLocalImages = [];
  // List to hold EXISTING image URLs from the report
  List<String> _existingImageUrls = [];
  // Set to track which EXISTING images are marked for removal
  Set<String> _imagesToDelete = {};

  bool _addReward = false;

  final DataFetchService _dataFetchService = DataFetchService();

  List<Category> _allCategories = [];
  List<Location> _allLocations = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _ownerNameController = TextEditingController(text: widget.report.ownerName);
    _rewardAmountController = TextEditingController(text: widget.report.reward == '0' ? '' : widget.report.reward);
    _notesController = TextEditingController(text: widget.report.notes);

    // Initialize dropdowns with existing report data.
    // These will be properly set after _fetchFormData completes and validates them.
    _selectedCategoryName = widget.report.category.isNotEmpty ? widget.report.category : null;
    _selectedSubcategoryName = widget.report.subcategory.isNotEmpty ? widget.report.subcategory : null;
    _selectedLocationName = widget.report.locationLost.isNotEmpty ? widget.report.locationLost : null;
    _selectedSubLocationName = widget.report.subLocationLost.isNotEmpty ? widget.report.subLocationLost : null;

    _incidentDate = widget.report.reportedDate.toDate().year > 2000 ? widget.report.reportedDate.toDate() : null;
    _addReward = widget.report.reward.isNotEmpty && widget.report.reward != '0';

    // Initialize existing image URLs
    _existingImageUrls = List.from(widget.report.images);

    _fetchFormData();
  }

  Future<void> _fetchFormData() async {
    setState(() {
      _isLoadingData = true;
    });
    try {
      final categories = await _dataFetchService.fetchCategories();
      final locations = await _dataFetchService.fetchLocations();

      setState(() {
        _allCategories = categories;
        _allLocations = locations;

        // After fetching, attempt to set the initial values based on widget.report
        // Only set if the value exists in the fetched unique list.
        if (widget.report.category.isNotEmpty &&
            _allCategories.any((cat) => cat.nameEn == widget.report.category)) {
          _selectedCategoryName = widget.report.category;
        } else {
          _selectedCategoryName = null;
        }

        if (_selectedCategoryName != null &&
            widget.report.subcategory.isNotEmpty) {
          final selectedCategory = _allCategories.firstWhere(
            (cat) => cat.nameEn == _selectedCategoryName,
            orElse: () => Category(categoryId: '', createdAt: Timestamp.now(), nameEn: '', nameFr: '', subcategories: [], updatedAt: Timestamp.now()),
          );
          if (selectedCategory.subcategories.any((sub) => sub.nameEn == widget.report.subcategory)) {
            _selectedSubcategoryName = widget.report.subcategory;
          } else {
            _selectedSubcategoryName = null;
          }
        } else {
          _selectedSubcategoryName = null;
        }

        if (widget.report.locationLost.isNotEmpty &&
            _allLocations.any((loc) => loc.nameEn == widget.report.locationLost)) {
          _selectedLocationName = widget.report.locationLost;
        } else {
          _selectedLocationName = null;
        }

        if (_selectedLocationName != null &&
            widget.report.subLocationLost.isNotEmpty) {
          final selectedLocation = _allLocations.firstWhere(
            (loc) => loc.nameEn == _selectedLocationName,
            orElse: () => Location(createdAt: Timestamp.now(), locationId: '', nameEn: '', nameFr: '', sublocations: [], updatedAt: Timestamp.now()),
          );
          if (selectedLocation.sublocations.any((sub) => sub.nameEn == widget.report.subLocationLost)) {
            _selectedSubLocationName = widget.report.subLocationLost;
          } else {
            _selectedSubLocationName = null;
          }
        } else {
          _selectedSubLocationName = null;
        }

        _isLoadingData = false;
      });
    } catch (e) {
      print('Failed to load form data: $e');
      setState(() {
        _isLoadingData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load categories and locations. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ownerNameController!.dispose();
    _rewardAmountController!.dispose();
    _notesController!.dispose();
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
        final currentTotalImages = _newlySelectedLocalImages.length +
            _existingImageUrls.where((url) => !_imagesToDelete.contains(url)).length;

        if ((currentTotalImages + images.length) > 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only upload a maximum of 2 images total.')),
          );
          // Add only enough images to reach the limit of 2
          setState(() {
            _newlySelectedLocalImages.addAll(images.take(2 - currentTotalImages));
          });
        } else {
          setState(() {
            _newlySelectedLocalImages.addAll(images);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newlySelectedLocalImages.removeAt(index);
    });
  }

  void _markExistingImageForRemoval(String imageUrl) {
    setState(() {
      if (_imagesToDelete.contains(imageUrl)) {
        _imagesToDelete.remove(imageUrl); // Unmark
      } else {
        _imagesToDelete.add(imageUrl); // Mark for removal
      }
    });
  }

  void _navigateToContactPage() {
    // Validate incident date manually since it's not a TextFormField
    if (_incidentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the incident date.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate images for 'Found' reports
    final totalImagesAfterRemoval = _newlySelectedLocalImages.length +
        _existingImageUrls.where((url) => !_imagesToDelete.contains(url)).length;

    if (widget.report.type == 'Found' && totalImagesAfterRemoval == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one image is required for Found reports.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Create a *copy* of the report with updated details
      final updatedReport = widget.report.copyWith(
        ownerName: _ownerNameController!.text.trim(),
        category: _selectedCategoryName!,
        subcategory: _selectedSubcategoryName!,
        reportedDate: Timestamp.fromDate(_incidentDate!),
        locationLost: _selectedLocationName!,
        subLocationLost: _selectedSubLocationName ?? '',
        notes: _notesController!.text.trim(),
        reward: _addReward ? _rewardAmountController!.text.trim() : '0',
        // Existing images will be filtered during the final upload/update process
        // No need to pass them here; the ContactPage will handle them.
      );

      // Pass the updated report, newly selected images, and images to delete
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactPage(
            report: updatedReport,
            localImageFiles: _newlySelectedLocalImages,
            existingImageUrls: _existingImageUrls,
            imagesToDelete: _imagesToDelete,
            isEditing: true, // Indicate that this is an edit flow
          ),
        ),
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
    // Reset controllers to their initial values (from widget.report)
    _ownerNameController!.text = widget.report.ownerName!;
    _rewardAmountController!.text = widget.report.reward == '0' ? '' : widget.report.reward;
    _notesController!.text = widget.report.notes;

    setState(() {
      // Reset dropdown selections to initial values or null if not valid
      _selectedCategoryName = widget.report.category.isNotEmpty && _allCategories.any((cat) => cat.nameEn == widget.report.category) ? widget.report.category : null;
      _selectedSubcategoryName = widget.report.subcategory.isNotEmpty && (_selectedCategoryName != null && _allCategories.firstWhere((cat) => cat.nameEn == _selectedCategoryName, orElse: () => Category(categoryId: '', createdAt: Timestamp.now(), nameEn: '', nameFr: '', subcategories: [], updatedAt: Timestamp.now())).subcategories.any((sub) => sub.nameEn == widget.report.subcategory)) ? widget.report.subcategory : null;
      _selectedLocationName = widget.report.locationLost.isNotEmpty && _allLocations.any((loc) => loc.nameEn == widget.report.locationLost) ? widget.report.locationLost : null;
      _selectedSubLocationName = widget.report.subLocationLost.isNotEmpty && (_selectedLocationName != null && _allLocations.firstWhere((loc) => loc.nameEn == _selectedLocationName, orElse: () => Location(createdAt: Timestamp.now(), locationId: '', nameEn: '', nameFr: '', sublocations: [], updatedAt: Timestamp.now())).sublocations.any((sub) => sub.nameEn == widget.report.subLocationLost)) ? widget.report.subLocationLost : null;

      _incidentDate = widget.report.reportedDate.toDate().year > 2000 ? widget.report.reportedDate.toDate() : null;
      _addReward = widget.report.reward.isNotEmpty && widget.report.reward != '0';

      _newlySelectedLocalImages = []; // Clear new images
      _existingImageUrls = List.from(widget.report.images); // Reset existing images
      _imagesToDelete = {}; // Clear images marked for deletion
    });
    // No need to _fetchFormData again unless data itself might have changed on backend
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.report.type.toUpperCase()} Report - Details'),
          centerTitle: true,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final int totalImages = _newlySelectedLocalImages.length +
        _existingImageUrls.where((url) => !_imagesToDelete.contains(url)).length;
    final int remainingSlots = 2 - totalImages;


    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.report.type.toUpperCase()} Report - Details'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetForm,
            tooltip: 'Reset Form to Original',
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
                  labelText: "Owner's Name (or Name on Item)*",
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the owner\'s name or name on the item';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown (Required)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category*',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategoryName,
                items: _allCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.nameEn,
                    child: Text(category.nameEn),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryName = value;
                    _selectedSubcategoryName = null; // Reset subcategory when category changes
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
                value: _selectedSubcategoryName,
                // Filter subcategories based on the selected category
                items: _selectedCategoryName != null
                    ? _allCategories
                        .firstWhere(
                          (cat) => cat.nameEn == _selectedCategoryName!,
                          orElse: () => Category(
                            categoryId: '', createdAt: Timestamp.now(), nameEn: '', nameFr: '', subcategories: [], updatedAt: Timestamp.now()
                          ),
                        )
                        .subcategories
                        .map((subcat) {
                          return DropdownMenuItem<String>(
                            value: subcat.nameEn,
                            child: Text(subcat.nameEn),
                          );
                        }).toList()
                    : [],
                onChanged: _selectedCategoryName != null
                    ? (value) {
                        setState(() {
                          _selectedSubcategoryName = value;
                        });
                      }
                    : null, // Disable if no category selected
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
                    // Only show error if incidentDate is null AND form has been validated (tried to submit)
                    errorText: (_incidentDate == null && (_formKey.currentState?.validate() ?? false))
                        ? 'Please select the incident date'
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        _incidentDate != null
                            ? DateFormat('MMM dd, yyyy').format(_incidentDate!) // Corrected date format
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
                value: _selectedLocationName,
                items: _allLocations.map((location) {
                  return DropdownMenuItem<String>(
                    value: location.nameEn,
                    child: Text(location.nameEn),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLocationName = value;
                    _selectedSubLocationName = null; // Reset sublocation
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
                value: _selectedSubLocationName,
                // Filter sublocations based on the selected location
                items: _selectedLocationName != null
                    ? _allLocations
                        .firstWhere(
                          (loc) => loc.nameEn == _selectedLocationName!,
                          orElse: () => Location(
                            createdAt: Timestamp.now(), locationId: '', nameEn: '', nameFr: '', sublocations: [], updatedAt: Timestamp.now()
                          ),
                        )
                        .sublocations
                        .map((subloc) {
                          return DropdownMenuItem<String>(
                            value: subloc.nameEn,
                            child: Text(subloc.nameEn),
                          );
                        }).toList()
                    : [],
                onChanged: _selectedLocationName != null
                    ? (value) {
                        setState(() {
                          _selectedSubLocationName = value;
                        });
                      }
                    : null, // Disable if no main location selected
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a sub-location';
                  }
                  return null;
                },
                disabledHint: const Text('Select a main location first'),
              ),
              const SizedBox(height: 24),

              // Image Picker Section
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
                      onPressed: totalImages < 2 ? _pickImages : null,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(totalImages < 2 ? 'Add Image (${remainingSlots} left)' : 'Max 2 Images Uploaded'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                    if (widget.report.type == 'Found' && totalImages == 0 && (_formKey.currentState?.validate() ?? false))
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'At least one image is required for Found reports.',
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                        ),
                      ),
                    if (_existingImageUrls.isNotEmpty || _newlySelectedLocalImages.isNotEmpty) const SizedBox(height: 16),
                    if (_existingImageUrls.isNotEmpty || _newlySelectedLocalImages.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _existingImageUrls.length + _newlySelectedLocalImages.length,
                          itemBuilder: (context, index) {
                            if (index < _existingImageUrls.length) {
                              // Existing image
                              final imageUrl = _existingImageUrls[index];
                              final isMarkedForDeletion = _imagesToDelete.contains(imageUrl);
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 8.0),
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                      color: isMarkedForDeletion ? Colors.grey[300] : null,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: ColorFiltered(
                                        colorFilter: isMarkedForDeletion
                                            ? const ColorFilter.mode(Colors.black38, BlendMode.darken)
                                            : ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Center(child: Icon(Icons.broken_image)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () => _markExistingImageForRemoval(imageUrl),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: isMarkedForDeletion ? Colors.green : Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                            isMarkedForDeletion ? Icons.undo : Icons.close,
                                            size: 18,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  if (isMarkedForDeletion)
                                    const Positioned.fill(
                                      child: Center(
                                        child: Icon(
                                          Icons.delete_forever,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            } else {
                              // Newly selected image
                              final newImageIndex = index - _existingImageUrls.length;
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
                                        File(_newlySelectedLocalImages[newImageIndex].path),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () => _removeNewImage(newImageIndex),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, size: 18, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Additional Notes Text Field (Directly integrated)
              TextFormField(
                controller: _notesController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter any extra information here...',
                  alignLabelWithHint: true,
                ),
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 16),

              // Reward Section (Only for 'lost' reports)
              if (widget.report.type == 'Lost')
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
                                  _rewardAmountController!.clear();
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
                )
              else
                const SizedBox(), // Render nothing if not a 'Lost' report

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