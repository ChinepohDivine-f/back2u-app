import 'package:flutter/material.dart';
import 'package:back2u/services/report_search_service.dart'; // Import the service

class FilterBottomSheet extends StatefulWidget {
  final String? initialFilterType;
  final String? initialFilterCategory;
  final String? initialFilterSubCategory;
  final String? initialFilterLocation;
  final String? initialFilterSubLocation;
  final bool? initialFilterIsResolved;

  final List<String> reportTypes;
  final List<String> availableCategories;
  final List<String> availableLocations;

  // NEW: Pass the service instance for dynamic sub-list fetching
  final ReportSearchService searchService;


  // Callback to apply filters
  final void Function(
    String? type,
    String? category,
    String? subCategory,
    String? location,
    String? subLocation,
    bool? isResolved,
  ) onApplyFilters;

  const FilterBottomSheet({
    super.key,
    this.initialFilterType,
    this.initialFilterCategory,
    this.initialFilterSubCategory,
    this.initialFilterLocation,
    this.initialFilterSubLocation,
    this.initialFilterIsResolved,
    required this.reportTypes,
    required this.availableCategories,
    required this.availableLocations,
    required this.searchService, // NEW: Required service
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedType;
  String? _selectedCategory;
  String? _selectedSubCategory;
  String? _selectedLocation;
  String? _selectedSubLocation;
  bool? _selectedIsResolved;

  // NEW: Internal state for dynamically loaded subcategories and sublocations
  List<String> _currentSubCategories = [];
  List<String> _currentSubLocations = [];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialFilterType;
    _selectedCategory = widget.initialFilterCategory;
    _selectedSubCategory = widget.initialFilterSubCategory;
    _selectedLocation = widget.initialFilterLocation;
    _selectedSubLocation = widget.initialFilterSubLocation;
    _selectedIsResolved = widget.initialFilterIsResolved;

    // Initialize the current sub-lists based on initial values
    _updateSubCategories();
    _updateSubLocations();
  }

  // NEW: Helper to update subcategories based on _selectedCategory
  void _updateSubCategories() {
    setState(() {
      _currentSubCategories = _selectedCategory != null
          ? widget.searchService.getSubcategoriesForCategory(_selectedCategory!)
          : [];
      // Ensure the selected subcategory is still valid, otherwise reset it
      if (_selectedSubCategory != null && !_currentSubCategories.contains(_selectedSubCategory)) {
        _selectedSubCategory = null;
      }
    });
  }

  // NEW: Helper to update sublocations based on _selectedLocation
  void _updateSubLocations() {
    setState(() {
      _currentSubLocations = _selectedLocation != null
          ? widget.searchService.getSublocationsForLocation(_selectedLocation!)
          : [];
      // Ensure the selected sublocation is still valid, otherwise reset it
      if (_selectedSubLocation != null && !_currentSubLocations.contains(_selectedSubLocation)) {
        _selectedSubLocation = null;
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedCategory = null;
      _selectedSubCategory = null;
      _selectedLocation = null;
      _selectedSubLocation = null;
      _selectedIsResolved = null;
      // NEW: Clear internal sub-lists on clear
      _currentSubCategories = [];
      _currentSubLocations = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Ensures the content is scrollable and compact
      // Adjust padding to account for the keyboard when it's open
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Takes minimum vertical space
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Apply Filters',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Report Type Filter (Lost/Found)
          Text('Report Type', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: widget.reportTypes.map((type) {
              return ChoiceChip(
                label: Text(type),
                selected: _selectedType == type,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? type : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Category Filter
          Text('Category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: const Text('Select a category'),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: widget.availableCategories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
                _selectedSubCategory = null; // Reset subcategory when category changes
                _updateSubCategories(); // Immediately update subcategories
              });
            },
          ),
          const SizedBox(height: 20),

          // Subcategory Filter (Always Visible)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Subcategory', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSubCategory,
                hint: const Text('Select a subcategory'),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                // Use _currentSubCategories for items
                items: _currentSubCategories.map((subCategory) {
                  return DropdownMenuItem(
                    value: subCategory,
                    child: Text(subCategory),
                  );
                }).toList(),
                // Enable onChanged only if there's a selected category and subcategories exist
                onChanged: _selectedCategory != null && _currentSubCategories.isNotEmpty
                    ? (value) {
                        setState(() {
                          _selectedSubCategory = value;
                        });
                      }
                    : null, // Disable if no category selected or no subcategories available
                disabledHint: const Text('Select a category first'), // Show when disabled
              ),
              const SizedBox(height: 20),
            ],
          ),


          // Location Filter
          Text('Location', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedLocation,
            hint: const Text('Select a location'),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: widget.availableLocations.map((location) {
              return DropdownMenuItem(
                value: location,
                child: Text(location),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLocation = value;
                _selectedSubLocation = null; // Reset sublocation when location changes
                _updateSubLocations(); // Immediately update sublocations
              });
            },
          ),
          const SizedBox(height: 20),

          // Sublocation Filter (Always Visible)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sublocation', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSubLocation,
                hint: const Text('Select a sublocation'),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                // Use _currentSubLocations for items
                items: _currentSubLocations.map((subLocation) {
                  return DropdownMenuItem(
                    value: subLocation,
                    child: Text(subLocation),
                  );
                }).toList(),
                // Enable onChanged only if there's a selected location and sublocations exist
                onChanged: _selectedLocation != null && _currentSubLocations.isNotEmpty
                    ? (value) {
                        setState(() {
                          _selectedSubLocation = value;
                        });
                      }
                    : null, // Disable if no main location selected or no sublocations available
                disabledHint: const Text('Select a main location first'), // Show when disabled
              ),
              const SizedBox(height: 20),
            ],
          ),

          // Resolved Status Filter
          Text('Status', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: [
              ChoiceChip(
                label: const Text('Resolved'),
                selected: _selectedIsResolved == true,
                onSelected: (selected) {
                  setState(() {
                    _selectedIsResolved = selected ? true : null;
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Unresolved'),
                selected: _selectedIsResolved == false,
                onSelected: (selected) {
                  setState(() {
                    _selectedIsResolved = selected ? false : null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Apply Filters Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApplyFilters(
                  _selectedType,
                  _selectedCategory,
                  _selectedSubCategory,
                  _selectedLocation,
                  _selectedSubLocation,
                  _selectedIsResolved,
                );
                Navigator.pop(context); // Close the bottom sheet
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}