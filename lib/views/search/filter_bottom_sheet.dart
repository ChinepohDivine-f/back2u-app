import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? initialFilterType;
  final String? initialFilterDocumentType;
  final String? initialFilterLocation;
  final bool? initialFilterIsResolved;
  final List<String> reportTypes;
  final List<String> documentTypes;
  final List<String> locations;
  final Function(String?, String?, String?, bool?) onApplyFilters;

  const FilterBottomSheet({
    super.key,
    this.initialFilterType,
    this.initialFilterDocumentType,
    this.initialFilterLocation,
    this.initialFilterIsResolved,
    required this.reportTypes,
    required this.documentTypes,
    required this.locations,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _tempFilterType;
  String? _tempFilterDocumentType;
  String? _tempFilterLocation;
  bool? _tempFilterIsResolved;

  @override
  void initState() {
    super.initState();
    _tempFilterType = widget.initialFilterType;
    _tempFilterDocumentType = widget.initialFilterDocumentType;
    _tempFilterLocation = widget.initialFilterLocation;
    _tempFilterIsResolved = widget.initialFilterIsResolved;
  }

  void _clearFilters() {
    setState(() {
      _tempFilterType = null;
      _tempFilterDocumentType = null;
      _tempFilterLocation = null;
      _tempFilterIsResolved = null;
    });
  }

  Widget _buildChoiceChips<T>({
    required String label,
    required List<T> options,
    required T? selectedValue,
    required void Function(T?) onSelected,
    required String Function(T) labelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: selectedValue == null,
              onSelected: (_) => onSelected(null),
            ),
            ...options.map((option) {
              return ChoiceChip(
                label: Text(labelBuilder(option)),
                selected: selectedValue == option,
                onSelected: (_) => onSelected(option),
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16.0,
        16.0,
        16.0,
        MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Filter Lost Documents', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),

          // Report Type Chips
          _buildChoiceChips<String>(
            label: 'Report Type',
            options: widget.reportTypes,
            selectedValue: _tempFilterType,
            onSelected: (value) => setState(() => _tempFilterType = value),
            labelBuilder: (val) => val,
          ),
          const SizedBox(height: 20),

          // Document Type Dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Document Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.article_outlined),
            ),
            value: _tempFilterDocumentType,
            items: widget.documentTypes.map((docType) {
              return DropdownMenuItem(value: docType, child: Text(docType));
            }).toList(),
            onChanged: (value) => setState(() => _tempFilterDocumentType = value),
            hint: const Text('Select Document Type'),
          ),
          const SizedBox(height: 20),

          // Location Dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            value: _tempFilterLocation,
            items: widget.locations.map((loc) {
              return DropdownMenuItem(value: loc, child: Text(loc));
            }).toList(),
            onChanged: (value) => setState(() => _tempFilterLocation = value),
            hint: const Text('Select Location'),
          ),
          const SizedBox(height: 20),

          // Status Chips
          _buildChoiceChips<bool>(
            label: 'Status',
            options: [true, false],
            selectedValue: _tempFilterIsResolved,
            onSelected: (value) => setState(() => _tempFilterIsResolved = value),
            labelBuilder: (val) => val ? 'Resolved' : 'Unresolved',
          ),
          const SizedBox(height: 30),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(
                    _tempFilterType,
                    _tempFilterDocumentType,
                    _tempFilterLocation,
                    _tempFilterIsResolved,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
