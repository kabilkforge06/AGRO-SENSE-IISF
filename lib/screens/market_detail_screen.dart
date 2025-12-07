import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../services/market_service.dart';
import '../widgets/market_widgets.dart';
import 'crop_detail_screen.dart';

class MarketDetailScreen extends StatefulWidget {
  final String marketName;

  const MarketDetailScreen({super.key, required this.marketName});

  @override
  State<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends State<MarketDetailScreen> {
  final MarketService _marketService = MarketService();

  List<CropPrice> _cropPrices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarketData();
  }

  Future<void> _loadMarketData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final prices = await _marketService.getCropPrices(widget.marketName);

      // Sort by crop name for consistent ordering
      prices.sort((a, b) => a.cropName.compareTo(b.cropName));

      setState(() {
        _cropPrices = prices;
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading market data: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading market data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.marketName.length > 30
              ? '${widget.marketName.substring(0, 27)}...'
              : widget.marketName,
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMarketData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Market Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.store, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.marketName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.inventory, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _isLoading
                          ? 'Loading...'
                          : '${_cropPrices.length} commodities available',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Price Table
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadMarketData,
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading market prices...'),
                        ],
                      ),
                    )
                  : _cropPrices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No price data available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pull to refresh to try again',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Table Header
                        const PriceTableRow.header(),

                        // Table Data
                        Expanded(
                          child: ListView.builder(
                            itemCount: _cropPrices.length,
                            itemBuilder: (context, index) {
                              final crop = _cropPrices[index];
                              return PriceTableRow(
                                cropPrice: crop,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CropDetailScreen(
                                        cropName: crop.cropName,
                                        marketName: widget.marketName,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
