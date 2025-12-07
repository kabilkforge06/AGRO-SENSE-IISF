import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../services/market_service.dart';
import '../widgets/market_widgets.dart';
import 'market_detail_screen.dart';

class NearbyMarketsScreen extends StatefulWidget {
  const NearbyMarketsScreen({super.key});

  @override
  State<NearbyMarketsScreen> createState() => _NearbyMarketsScreenState();
}

class _NearbyMarketsScreenState extends State<NearbyMarketsScreen> {
  final MarketService _marketService = MarketService();
  final TextEditingController _searchController = TextEditingController();

  List<String> _allMarkets = [];
  List<String> _filteredMarkets = [];
  final Map<String, List<CropPrice>> _marketCrops = {};
  final Map<String, bool> _marketLoadingState = {};

  bool _isLoadingMarkets = true;

  @override
  void initState() {
    super.initState();
    _loadMarkets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMarkets() async {
    try {
      setState(() {
        _isLoadingMarkets = true;
      });

      final markets = await _marketService.getNearbyMarkets();

      setState(() {
        _allMarkets = markets;
        _filteredMarkets = markets;
        _isLoadingMarkets = false;
      });

      // Load top crops for each market
      _loadTopCropsForMarkets();
    } catch (e) {
      developer.log('Error loading markets: $e');
      setState(() {
        _isLoadingMarkets = false;
      });
    }
  }

  Future<void> _loadTopCropsForMarkets() async {
    for (String market in _filteredMarkets) {
      _loadTopCropsForMarket(market);
    }
  }

  Future<void> _loadTopCropsForMarket(String market) async {
    try {
      setState(() {
        _marketLoadingState[market] = true;
      });

      final crops = await _marketService.getCropPrices(market);

      // Sort by price and take top 3
      crops.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));

      setState(() {
        _marketCrops[market] = crops.take(3).toList();
        _marketLoadingState[market] = false;
      });
    } catch (e) {
      developer.log('Error loading crops for market $market: $e');
      setState(() {
        _marketLoadingState[market] = false;
        _marketCrops[market] = [];
      });
    }
  }

  void _filterMarkets(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMarkets = _allMarkets;
      } else {
        _filteredMarkets = _allMarkets
            .where(
              (market) => market.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });

    // Load crops for newly filtered markets
    for (String market in _filteredMarkets) {
      if (!_marketCrops.containsKey(market) &&
          !(_marketLoadingState[market] ?? false)) {
        _loadTopCropsForMarket(market);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Markets'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search markets...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          _filterMarkets('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: _filterMarkets,
            ),
          ),

          // Markets List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadMarkets,
              child: _isLoadingMarkets
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredMarkets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.store_mall_directory_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'No markets found'
                                : 'No markets available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_searchController.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: _filteredMarkets.length,
                      itemBuilder: (context, index) {
                        final market = _filteredMarkets[index];
                        final crops = _marketCrops[market] ?? [];
                        final isLoading = _marketLoadingState[market] ?? false;

                        return MarketCard(
                          marketName: market,
                          topCrops: crops,
                          isLoading: isLoading,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MarketDetailScreen(marketName: market),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
