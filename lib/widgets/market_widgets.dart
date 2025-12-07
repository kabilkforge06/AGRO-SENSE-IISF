import 'package:flutter/material.dart';
import '../services/market_service.dart';

/// Trend indicator widget showing price direction with color-coded arrows
class TrendIndicator extends StatelessWidget {
  final PriceTrend trend;
  final double? changePercent;
  final bool showPercentage;

  const TrendIndicator({
    super.key,
    required this.trend,
    this.changePercent,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String text = '';

    switch (trend) {
      case PriceTrend.up:
        icon = Icons.trending_up;
        color = Colors.green;
        text = showPercentage && changePercent != null
            ? '+${changePercent!.toStringAsFixed(1)}%'
            : 'Up';
        break;
      case PriceTrend.down:
        icon = Icons.trending_down;
        color = Colors.red;
        text = showPercentage && changePercent != null
            ? '${changePercent!.toStringAsFixed(1)}%'
            : 'Down';
        break;
      case PriceTrend.stable:
        icon = Icons.trending_flat;
        color = Colors.orange;
        text = 'Stable';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        if (showPercentage && changePercent != null) ...[
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

/// Market card widget for displaying market info with top crops
class MarketCard extends StatelessWidget {
  final String marketName;
  final List<CropPrice> topCrops;
  final VoidCallback onTap;
  final bool isLoading;

  const MarketCard({
    super.key,
    required this.marketName,
    required this.topCrops,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.store, color: Colors.green[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      marketName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (topCrops.isEmpty)
                Text(
                  'No price data available',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                Column(
                  children: topCrops.take(3).map((crop) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              crop.cropName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '₹${crop.currentPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: TrendIndicator(trend: crop.trend),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Crop price tile for displaying individual crop price information
class CropPriceTile extends StatelessWidget {
  final CropPrice cropPrice;
  final VoidCallback? onTap;
  final bool showMarket;

  const CropPriceTile({
    super.key,
    required this.cropPrice,
    this.onTap,
    this.showMarket = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cropPrice.cropName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (showMarket) ...[
                        const SizedBox(height: 4),
                        Text(
                          cropPrice.market,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                TrendIndicator(
                  trend: cropPrice.trend,
                  changePercent: cropPrice.changePercent,
                  showPercentage: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PriceInfo(
                    label: 'Modal Price',
                    price: cropPrice.currentPrice,
                    isMain: true,
                  ),
                ),
                Expanded(
                  child: _PriceInfo(
                    label: 'Min Price',
                    price: cropPrice.previousPrice,
                  ),
                ),
                Expanded(
                  child: _PriceInfo(
                    label: 'Last Updated',
                    date: cropPrice.lastUpdated,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceInfo extends StatelessWidget {
  final String label;
  final double? price;
  final DateTime? date;
  final bool isMain;

  const _PriceInfo({
    required this.label,
    this.price,
    this.date,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    String displayText;
    if (price != null) {
      displayText = '₹${price!.toStringAsFixed(0)}';
    } else if (date != null) {
      final now = DateTime.now();
      final difference = now.difference(date!);
      if (difference.inDays > 0) {
        displayText = '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        displayText = '${difference.inHours}h ago';
      } else {
        displayText = 'Recently';
      }
    } else {
      displayText = 'N/A';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          displayText,
          style: TextStyle(
            fontSize: isMain ? 16 : 14,
            fontWeight: isMain ? FontWeight.bold : FontWeight.w600,
            color: isMain ? Colors.green[700] : Colors.black87,
          ),
        ),
      ],
    );
  }
}

/// Price table row for detailed market view
class PriceTableRow extends StatelessWidget {
  final CropPrice? cropPrice;
  final VoidCallback? onTap;
  final bool isHeader;

  const PriceTableRow({
    super.key,
    required this.cropPrice,
    this.onTap,
    this.isHeader = false,
  });

  const PriceTableRow.header({super.key})
    : cropPrice = null,
      onTap = null,
      isHeader = true;

  @override
  Widget build(BuildContext context) {
    if (isHeader) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          border: Border(bottom: BorderSide(color: Colors.green[200]!)),
        ),
        child: const Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'Commodity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Modal ₹',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Min ₹',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Max ₹',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Trend',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (cropPrice == null) return const SizedBox.shrink();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                cropPrice!.cropName,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '₹${cropPrice!.currentPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '₹${cropPrice!.previousPrice.toStringAsFixed(0)}',
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '₹${(cropPrice!.currentPrice * 1.1).toStringAsFixed(0)}', // Approximating max price
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(child: TrendIndicator(trend: cropPrice!.trend)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Crop selection grid for comparison screens
class CropSelectionGrid extends StatelessWidget {
  final List<String> availableCrops;
  final List<String> selectedCrops;
  final Function(String) onCropToggle;
  final int maxSelection;

  const CropSelectionGrid({
    super.key,
    required this.availableCrops,
    required this.selectedCrops,
    required this.onCropToggle,
    this.maxSelection = 5,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: availableCrops.length,
      itemBuilder: (context, index) {
        final crop = availableCrops[index];
        final isSelected = selectedCrops.contains(crop);
        final canSelect = selectedCrops.length < maxSelection || isSelected;

        return InkWell(
          onTap: canSelect ? () => onCropToggle(crop) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.green[100] : Colors.grey[100],
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                crop,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: canSelect ? Colors.black87 : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Market comparison row for comparing prices across markets
class MarketComparisonRow extends StatelessWidget {
  final String cropName;
  final List<CropPrice> marketPrices;
  final bool isHeader;

  const MarketComparisonRow({
    super.key,
    required this.cropName,
    required this.marketPrices,
    this.isHeader = false,
  });

  const MarketComparisonRow.header({
    super.key,
    required List<String> marketNames,
  }) : cropName = 'Crop',
       marketPrices = const [],
       isHeader = true;

  @override
  Widget build(BuildContext context) {
    if (isHeader) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          border: Border(bottom: BorderSide(color: Colors.green[200]!)),
        ),
        child: Row(
          children: [
            const Expanded(
              flex: 2,
              child: Text(
                'Crop',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...marketPrices.map(
              (price) => Expanded(
                flex: 2,
                child: Text(
                  price.market.length > 15
                      ? '${price.market.substring(0, 12)}...'
                      : price.market,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              cropName,
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...marketPrices.map(
            (price) => Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    '₹${price.currentPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  TrendIndicator(trend: price.trend),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
