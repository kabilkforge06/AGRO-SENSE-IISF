import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/cold_storage_service.dart';
import '../config/models/cold_storage_facility.dart';

class ColdStorageFinderScreen extends StatefulWidget {
  const ColdStorageFinderScreen({super.key});

  @override
  State<ColdStorageFinderScreen> createState() =>
      _ColdStorageFinderScreenState();
}

class _ColdStorageFinderScreenState extends State<ColdStorageFinderScreen> {
  final ColdStorageService _coldStorageService = ColdStorageService();

  // Data State
  List<ColdStorageFacility> _facilities = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Position? _currentPosition;

  // Search/Filter State
  final TextEditingController _searchController = TextEditingController();

  // By default, we initiate with manual search if location isn't instantly available
  String _selectedState = 'All';
  String _selectedDistrict = 'All';
  List<String> _districts = []; // Dynamic list based on selected State

  @override
  void initState() {
    super.initState();
    // Don't auto-load nearby. Let user choose or we try quietly.
    _attemptInitialLocationLoad();
  }

  Future<void> _attemptInitialLocationLoad() async {
    setState(() => _isLoading = true);
    try {
      // Check permissions without asking first to avoid bad UX on startup
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        await _getCurrentLocationAndFetch();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Select a State & District to find facilities.";
        });
      }
    } catch (e) {
      print('Initial location load error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = "Select a State & District to find facilities.";
      });
    }
  }

  Future<void> _getCurrentLocationAndFetch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition();
      _currentPosition = position;

      debugPrint('Fetching nearby facilities via GPS...');
      final results = await _coldStorageService.getNearbyFacilities(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _facilities = results;
        _isLoading = false;
        if (results.isEmpty) {
          _errorMessage = 'No cold storage facilities found nearby.';
        }
      });
    } catch (e) {
      debugPrint('Location error: $e');
      final errorMsg = e.toString();
      final isCorsError = errorMsg.contains('CORS');
      setState(() {
        _isLoading = false;
        _errorMessage = isCorsError
            ? 'Web demo mode: Showing sample data. Use mobile app for GPS functionality.'
            : 'Could not use GPS: Exception: $errorMsg. \nPlease try Manual Search below.';
      });
    }
  }

  Future<void> _searchByStateAndDistrict() async {
    if (_selectedState == 'All' || _selectedDistrict == 'All') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both State and District')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      FocusScope.of(context).unfocus(); // Hide keyboard
    });

    try {
      debugPrint(
        'Searching for facilities in $_selectedDistrict, $_selectedState',
      );
      final results = await _coldStorageService.searchByStateAndDistrict(
        _selectedState,
        _selectedDistrict,
      );

      setState(() {
        _facilities = results;
        _isLoading = false;
        if (results.isEmpty) {
          _errorMessage =
              'No facilities found in $_selectedDistrict via Google Maps.';
        }
      });
    } catch (e) {
      print('State/District search error: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });

      // Show user-friendly snackbar based on error type
      if (mounted) {
        final isCorsError = errorMsg.contains('CORS');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCorsError
                  ? 'Web demo mode: Sample data shown. Use mobile app for real-time data.'
                  : 'Unable to search. Please check your internet connection.',
            ),
            backgroundColor: isCorsError ? Colors.blue : Colors.orange,
            action: isCorsError
                ? null
                : SnackBarAction(
                    label: 'Retry',
                    onPressed: _searchByStateAndDistrict,
                    textColor: Colors.white,
                  ),
          ),
        );
      }
    }
  }

  Future<void> _searchByText() async {
    final text = _searchController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      FocusScope.of(context).unfocus();
    });

    try {
      final results = await _coldStorageService.searchFacilities(text);
      setState(() {
        _facilities = results;
        _isLoading = false;
        if (results.isEmpty) {
          _errorMessage = 'No results found for "$text"';
        }
      });
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg.contains('CORS')
            ? 'Web demo mode: Showing sample results for "$text"'
            : 'Search failed: $errorMsg';
      });
    }
  }

  // --- UI Helpers for State/District ---

  void _onStateChanged(String? newState) async {
    if (newState == null) return;

    setState(() {
      _selectedState = newState;
      _selectedDistrict = 'All'; // Reset district
      _districts = [];
      _isLoading = true; // Show loading while fetching districts
    });

    if (newState != 'All') {
      final districts = await _coldStorageService.getDistrictsForState(
        newState,
      );
      setState(() {
        _districts = districts;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Storage Finder'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Use GPS',
            onPressed: _getCurrentLocationAndFetch,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search & Filter Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Text Search
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name (e.g. "Frozen Warehouse")',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 10,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _searchByText,
                    ),
                  ),
                  onSubmitted: (_) => _searchByText(),
                ),
                const SizedBox(height: 12),

                const Text(
                  'Or Select Location Manually:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),

                // State & District Row
                Row(
                  children: [
                    // State Dropdown
                    Expanded(
                      flex: 4,
                      child: FutureBuilder<List<String>>(
                        future: _coldStorageService.getAvailableStates(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const LinearProgressIndicator();
                          }

                          final states = ['All', ...snapshot.data!];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedState,
                                hint: const Text('State'),
                                items: states
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(
                                          s,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _onStateChanged,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // District Dropdown
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedDistrict,
                            hint: const Text('District'),
                            // Only allow selection if districts are loaded
                            items: _selectedState == 'All'
                                ? [
                                    const DropdownMenuItem(
                                      value: 'All',
                                      child: Text('Select State First'),
                                    ),
                                  ]
                                : ['All', ..._districts]
                                      .map(
                                        (d) => DropdownMenuItem(
                                          value: d,
                                          child: Text(
                                            d,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                            onChanged: _selectedState == 'All'
                                ? null
                                : (val) {
                                    setState(() => _selectedDistrict = val!);
                                  },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Search Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _searchByStateAndDistrict,
                        child: const Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Results List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_facilities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warehouse, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Search to find cold storages',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _facilities.length,
      itemBuilder: (context, index) {
        return _buildFacilityCard(_facilities[index]);
      },
    );
  }

  Widget _buildFacilityCard(ColdStorageFacility facility) {
    double? distance;
    if (_currentPosition != null) {
      distance = facility.distanceFrom(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              facility.imageUrls.isNotEmpty
                  ? facility.imageUrls.first
                  : 'https://via.placeholder.com/400x200',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 150,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        facility.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (distance != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${distance.toStringAsFixed(1)} km',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        facility.address,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Ratings and Status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            facility.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '(${facility.reviewCount} reviews)',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feature not implemented in this demo'),
                        ),
                      );
                    },
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
