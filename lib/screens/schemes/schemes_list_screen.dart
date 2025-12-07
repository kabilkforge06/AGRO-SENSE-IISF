import 'package:flutter/material.dart';
import '../../models/government_scheme.dart';
import '../../services/scheme_service.dart';
import 'scheme_detail_screen.dart';

class SchemesListScreen extends StatefulWidget {
  const SchemesListScreen({super.key});

  @override
  State<SchemesListScreen> createState() => _SchemesListScreenState();
}

class _SchemesListScreenState extends State<SchemesListScreen>
    with SingleTickerProviderStateMixin {
  final SchemeService _schemeService = SchemeService();
  late TabController _tabController;
  String? _selectedCategory;
  String _searchQuery = '';
  List<GovernmentScheme> _searchResults = [];
  bool _isSearching = false;
  List<GovernmentScheme> _allSchemes = [];
  bool _isLoadingSchemes = true;

  final List<String> _categories = [
    'All',
    'Financial Aid',
    'Crop Insurance',
    'Equipment Subsidy',
    'Training',
    'Market Access',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDetailedSchemes();
  }

  Future<void> _loadDetailedSchemes() async {
    setState(() {
      _isLoadingSchemes = true;
    });

    try {
      // Load all detailed schemes from SchemeDataExpander
      final schemes = await _schemeService.getAllDetailedSchemeObjects();
      setState(() {
        _allSchemes = schemes;
        _isLoadingSchemes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSchemes = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading schemes: $e')));
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Search in loaded detailed schemes
    final lowerQuery = query.toLowerCase();
    final results = _allSchemes.where((scheme) {
      return scheme.name.toLowerCase().contains(lowerQuery) ||
          scheme.description.toLowerCase().contains(lowerQuery) ||
          scheme.category.toLowerCase().contains(lowerQuery) ||
          (scheme.departmentName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search schemes...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _performSearch(value);
                },
              )
            : const Text('Government Schemes'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchResults = [];
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (category) {
              setState(() {
                _selectedCategory = category == 'All' ? null : category;
              });
            },
            itemBuilder: (context) {
              return _categories.map((category) {
                return PopupMenuItem(value: category, child: Text(category));
              }).toList();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Schemes'),
            Tab(text: 'Expiring Soon'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSchemeSummaryCard(),
          Expanded(
            child: _isSearching && _searchQuery.isNotEmpty
                ? _buildSearchResults()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllSchemes(),
                      _buildExpiringSoonSchemes(),
                      _buildFavoriteSchemes(),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to eligibility checker
          Navigator.pushNamed(context, '/eligibility-checker');
        },
        label: const Text('Check Eligibility'),
        icon: const Icon(Icons.check_circle),
      ),
    );
  }

  Widget _buildSchemeSummaryCard() {
    if (_isLoadingSchemes) {
      return const SizedBox.shrink();
    }

    final totalSchemes = _allSchemes.length;
    final centralSchemes = _allSchemes.where((s) => s.type == 'Central').length;
    final stateSchemes = _allSchemes.where((s) => s.type == 'State').length;
    final expiringCount = _allSchemes.where((s) => s.isExpiringSoon).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total\nSchemes',
                totalSchemes.toString(),
                Icons.assignment,
              ),
              _buildStatItem(
                'Central\nSchemes',
                centralSchemes.toString(),
                Icons.flag,
              ),
              _buildStatItem(
                'State\nSchemes',
                stateSchemes.toString(),
                Icons.location_city,
              ),
              if (expiringCount > 0)
                _buildStatItem(
                  'Expiring\nSoon',
                  expiringCount.toString(),
                  Icons.warning_amber,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No schemes found'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildSchemeCard(_searchResults[index]);
      },
    );
  }

  Widget _buildAllSchemes() {
    if (_isLoadingSchemes) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filter schemes by selected category
    List<GovernmentScheme> filteredSchemes = _allSchemes;
    if (_selectedCategory != null && _selectedCategory != 'All') {
      filteredSchemes = _allSchemes
          .where((scheme) => scheme.category == _selectedCategory)
          .toList();
    }

    if (filteredSchemes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text('No schemes available'),
            const SizedBox(height: 8),
            if (_selectedCategory != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
                child: const Text('Clear filters'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDetailedSchemes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredSchemes.length,
        itemBuilder: (context, index) {
          return _buildSchemeCard(filteredSchemes[index]);
        },
      ),
    );
  }

  Widget _buildExpiringSoonSchemes() {
    if (_isLoadingSchemes) {
      return const Center(child: CircularProgressIndicator());
    }

    final expiringSchemes =
        _allSchemes.where((scheme) => scheme.isExpiringSoon).toList()..sort(
          (a, b) =>
              (a.daysUntilExpiry ?? 999).compareTo(b.daysUntilExpiry ?? 999),
        );

    if (expiringSchemes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('No schemes expiring soon'),
            SizedBox(height: 8),
            Text(
              'All schemes are valid for more than 30 days',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDetailedSchemes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: expiringSchemes.length,
        itemBuilder: (context, index) {
          return _buildSchemeCard(
            expiringSchemes[index],
            showExpiryAlert: true,
          );
        },
      ),
    );
  }

  Widget _buildFavoriteSchemes() {
    // TODO: Implement favorites using local storage
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No favorite schemes yet'),
          SizedBox(height: 8),
          Text(
            'Mark schemes as favorites to see them here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(
    GovernmentScheme scheme, {
    bool showExpiryAlert = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SchemeDetailScreen(scheme: scheme),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      scheme.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildSchemeTypeBadge(scheme.type),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                scheme.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(Icons.category, scheme.category, Colors.blue),
                  if (scheme.subsidyPercentage != null)
                    _buildInfoChip(
                      Icons.percent,
                      '${scheme.subsidyPercentage}% Subsidy',
                      Colors.green,
                    ),
                  if (scheme.states.isNotEmpty)
                    _buildInfoChip(
                      Icons.location_on,
                      scheme.states.length == 1
                          ? scheme.states.first
                          : '${scheme.states.length} States',
                      Colors.orange,
                    ),
                ],
              ),
              if (showExpiryAlert && scheme.daysUntilExpiry != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Expires in ${scheme.daysUntilExpiry} days',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchemeTypeBadge(String type) {
    Color color;
    switch (type.toLowerCase()) {
      case 'central':
        color = Colors.purple;
        break;
      case 'state':
        color = Colors.teal;
        break;
      case 'district':
        color = Colors.indigo;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
