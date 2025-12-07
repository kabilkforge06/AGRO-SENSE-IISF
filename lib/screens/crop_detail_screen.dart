import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../services/market_service.dart';
import '../widgets/market_widgets.dart';

class CropDetailScreen extends StatefulWidget {
  final String cropName;
  final String marketName;

  const CropDetailScreen({
    super.key,
    required this.cropName,
    required this.marketName,
  });

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  final MarketService _marketService = MarketService();

  CropPrice? _cropPrice;
  List<PriceTrendData> _priceTrends = [];
  bool _isLoadingPrice = true;
  bool _isLoadingTrends = true;

  @override
  void initState() {
    super.initState();
    _loadCropData();
  }

  Future<void> _loadCropData() async {
    await Future.wait([_loadCropPrice(), _loadPriceTrends()]);
  }

  Future<void> _loadCropPrice() async {
    try {
      setState(() {
        _isLoadingPrice = true;
      });

      final prices = await _marketService.getCropPrices(widget.marketName);
      final cropPrice = prices.firstWhere(
        (price) =>
            price.cropName.toLowerCase() == widget.cropName.toLowerCase(),
        orElse: () => throw Exception('Crop not found in market'),
      );

      setState(() {
        _cropPrice = cropPrice;
        _isLoadingPrice = false;
      });
    } catch (e) {
      developer.log('Error loading crop price: $e');
      setState(() {
        _isLoadingPrice = false;
      });
    }
  }

  Future<void> _loadPriceTrends() async {
    try {
      setState(() {
        _isLoadingTrends = true;
      });

      final trends = await _marketService.getPriceTrends(
        widget.cropName,
        widget.marketName,
      );

      setState(() {
        _priceTrends = trends;
        _isLoadingTrends = false;
      });
    } catch (e) {
      developer.log('Error loading price trends: $e');
      setState(() {
        _isLoadingTrends = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cropName.length > 25
              ? '${widget.cropName.substring(0, 22)}...'
              : widget.cropName,
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCropData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCropData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crop Info Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.grass,
                              color: Colors.green[600],
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.cropName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.marketName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Price Information
                      if (_isLoadingPrice)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_cropPrice == null)
                        Center(
                          child: Text(
                            'Price data not available',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        )
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              child: _PriceInfoCard(
                                title: 'Modal Price',
                                price: _cropPrice!.currentPrice,
                                isMain: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PriceInfoCard(
                                title: 'Min Price',
                                price: _cropPrice!.previousPrice,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _PriceInfoCard(
                                title: 'Max Price',
                                price:
                                    _cropPrice!.currentPrice *
                                    1.15, // Approximation
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Trend',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TrendIndicator(
                                          trend: _cropPrice!.trend,
                                          changePercent:
                                              _cropPrice!.changePercent,
                                          showPercentage: true,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Last Updated: ${_formatDate(_cropPrice!.lastUpdated)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Price Trends Section
              Text(
                '7-Day Price Trend',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _isLoadingTrends
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _priceTrends.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.show_chart,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No trend data available',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            // Simple chart representation
                            SizedBox(height: 200, child: _buildSimpleChart()),
                            const SizedBox(height: 20),

                            // Trend summary
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _getTrendSummary(),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleChart() {
    if (_priceTrends.isEmpty) return const SizedBox.shrink();

    final maxPrice = _priceTrends
        .map((e) => e.price)
        .reduce((a, b) => a > b ? a : b);
    final minPrice = _priceTrends
        .map((e) => e.price)
        .reduce((a, b) => a < b ? a : b);
    final priceRange = maxPrice - minPrice;

    return Container(
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        size: Size.infinite,
        painter: _SimpleChartPainter(_priceTrends, minPrice, priceRange),
      ),
    );
  }

  String _getTrendSummary() {
    if (_priceTrends.isEmpty) return 'No trend data available';

    final firstPrice = _priceTrends.first.price;
    final lastPrice = _priceTrends.last.price;
    final change = ((lastPrice - firstPrice) / firstPrice) * 100;

    if (change > 5) {
      return 'Price has increased significantly by ${change.toStringAsFixed(1)}% over the past week.';
    } else if (change < -5) {
      return 'Price has decreased by ${change.abs().toStringAsFixed(1)}% over the past week.';
    } else {
      return 'Price has remained relatively stable over the past week.';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return 'Recently';
    }
  }
}

class _PriceInfoCard extends StatelessWidget {
  final String title;
  final double price;
  final bool isMain;

  const _PriceInfoCard({
    required this.title,
    required this.price,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMain ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMain ? Colors.green[200]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: isMain ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: isMain ? Colors.green[700] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleChartPainter extends CustomPainter {
  final List<PriceTrendData> data;
  final double minPrice;
  final double priceRange;

  _SimpleChartPainter(this.data, this.minPrice, this.priceRange);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.green[700]!
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedPrice = priceRange > 0
          ? (data[i].price - minPrice) / priceRange
          : 0.5;
      final y = size.height - (normalizedPrice * size.height);

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw the line
    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }

    // Draw labels for first and last points
    final textStyle = TextStyle(color: Colors.grey[600], fontSize: 12);

    if (points.isNotEmpty) {
      final firstPainter = TextPainter(
        text: TextSpan(
          text: '₹${data.first.price.toStringAsFixed(0)}',
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      firstPainter.layout();
      firstPainter.paint(
        canvas,
        Offset(points.first.dx - firstPainter.width / 2, points.first.dy - 25),
      );

      final lastPainter = TextPainter(
        text: TextSpan(
          text: '₹${data.last.price.toStringAsFixed(0)}',
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      lastPainter.layout();
      lastPainter.paint(
        canvas,
        Offset(points.last.dx - lastPainter.width / 2, points.last.dy - 25),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
