import 'package:flutter/material.dart';
import 'package:speakdine_app/services/firestore_service.dart';
import 'package:speakdine_app/models/order_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorExt.surface,
      appBar: AppBar(
        title: Text(
          "Insights & Growth",
          style: TextStyle(
            color: colorExt.primaryText,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            fontFamily: 'Metropolis',
          ),
        ),
        backgroundColor: colorExt.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton.filledTonal(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _dbService.streamOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final orders = snapshot.data ?? [];
          double totalRevenue = 0;
          for (var o in orders) totalRevenue += o.totalAmount;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInsightCard("TOTAL REVENUE", "Rs. ${totalRevenue.toStringAsFixed(0)}", Colors.green, orders.map((e) => e.totalAmount).toList()),
                const SizedBox(height: 16),
                _buildInsightCard("ORDER VELOCITY", "${orders.length} Orders", colorExt.primary, [2, 5, 3, 8, 4, 10, 6]),
                const SizedBox(height: 32),
                Text(
                  "Recent Performance",
                  style: TextStyle(
                    color: colorExt.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                if (orders.isEmpty)
                  _buildEmptyAnalytics()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length > 5 ? 5 : orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildRecentOrderTile(order);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyAnalytics() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.bar_chart_rounded, size: 64, color: colorExt.placeholder.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text("No sales data yet", style: TextStyle(color: colorExt.secondaryText, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, Color color, List<double> points) {
    return Card(
      elevation: 0,
      color: colorExt.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: colorExt.secondaryText, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Text(value, style: TextStyle(color: colorExt.primaryText, fontSize: 26, fontWeight: FontWeight.w900)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.trending_up_rounded, color: color, size: 22),
                )
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 100,
              width: double.infinity,
              child: CustomPaint(
                painter: SmoothChartPainter(color, points),
              ),
            )
          ],
        ),
      ),
    ).animate().slideY(begin: 0.1).fadeIn();
  }

  Widget _buildRecentOrderTile(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: colorExt.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: colorExt.primary.withValues(alpha: 0.1),
          child: Icon(Icons.shopping_bag_rounded, color: colorExt.primary, size: 20),
        ),
        title: Text(order.userName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        subtitle: Text("${order.items.length} dishes", style: TextStyle(color: colorExt.secondaryText, fontSize: 12, fontWeight: FontWeight.w600)),
        trailing: Text(
          "Rs. ${order.totalAmount.toStringAsFixed(0)}",
          style: TextStyle(color: colorExt.primaryText, fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }
}

class SmoothChartPainter extends CustomPainter {
  final Color color;
  final List<double> points;
  SmoothChartPainter(this.color, this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    
    var paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    var fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    var path = Path();
    double max = 0;
    for (var p in points) if (p > max) max = p;
    if (max == 0) max = 1;

    double dx = size.width / (points.length > 1 ? points.length - 1 : 1);
    
    path.moveTo(0, size.height - (points[0] / max * size.height * 0.8));

    for (int i = 1; i < points.length; i++) {
      double x = i * dx;
      double y = size.height - (points[i] / max * size.height * 0.8);
      
      // Using Bezier for smoothness
      double prevX = (i - 1) * dx;
      double prevY = size.height - (points[i - 1] / max * size.height * 0.8);
      
      path.cubicTo(
        prevX + dx / 2, prevY,
        x - dx / 2, y,
        x, y,
      );
    }

    var fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
