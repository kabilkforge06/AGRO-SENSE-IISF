import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../services/market_service.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketService _marketService = MarketService();
  final TextEditingController _searchController = TextEditingController();

  List<CropPrice> _cropPrices = [];
  List<String> _availableMarkets = [];
  List<String> _filteredMarkets = [];
  List<PriceTrendData> _priceTrends = [];

  bool _isLoading = true;
  bool _isLoadingMarkets = true;
  bool _isLoadingTrends = false;

  String _selectedMarket = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadNearbyMarkets();
  }

  Future<void> _loadNearbyMarkets() async {
    setState(() {
      _isLoadingMarkets = true;
    });

    try {
      final markets = await _marketService.getNearbyMarkets();
      setState(() {
        _availableMarkets = markets;
        _filteredMarkets = markets;
        _selectedMarket = markets.isNotEmpty ? markets.first : 'Local Market';
        _isLoadingMarkets = false;
      });

      await _loadMarketPrices();
    } catch (e) {
      setState(() {
        _isLoadingMarkets = false;
        _selectedMarket = 'Local Market';
      });
      await _loadMarketPrices();
    }
  }

  Future<void> _searchMarkets(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredMarkets = _availableMarkets;
      });
      return;
    }

    try {
      final searchResults = await _marketService.searchMarkets(query);
      setState(() {
        _filteredMarkets = searchResults;
      });
    } catch (e) {
      developer.log('Search error: $e');
    }
  }

  Future<void> _loadPriceTrends(String cropName) async {
    setState(() {
      _isLoadingTrends = true;
    });

    try {
      final trends = await _marketService.getPriceTrends(
        cropName,
        _selectedMarket,
      );
      setState(() {
        _priceTrends = trends;
        _isLoadingTrends = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTrends = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load price trends: $e')),
        );
      }
    }
  }

  Future<void> _loadMarketPrices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prices = await _marketService.getCropPrices(_selectedMarket);
      setState(() {
        _cropPrices = prices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load market prices: $e')),
        );
      }
    }
  }

  void _showMarketSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Market'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search markets...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _searchMarkets,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredMarkets.length,
                  itemBuilder: (context, index) {
                    final market = _filteredMarkets[index];
                    return ListTile(
                      title: Text(market),
                      onTap: () {
                        setState(() {
                          _selectedMarket = market;
                        });
                        Navigator.pop(context);
                        _loadMarketPrices();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPriceTrendsDialog(String cropName) {
    _loadPriceTrends(cropName);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('$cropName Price Trends'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: _isLoadingTrends
                ? const Center(child: CircularProgressIndicator())
                : _priceTrends.isEmpty
                ? const Center(child: Text('No trend data available'))
                : Column(
                    children: [
                      Text(
                        'Market: $_selectedMarket',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _priceTrends.length,
                          itemBuilder: (context, index) {
                            final trend = _priceTrends[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  '₹${trend.price.toStringAsFixed(2)}/kg',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${trend.date.day}/${trend.date.month}/${trend.date.year}',
                                ),
                                trailing: index > 0
                                    ? Icon(
                                        trend.price >
                                                _priceTrends[index - 1].price
                                            ? Icons.trending_up
                                            : Icons.trending_down,
                                        color:
                                            trend.price >
                                                _priceTrends[index - 1].price
                                            ? Colors.green
                                            : Colors.red,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Prices'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoadingMarkets)
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: _showMarketSelectionDialog,
              tooltip: 'Select Market',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMarketPrices,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Market Info Card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.store, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Market',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _selectedMarket,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isLoadingMarkets)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadNearbyMarkets,
                          color: Colors.green.shade700,
                        ),
                    ],
                  ),
                ),

                // Prices List
                Expanded(
                  child: _cropPrices.isEmpty
                      ? const Center(
                          child: Text(
                            'No market prices available',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _cropPrices.length,
                          itemBuilder: (context, index) {
                            final crop = _cropPrices[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.shade100,
                                  child: Text(
                                    crop.cropName[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  crop.cropName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Market: ${crop.market}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${crop.currentPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          '${crop.changePercent > 0 ? '+' : ''}${crop.changePercent.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: crop.trend == PriceTrend.up
                                                ? Colors.green
                                                : crop.trend == PriceTrend.down
                                                ? Colors.red
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.trending_up),
                                      onPressed: () =>
                                          _showPriceTrendsDialog(crop.cropName),
                                      color: Colors.blue,
                                      tooltip: 'View Price Trends',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
