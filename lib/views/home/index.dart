import 'package:back2u/components/SimpleCard.dart';
import 'package:back2u/utils/app_drawer.dart';
import 'package:back2u/views/report/index.dart';
import 'package:back2u/views/search/index.dart';
import 'package:flutter/material.dart';

final List<Map<String, dynamic>> cardData = [
  {
    'ownerName': 'John Doe',
    'subCategory': 'Birth Certificate',
    'type': 'Lost',
    'location': 'New York',
    'imageCount': 2,
    'incidentDate': DateTime(2023, 10, 15),
    'isResolved': false,
  },
  {
    'ownerName': 'Jane Smith',
    'subCategory': 'ID Card',
    'type': 'Lost',
    'location': 'Los Angeles',
    'imageCount': 1,
    'incidentDate': DateTime(2023, 11, 3),
    'isResolved': false,
  },
  {
    'ownerName': 'Mike Johnson',
    'subCategory': 'Wallet',
    'type': 'Found',
    'location': 'Los Angeles',
    'imageCount': 3,
    'incidentDate': DateTime(2023, 11, 5),
    'isResolved': false,
  },
  {
    'ownerName': 'Sarah Williams',
    'subCategory': 'Laptop',
    'type': 'Lost',
    'location': 'Chicago',
    'imageCount': 2,
    'incidentDate': DateTime(2023, 11, 10),
    'isResolved': false,
  },
  {
    'ownerName': 'David Miller',
    'subCategory': 'Car Keys',
    'type': 'Found',
    'location': 'Miami',
    'imageCount': 1,
    'incidentDate': DateTime(2023, 11, 12),
    'isResolved': false,
  },
  {
    'ownerName': 'Emily Johnson',
    'subCategory': 'Backpack',
    'type': 'Found',
    'location': 'Seattle',
    'imageCount': 2,
    'incidentDate': DateTime(2023, 11, 8),
    'isResolved': false,
  },
  {
    'ownerName': 'Robert Brown',
    'subCategory': 'Headphones',
    'type': 'Lost',
    'location': 'Dallas',
    'imageCount': 0,
    'incidentDate': DateTime(2023, 10, 28),
    'isResolved': false,
  },
  {
    'ownerName': 'Lisa Chen',
    'subCategory': 'Umbrella',
    'type': 'Found',
    'location': 'Boston',
    'imageCount': 1,
    'incidentDate': DateTime(2023, 10, 25),
    'isResolved': false,
  },
  {
    'ownerName': 'Thomas Wilson',
    'subCategory': 'Watch',
    'type': 'Found',
    'location': 'San Francisco',
    'imageCount': 2,
    'incidentDate': DateTime(2023, 11, 1),
    'isResolved': false,
  },
  {
    'ownerName': 'Peter Jones',
    'subCategory': 'Books',
    'type': 'Lost',
    'location': 'Chicago',
    'imageCount': 1,
    'incidentDate': DateTime(2023, 9, 18),
    'isResolved': true,
  },
];

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = false;
  String _activeFilter = 'All';
  List<Map<String, dynamic>> _filteredData = [];

  final List<String> filters = ['All', 'Lost', 'Found'];

  @override
  void initState() {
    super.initState();
    _filteredData = List.from(cardData);
    _simulateLoading();
  }

  void _simulateLoading() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _filteredData = filter == 'All'
            ? List.from(cardData)
            : cardData.where((item) => item['type'] == filter).toList();
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          centerTitle: true,
          elevation: 1,
          backgroundColor: colorScheme.primary, // Use primary color from theme
          foregroundColor: colorScheme.onPrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search items',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: 'More options',
              onPressed: () {},
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ChoiceChip filter section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Wrap(
                spacing: 8,
                children: filters.map((filter) {
                  final isSelected = _activeFilter == filter;
                  return ChoiceChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        // color: isSelected ? Colors.white : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    // checkmarkColor: Colors.white,
                    // selectedColor: Colors.blue,
                    // backgroundColor: Colors.grey.shade200,
                    onSelected: (_) => _applyFilter(filter),
                  );
                }).toList(),
              ),
            ),

            // Card list or status view
            Expanded(
              child: _isLoading
                  ? _buildLoadingView()
                  : _filteredData.isEmpty
                      ? _buildNoReportsView()
                      : _buildReportsList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Report()),
            );
          },
          label: const Text('Make a Report'),
          icon: const Icon(Icons.add),
          tooltip: 'Create a new lost or found report',
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            "Loading reports...",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReportsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No reports found",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            "Try changing your filters or create a new report",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    return ListView.separated(
      itemCount: _filteredData.length,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      separatorBuilder: (context, index) => const SizedBox(height: 1),
      itemBuilder: (context, index) {
        final item = _filteredData[index];
        return SimpleCard(
          ownerName: item['ownerName'],
          subCategory: item['subCategory'],
          type: item['type'],
          location: item['location'],
          imageCount: item['imageCount'],
          incidentDate: item['incidentDate'],
          isResolved: item['isResolved'],
        );
      },
    );
  }
}
