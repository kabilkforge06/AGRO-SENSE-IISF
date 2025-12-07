import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../services/market_service.dart';
import '../widgets/market_widgets.dart';

class CompareMarketsScreen extends StatefulWidget {
  const CompareMarketsScreen({super.key});

  @override
  State<CompareMarketsScreen> createState() => _CompareMarketsScreenState();
}

class _CompareMarketsScreenState extends State<CompareMarketsScreen> {
  final MarketService _marketService = MarketService();

  List<String> _availableMarkets = [];
  final List<String> _selectedMarkets = [];
  List<String> _availableCrops = [];
  final List<String> _selectedCrops = [];
  final Map<String, List<CropPrice>> _marketPrices = {};

  bool _isLoadingMarkets = true;
  bool _isLoadingCrops = false;
  bool _isLoadingComparison = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadMarkets();
  }

  Future<void> _loadMarkets() async {
    try {
      setState(() {
        _isLoadingMarkets = true;
      });

      final markets = await _marketService.getNearbyMarkets();

      setState(() {
        _availableMarkets = markets;
        _isLoadingMarkets = false;
      });
    } catch (e) {
      developer.log('Error loading markets: $e');
      setState(() {
        _isLoadingMarkets = false;
      });
    }
  }

  Future<void> _loadCropsForSelectedMarkets() async {
    if (_selectedMarkets.isEmpty) return;

    try {
      setState(() {
        _isLoadingCrops = true;
      });

      Set<String> allCrops = {};

      // Get crops from selected markets
      for (String market in _selectedMarkets) {
        try {
          final prices = await _marketService.getCropPrices(market);
          allCrops.addAll(prices.map((p) => p.cropName));
        } catch (e) {
          developer.log('Error loading crops for $market: $e');
        }
      }

      setState(() {
        _availableCrops = allCrops.toList()..sort();
        _isLoadingCrops = false;
      });
    } catch (e) {
      developer.log('Error loading crops: $e');
      setState(() {
        _isLoadingCrops = false;
      });
    }
  }

  Future<void> _loadComparisonData() async {
    if (_selectedMarkets.isEmpty || _selectedCrops.isEmpty) return;

    try {
      setState(() {
        _isLoadingComparison = true;
        _marketPrices.clear();
      });

      // Load prices for each selected market
      for (String market in _selectedMarkets) {
        try {
          final prices = await _marketService.getCropPrices(market);
          final filteredPrices = prices
              .where((price) => _selectedCrops.contains(price.cropName))
              .toList();

          setState(() {
            _marketPrices[market] = filteredPrices;
          });
        } catch (e) {
          developer.log('Error loading prices for $market: $e');
        }
      }

      setState(() {
        _isLoadingComparison = false;
      });
    } catch (e) {
      developer.log('Error loading comparison data: $e');
      setState(() {
        _isLoadingComparison = false;
      });
    }
  }

  void _toggleMarket(String market) {
    setState(() {
      if (_selectedMarkets.contains(market)) {
        _selectedMarkets.remove(market);
      } else if (_selectedMarkets.length < 4) {
        // Limit to 4 markets
        _selectedMarkets.add(market);
      }
    });

    if (_selectedMarkets.isNotEmpty) {
      _loadCropsForSelectedMarkets();
    } else {
      setState(() {
        _availableCrops.clear();
        _selectedCrops.clear();
      });
    }
  }

  void _toggleCrop(String crop) {
    setState(() {
      if (_selectedCrops.contains(crop)) {
        _selectedCrops.remove(crop);
      } else if (_selectedCrops.length < 10) {
        // Limit to 10 crops
        _selectedCrops.add(crop);
      }
    });
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedMarkets.isNotEmpty) {
      setState(() {
        _currentStep = 1;
      });
      _loadCropsForSelectedMarkets();
    } else if (_currentStep == 1 && _selectedCrops.isNotEmpty) {
      setState(() {
        _currentStep = 2;
      });
      _loadComparisonData();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Markets'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Step Indicator
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                _StepIndicator(
                  step: 1,
                  title: 'Markets',
                  isActive: _currentStep == 0,
                  isCompleted: _currentStep > 0,
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep > 0 ? Colors.white : Colors.white30,
                  ),
                ),
                _StepIndicator(
                  step: 2,
                  title: 'Crops',
                  isActive: _currentStep == 1,
                  isCompleted: _currentStep > 1,
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep > 1 ? Colors.white : Colors.white30,
                  ),
                ),
                _StepIndicator(
                  step: 3,
                  title: 'Compare',
                  isActive: _currentStep == 2,
                  isCompleted: false,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                // Step 1: Select Markets
                _buildMarketSelection(),

                // Step 2: Select Crops
                _buildCropSelection(),

                // Step 3: Comparison Results
                _buildComparisonResults(),
              ],
            ),
          ),

          // Bottom Navigation
          if (_currentStep < 2)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          (_currentStep == 0 && _selectedMarkets.isNotEmpty) ||
                              (_currentStep == 1 && _selectedCrops.isNotEmpty)
                          ? _nextStep
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_currentStep == 1 ? 'Compare' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMarketSelection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Markets to Compare (${_selectedMarkets.length}/4)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose up to 4 markets for price comparison',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _isLoadingMarkets
                ? const Center(child: CircularProgressIndicator())
                : _availableMarkets.isEmpty
                ? const Center(child: Text('No markets available'))
                : ListView.builder(
                    itemCount: _availableMarkets.length,
                    itemBuilder: (context, index) {
                      final market = _availableMarkets[index];
                      final isSelected = _selectedMarkets.contains(market);
                      final canSelect =
                          _selectedMarkets.length < 4 || isSelected;

                      return Card(
                        child: CheckboxListTile(
                          title: Text(
                            market,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: canSelect ? Colors.black87 : Colors.grey,
                            ),
                          ),
                          value: isSelected,
                          onChanged: canSelect
                              ? (value) => _toggleMarket(market)
                              : null,
                          activeColor: Colors.green[600],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropSelection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Crops to Compare (${_selectedCrops.length}/10)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose crops available in selected markets',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _isLoadingCrops
                ? const Center(child: CircularProgressIndicator())
                : _availableCrops.isEmpty
                ? const Center(
                    child: Text('No crops available in selected markets'),
                  )
                : CropSelectionGrid(
                    availableCrops: _availableCrops,
                    selectedCrops: _selectedCrops,
                    onCropToggle: _toggleCrop,
                    maxSelection: 10,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonResults() {
    if (_isLoadingComparison) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading comparison data...'),
          ],
        ),
      );
    }

    if (_marketPrices.isEmpty) {
      return const Center(child: Text('No comparison data available'));
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Price Comparison',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        // Comparison Table
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  const DataColumn(
                    label: Text(
                      'Crop',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ..._selectedMarkets
                      .map(
                        (market) => DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Text(
                              market.length > 15
                                  ? '${market.substring(0, 12)}...'
                                  : market,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                      ,
                ],
                rows: _selectedCrops.map((crop) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          crop,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      ..._selectedMarkets.map((market) {
                        final marketPrices = _marketPrices[market] ?? [];
                        final cropPrice = marketPrices.firstWhere(
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

                        return DataCell(
                          cropPrice.currentPrice > 0
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '₹${cropPrice.currentPrice.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                    TrendIndicator(trend: cropPrice.trend),
                                  ],
                                )
                              : const Text(
                                  '-',
                                  style: TextStyle(color: Colors.grey),
                                ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  final String title;
  final bool isActive;
  final bool isCompleted;

  const _StepIndicator({
    required this.step,
    required this.title,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    if (isCompleted) {
      backgroundColor = Colors.white;
      textColor = Colors.green[600]!;
    } else if (isActive) {
      backgroundColor = Colors.white;
      textColor = Colors.green[600]!;
    } else {
      backgroundColor = Colors.white30;
      textColor = Colors.white70;
    }

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: textColor, size: 20)
                : Text(
                    step.toString(),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
