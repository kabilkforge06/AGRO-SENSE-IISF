import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../services/market_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  final MarketService _marketService = MarketService();
  late TabController _tabController;

  List<String> _favoriteMarkets = [];
  List<String> _favoriteCrops = [];
  final Map<String, List<CropPrice>> _favoriteCropPrices = {};

  bool _isLoadingFavorites = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    // In a real app, this would load from SharedPreferences or a database
    // For demo purposes, we'll use some hardcoded favorites
    setState(() {
      _isLoadingFavorites = true;
      _favoriteMarkets = ['AJattihalli(Uzhavar Sandhai )', 'AYMANAM VFPCK'];
      _favoriteCrops = ['Amaranthus', 'Cotton', 'Rice'];
    });

    await _loadFavoritePrices();

    setState(() {
      _isLoadingFavorites = false;
    });
  }

  Future<void> _loadFavoritePrices() async {
    // Load prices for favorite crops from favorite markets
    for (String market in _favoriteMarkets) {
      try {
        final prices = await _marketService.getCropPrices(market);
        final favoritePrices = prices
            .where((price) => _favoriteCrops.contains(price.cropName))
            .toList();

        setState(() {
          _favoriteCropPrices[market] = favoritePrices;
        });
      } catch (e) {
        developer.log('Error loading prices for $market: $e');
      }
    }
  }

  void _toggleFavoriteMarket(String market) {
    setState(() {
      if (_favoriteMarkets.contains(market)) {
        _favoriteMarkets.remove(market);
        _favoriteCropPrices.remove(market);
      } else {
        _favoriteMarkets.add(market);
      }
    });
    // In a real app, save to SharedPreferences here
  }

  void _toggleFavoriteCrop(String crop) {
    setState(() {
      if (_favoriteCrops.contains(crop)) {
        _favoriteCrops.remove(crop);
      } else {
        _favoriteCrops.add(crop);
      }
    });
    // In a real app, save to SharedPreferences here
    _loadFavoritePrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.store), text: 'Markets'),
            Tab(icon: Icon(Icons.grass), text: 'Crops'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFavoriteMarkets(), _buildFavoriteCrops()],
      ),
    );
  }

  Widget _buildFavoriteMarkets() {
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: _isLoadingFavorites
          ? const Center(child: CircularProgressIndicator())
          : _favoriteMarkets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite markets yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add markets to favorites from market screens',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favoriteMarkets.length,
              itemBuilder: (context, index) {
                final market = _favoriteMarkets[index];
                final prices = _favoriteCropPrices[market] ?? [];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.store,
                              color: Colors.green[600],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                market,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: Colors.red[600],
                              ),
                              onPressed: () => _toggleFavoriteMarket(market),
                            ),
                          ],
                        ),
                        if (prices.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Text(
                            'Favorite Crops in this Market:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...prices
                              .map(
                                (price) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          price.cropName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '₹${price.currentPrice.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: _buildTrendIcon(price.trend),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              ,
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildFavoriteCrops() {
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: _isLoadingFavorites
          ? const Center(child: CircularProgressIndicator())
          : _favoriteCrops.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite crops yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add crops to favorites from crop screens',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favoriteCrops.length,
              itemBuilder: (context, index) {
                final crop = _favoriteCrops[index];

                // Collect prices from all favorite markets for this crop
                List<CropPrice> cropPricesAcrossMarkets = [];
                _favoriteCropPrices.forEach((market, prices) {
                  final cropPrice = prices.firstWhere(
                    (price) => price.cropName == crop,
                    orElse: () => CropPrice(
                      cropName: crop,
                      currentPrice: 0,
                      previousPrice: 0,
                      changePercent: 0,
                      trend: PriceTrend.stable,
                      market: market,
                      lastUpdated: DateTime.now(),
                    ),
                  );
                  if (cropPrice.currentPrice > 0) {
                    cropPricesAcrossMarkets.add(cropPrice);
                  }
                });

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.grass,
                              color: Colors.green[600],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                crop,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: Colors.red[600],
                              ),
                              onPressed: () => _toggleFavoriteCrop(crop),
                            ),
                          ],
                        ),
                        if (cropPricesAcrossMarkets.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Text(
                            'Prices in Favorite Markets:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...cropPricesAcrossMarkets
                              .map(
                                (price) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          price.market.length > 25
                                              ? '${price.market.substring(0, 22)}...'
                                              : price.market,
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '₹${price.currentPrice.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: _buildTrendIcon(price.trend),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              ,
                        ] else ...[
                          const SizedBox(height: 12),
                          Text(
                            'No price data available in favorite markets',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTrendIcon(PriceTrend trend) {
    IconData icon;
    Color color;

    switch (trend) {
      case PriceTrend.up:
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      case PriceTrend.down:
        icon = Icons.trending_down;
        color = Colors.red;
        break;
      case PriceTrend.stable:
        icon = Icons.trending_flat;
        color = Colors.orange;
        break;
    }

    return Center(child: Icon(icon, color: color, size: 18));
  }
}
