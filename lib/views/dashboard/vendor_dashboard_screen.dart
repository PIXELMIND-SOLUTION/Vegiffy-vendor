import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/dashboard_models.dart';
import '../../utils/responsive.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  bool _initialized = false;
  String? _vendorId;

  /// 🔥 NEW
  Timer? _pendingTimer;
  DashboardProvider? _dash;

  final ScrollController _scrollController = ScrollController();

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (!_initialized) {
  //     final auth = context.read<AuthProvider>();
  //     final vendor = auth.vendor;

  //     if (vendor != null && vendor.id.isNotEmpty) {
  //       _vendorId = vendor.id;

  //       /// Initial load
  //       context.read<DashboardProvider>().loadAll(vendor.id);

  //       /// 🔁 CALL PENDING API EVERY 5 SECONDS
  //       _pendingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
  //         if (mounted) {
  //           context.read<DashboardProvider>().loadAll(vendor.id);
  //         }
  //       });

  //       /// 🔽 SCROLL TO BOTTOM → RELOAD DASHBOARD
  //       _scrollController.addListener(() {
  //         if (_scrollController.position.pixels >=
  //             _scrollController.position.maxScrollExtent - 50) {
  //           context.read<DashboardProvider>().loadAll(vendor.id);
  //         }
  //       });
  //     }

  //     _initialized = true;
  //   }
  // }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final vendor = auth.vendor;

      if (vendor == null || vendor.id.isEmpty) return;

      _vendorId = vendor.id;
      _dash = context.read<DashboardProvider>();

      /// Initial load
      _dash!.loadAll(_vendorId!);

      /// ✅ GUARANTEED 5-SEC POLLING
      _pendingTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) {
          if (!mounted) return;

          debugPrint('⏱ Calling pending orders API...');
          _dash!.loadPendingOrders(_vendorId!); // 👈 IMPORTANT
        },
      );
    });
  }

  @override
  void dispose() {
    _pendingTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    final padding = EdgeInsets.symmetric(
      horizontal: isMobile ? 12 : 24,
      vertical: isMobile ? 12 : 20,
    );

    return Container(
      color: theme.colorScheme.surfaceVariant.withOpacity(0.05),
      child: Consumer<DashboardProvider>(
        builder: (context, dash, _) {
          if (dash.isLoading && dash.stats == null) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (dash.status == DashboardStatus.error && dash.stats == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  dash.errorMessage ?? 'Failed to load dashboard',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  // Reload all dashboard data
                  if (_vendorId != null) {
                    await _dash?.loadAll(_vendorId!);
                    // Also reload pending orders
                    await _dash?.loadPendingOrders(_vendorId!);
                  }
                },
                color: theme.colorScheme.primary,
                backgroundColor: Colors.white,
                strokeWidth: 2,
                child: SingleChildScrollView(
                  controller: _scrollController, // ✅ ATTACHED
                  padding: padding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: isDesktop ? 1200 : 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HeaderBar(dash: dash),
                          const SizedBox(height: 16),
                          _StatsGrid(stats: dash.stats, dash: dash),
                          const SizedBox(height: 24),
                          _ChartsRow(dash: dash),
                          const SizedBox(height: 24),
                          _BottomSection(dash: dash),
                          const SizedBox(height: 24),
                          _QuickOverview(dash: dash),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (dash.showBuffer &&
                  dash.currentBufferOrder != null &&
                  _vendorId != null)
                _BufferModalOverlay(
                  dash: dash,
                  vendorId: _vendorId!,
                ),
            ],
          );
        },
      ),
    );
  }
}

//
// ---------- HEADER + PENDING INFO ----------
//

class _HeaderBar extends StatelessWidget {
  final DashboardProvider dash;

  const _HeaderBar({required this.dash});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendingCount = dash.bufferOrders.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pendingCount > 0) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.orange.withOpacity(0.4),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$pendingCount pending order${pendingCount > 1 ? 's' : ''} awaiting action',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: dash.openBuffer,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    backgroundColor: Colors.orange.withOpacity(0.08),
                  ),
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                  ),
                  label: const Text('View orders'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

//
// ---------- STATS GRID ----------
//

class _StatsGrid extends StatelessWidget {
  final DashboardStats? stats;
  final DashboardProvider dash;

  const _StatsGrid({required this.stats, required this.dash});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    final crossAxisCount = isMobile ? 2 : 4;

    final totalOrders = stats?.totalOrders ?? 0;
    final completedOrders = stats?.completedOrders ?? 0;
    final pendingCount = dash.pendingOrders.length;
    final totalProducts = dash.products.length;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isMobile ? 1.15 : 1.6,
      children: [
        _StatCard(
          title: 'Total Orders',
          subtitle: 'All time',
          value: '$totalOrders',
          icon: Icons.shopping_bag_outlined,
          color: theme.colorScheme.primary,
        ),
        _StatCard(
          title: 'Completed',
          subtitle: 'Delivered',
          value: '$completedOrders',
          icon: Icons.check_circle_outline,
          color: Colors.teal,
        ),
        _StatCard(
          title: 'Pending',
          subtitle: 'Needs action',
          value: '$pendingCount',
          icon: Icons.timer_outlined,
          color: Colors.orange.shade800,
        ),
        _StatCard(
          title: 'Products',
          subtitle: 'Live on menu',
          value: '$totalProducts',
          icon: Icons.restaurant_menu,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      color: theme.brightness == Brightness.light
          ? Colors.white
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ---------- CHARTS ROW (responsive) ----------
//

class _ChartsRow extends StatelessWidget {
  final DashboardProvider dash;

  const _ChartsRow({required this.dash});

  @override
  Widget build(BuildContext context) {
    final isWide =
        Responsive.isDesktop(context) || Responsive.isTablet(context);

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _SalesChartCard(dash: dash)),
          const SizedBox(width: 16),
          const Expanded(child: _RevenueChartCard()),
        ],
      );
    }

    return Column(
      children: [
        _SalesChartCard(dash: dash),
        const SizedBox(height: 16),
        const _RevenueChartCard(),
      ],
    );
  }
}

class _SalesChartCard extends StatelessWidget {
  final DashboardProvider dash;

  const _SalesChartCard({required this.dash});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = dash.currentSales;

    final timeframes = dash.salesByTimeframe.keys.toList()
      ..sort((a, b) => a.compareTo(b)); // keep order stable

    double maxY = 0;
    for (final e in data) {
      if (e.sales > maxY) maxY = e.sales;
    }
    if (maxY == 0) {
      maxY = 1;
    }
    final adjustedMaxY = maxY * 1.2;
    final interval = adjustedMaxY / 4;

    return Card(
      elevation: 2,
      color: theme.brightness == Brightness.light
          ? Colors.white
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales Performance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Orders by selected timeframe',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
                if (timeframes.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: theme.colorScheme.primary.withOpacity(0.05),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: dash.selectedTimeframe,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        onChanged: (v) {
                          if (v != null) dash.changeTimeframe(v);
                        },
                        items: timeframes
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 230,
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        'No sales data available',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.hintColor),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        maxY: adjustedMaxY,
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: interval,
                          getDrawingHorizontalLine: (value) => FlLine(
                            strokeWidth: 0.5,
                            color: theme.dividerColor.withOpacity(0.4),
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: interval,
                              getTitlesWidget: (value, meta) {
                                if (value < 0) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  value.toInt().toString(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= data.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    data[idx].name,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipRoundedRadius: 12,
                            tooltipPadding: const EdgeInsets.all(8),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final idx = group.x.toInt();
                              final item = data[idx];
                              return BarTooltipItem(
                                '${item.name}\n',
                                theme.textTheme.labelMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        '${item.sales.toStringAsFixed(0)} orders',
                                    style: theme.textTheme.labelSmall,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        barGroups: [
                          for (int i = 0; i < data.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: data[i].sales,
                                  width: 14,
                                  borderRadius: BorderRadius.circular(8),
                                  color: theme.colorScheme.primary,
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: adjustedMaxY,
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.05),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueChartCard extends StatelessWidget {
  const _RevenueChartCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final revenue = [
      SalesEntry(name: 'Jan', sales: 40000),
      SalesEntry(name: 'Feb', sales: 30000),
      SalesEntry(name: 'Mar', sales: 50000),
      SalesEntry(name: 'Apr', sales: 27800),
      SalesEntry(name: 'May', sales: 38900),
      SalesEntry(name: 'Jun', sales: 43900),
    ];

    double maxY = 0;
    for (final e in revenue) {
      if (e.sales > maxY) maxY = e.sales;
    }
    if (maxY == 0) {
      maxY = 1;
    }
    final adjustedMaxY = maxY * 1.2;
    final interval = adjustedMaxY / 4;

    String _formatK(double value) {
      if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(0)}k';
      }
      return value.toStringAsFixed(0);
    }

    return Card(
      elevation: 2,
      color: theme.brightness == Brightness.light
          ? Colors.white
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Trend',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Last 6 months (₹)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: theme.colorScheme.primary.withOpacity(0.05),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Revenue',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 230,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: adjustedMaxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) => FlLine(
                      strokeWidth: 0.5,
                      color: theme.dividerColor.withOpacity(0.4),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          if (value < 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            _formatK(value),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= revenue.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              revenue[idx].name,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipRoundedRadius: 12,
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.toInt();
                          final item = revenue[idx];
                          return LineTooltipItem(
                            '${item.name}\n',
                            theme.textTheme.labelMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              TextSpan(
                                text: '₹${item.sales.toStringAsFixed(0)}',
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < revenue.length; i++)
                          FlSpot(i.toDouble(), revenue[i].sales),
                      ],
                      isCurved: true,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      color: theme.colorScheme.primary,
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withOpacity(0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ---------- CATEGORY + RECENT ORDERS SECTION ----------
//

class _BottomSection extends StatelessWidget {
  final DashboardProvider dash;

  const _BottomSection({required this.dash});

  @override
  Widget build(BuildContext context) {
    final isWide =
        Responsive.isDesktop(context) || Responsive.isTablet(context);

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: _CategoryCard()),
          const SizedBox(width: 16),
          Expanded(child: _RecentOrdersCard(dash: dash)),
        ],
      );
    }

    return Column(
      children: [
        const _CategoryCard(),
        const SizedBox(height: 16),
        _RecentOrdersCard(dash: dash),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final values = [
      {'value': 35.0, 'label': 'Main Course'},
      {'value': 25.0, 'label': 'Appetizers'},
      {'value': 20.0, 'label': 'Desserts'},
      {'value': 15.0, 'label': 'Beverages'},
      {'value': 5.0, 'label': 'Salads'},
    ];

    final colors = [
      theme.colorScheme.primary,
      Colors.teal,
      Colors.orange.shade700,
      Colors.purple,
      Colors.indigo,
    ];

    return Card(
      elevation: 2,
      color: theme.brightness == Brightness.light
          ? Colors.white
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Distribution',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Share of orders by category',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: [
                          for (int i = 0; i < values.length; i++)
                            PieChartSectionData(
                              value: values[i]['value'] as double,
                              color: colors[i % colors.length],
                              title: '${values[i]['value']}%',
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < values.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: colors[i % colors.length],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                values[i]['label'] as String,
                                style: theme.textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentOrdersCard extends StatelessWidget {
  final DashboardProvider dash;

  const _RecentOrdersCard({required this.dash});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orders = dash.orders.take(5).toList();

    return Card(
      elevation: 2,
      color: theme.brightness == Brightness.light
          ? Colors.white
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Orders',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last 5 orders from your customers',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 12),
            if (orders.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    'No recent orders',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (final order in orders)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.08),
                            child: Icon(
                              Icons.receipt_long_rounded,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #${order.id.substring(order.id.length - 8)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  order.paymentMethod,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${order.totalPayable.toStringAsFixed(2)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: order.orderStatus.toLowerCase() ==
                                          'completed'
                                      ? Colors.green.withOpacity(0.08)
                                      : Colors.orange.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  order.orderStatus,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: order.orderStatus.toLowerCase() ==
                                            'completed'
                                        ? Colors.green.shade800
                                        : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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

//
// ---------- QUICK OVERVIEW: PENDING + TOP PRODUCTS ----------
//

class _QuickOverview extends StatelessWidget {
  final DashboardProvider dash;

  const _QuickOverview({required this.dash});

  @override
  Widget build(BuildContext context) {
    final isWide =
        Responsive.isDesktop(context) || Responsive.isTablet(context);

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _PendingOrdersCard(dash: dash)),
          const SizedBox(width: 16),
          Expanded(child: _TopProductsCard(dash: dash)),
        ],
      );
    }

    return Column(
      children: [
        _PendingOrdersCard(dash: dash),
        const SizedBox(height: 16),
        _TopProductsCard(dash: dash),
      ],
    );
  }
}

class _PendingOrdersCard extends StatelessWidget {
  final DashboardProvider dash;

  const _PendingOrdersCard({required this.dash});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pending = dash.pendingOrders;

    return Card(
      elevation: 2,
      color: theme.brightness == Brightness.light
          ? Colors.white
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pending Orders',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Orders waiting for your confirmation',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 12),
            if (pending.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    'No pending orders',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (final order in pending.take(5))
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.2),
                          width: 0.6,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.orange.withOpacity(0.12),
                            ),
                            child: const Icon(
                              Icons.timelapse_rounded,
                              size: 18,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '#${order.id.substring(order.id.length - 8)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  order.paymentMethod,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${order.totalPayable.toStringAsFixed(2)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pending',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ],
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

class _TopProductsCard extends StatelessWidget {
  final DashboardProvider dash;

  const _TopProductsCard({required this.dash});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final products = dash.products.take(5).toList();

    return Card(
      elevation: 2,
      color: theme.brightness == Brightness.light
          ? Colors.white
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Products',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Best performing menu items',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 12),
            if (products.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    'No products available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (int i = 0; i < products.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  theme.colorScheme.primary.withOpacity(0.06),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  products[i].displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  products[i].categoryName,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${products[i].displayPrice.toStringAsFixed(0)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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

//
// ---------- BUFFER MODAL (ACCEPT / REJECT) ----------
//

// class _BufferModalOverlay extends StatelessWidget {
//   final DashboardProvider dash;
//   final String vendorId;

//   const _BufferModalOverlay({
//     required this.dash,
//     required this.vendorId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final order = dash.currentBufferOrder!;
//     final user = order.user;
//     final address = order.deliveryAddress;

//     return Positioned.fill(
//       child: Container(
//         color: Colors.black.withOpacity(0.5),
//         child: Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 600),
//             child: Card(
//               elevation: 6,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(18),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             width: 24,
//                             height: 24,
//                             decoration: BoxDecoration(
//                               color:
//                                   theme.colorScheme.primary.withOpacity(0.12),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               Icons.notifications_active_rounded,
//                               color: theme.colorScheme.primary,
//                               size: 16,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'New Order Alert',
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.close_rounded),
//                             splashRadius: 20,
//                             onPressed: dash.closeBuffer,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       const Divider(height: 1),
//                       const SizedBox(height: 12),
//                       Text(
//                         'Order #${order.id.substring(order.id.length - 8)}',
//                         style: theme.textTheme.bodyLarge?.copyWith(
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 4,
//                         children: [
//                           Chip(
//                             padding: EdgeInsets.zero,
//                             backgroundColor:
//                                 theme.colorScheme.primary.withOpacity(0.06),
//                             side: BorderSide(
//                               color: theme.colorScheme.primary.withOpacity(0.3),
//                               width: 0.4,
//                             ),
//                             label: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.account_balance_wallet_outlined,
//                                   size: 16,
//                                   color: theme.colorScheme.primary,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(order.paymentMethod),
//                               ],
//                             ),
//                           ),
//                           Chip(
//                             padding: EdgeInsets.zero,
//                             backgroundColor: Colors.orange.withOpacity(0.06),
//                             side: BorderSide(
//                               color: Colors.orange.withOpacity(0.3),
//                               width: 0.4,
//                             ),
//                             label: Text(
//                               'Status: ${order.orderStatus}',
//                               style: TextStyle(
//                                 color: Colors.orange.shade900,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       if (user != null) ...[
//                         Text(
//                           'Customer details',
//                           style: theme.textTheme.labelLarge?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             color: theme.colorScheme.surfaceVariant
//                                 .withOpacity(0.25),
//                           ),
//                           child: Text(
//                             'Name: ${user.firstName ?? ''} ${user.lastName ?? ''}\n'
//                             'Phone: ${user.phoneNumber ?? 'N/A'}\n'
//                             'Email: ${user.email ?? 'N/A'}',
//                             style: theme.textTheme.bodySmall,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                       ],
//                       if (address != null) ...[
//                         Text(
//                           'Delivery address',
//                           style: theme.textTheme.labelLarge?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             color: theme.colorScheme.surfaceVariant
//                                 .withOpacity(0.25),
//                           ),
//                           child: Text(
//                             '${address.street ?? ''}, ${address.city ?? ''}\n'
//                             '${address.state ?? ''}, ${address.postalCode ?? ''}\n'
//                             '${address.country ?? ''}',
//                             style: theme.textTheme.bodySmall,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                       ],
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Order total',
//                             style: theme.textTheme.bodyMedium?.copyWith(
//                               color: theme.hintColor,
//                             ),
//                           ),
//                           Text(
//                             '₹${order.totalPayable.toStringAsFixed(2)}',
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: OutlinedButton(
//                               style: OutlinedButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 12,
//                                 ),
//                                 side: BorderSide(
//                                   color: Colors.redAccent.withOpacity(0.5),
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                               ),
//                               onPressed: () {
//                                 dash.rejectOrder(vendorId, order.id);
//                               },
//                               child: Text(
//                                 'Reject',
//                                 style: TextStyle(
//                                   color: Colors.redAccent.shade400,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 12,
//                                 ),
//                                 backgroundColor: Colors.green,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                               ),
//                               onPressed: () {
//                                 dash.acceptOrder(vendorId, order.id);
//                               },
//                               child: const Text(
//                                 'Accept',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       if (dash.bufferOrders.length > 1) ...[
//                         const SizedBox(height: 8),
//                         Align(
//                           alignment: Alignment.center,
//                           child: TextButton.icon(
//                             onPressed: dash.nextBufferOrder,
//                             icon: const Icon(
//                               Icons.skip_next_rounded,
//                               size: 18,
//                             ),
//                             label: Text(
//                               'Next order (${dash.bufferOrders.length - 1} more)',
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

//
// ---------- BUFFER MODAL (ACCEPT / REJECT) WITH AUDIO ----------
//

class _BufferModalOverlay extends StatefulWidget {
  final DashboardProvider dash;
  final String vendorId;

  const _BufferModalOverlay({
    required this.dash,
    required this.vendorId,
  });

  @override
  State<_BufferModalOverlay> createState() => _BufferModalOverlayState();
}

class _BufferModalOverlayState extends State<_BufferModalOverlay> {
  bool _hasPlayedSound = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playNewOrderSound();
  }

  Future<void> _playNewOrderSound() async {
    if (_hasPlayedSound) return;
    _hasPlayedSound = true;

    try {
      await _audioPlayer.play(AssetSource('audio/new_order.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final order = widget.dash.currentBufferOrder!;
    final user = order.user;
    final address = order.deliveryAddress;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.notifications_active_rounded,
                              color: theme.colorScheme.primary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'New Order Alert',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          // Sound indicator icon
                          IconButton(
                            icon: const Icon(Icons.volume_up, size: 18),
                            onPressed: _playNewOrderSound,
                            tooltip: 'Play sound again',
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            splashRadius: 20,
                            onPressed: widget.dash.closeBuffer,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Animated bell for new order
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 1 + (value * 0.1),
                            child: child,
                          );
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              color: Colors.orange.shade600,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Order #${order.id.substring(order.id.length - 8)}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(
                            padding: EdgeInsets.zero,
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.06),
                            side: BorderSide(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              width: 0.4,
                            ),
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(order.paymentMethod),
                              ],
                            ),
                          ),
                          Chip(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.orange.withOpacity(0.06),
                            side: BorderSide(
                              color: Colors.orange.withOpacity(0.3),
                              width: 0.4,
                            ),
                            label: Text(
                              'Status: ${order.orderStatus}',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (user != null) ...[
                        Text(
                          'Customer details',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: theme.colorScheme.surfaceVariant
                                .withOpacity(0.25),
                          ),
                          child: Text(
                            'Name: ${user.firstName ?? ''} ${user.lastName ?? ''}\n'
                            'Phone: ${user.phoneNumber ?? 'N/A'}\n'
                            'Email: ${user.email ?? 'N/A'}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (address != null) ...[
                        Text(
                          'Delivery address',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: theme.colorScheme.surfaceVariant
                                .withOpacity(0.25),
                          ),
                          child: Text(
                            '${address.street ?? ''}, ${address.city ?? ''}\n'
                            '${address.state ?? ''}, ${address.postalCode ?? ''}\n'
                            '${address.country ?? ''}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order total',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            '₹${order.totalPayable.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(
                                  color: Colors.redAccent.withOpacity(0.5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                widget.dash
                                    .rejectOrder(widget.vendorId, order.id);
                              },
                              child: Text(
                                'Reject',
                                style: TextStyle(
                                  color: Colors.redAccent.shade400,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                widget.dash
                                    .acceptOrder(widget.vendorId, order.id);
                              },
                              child: const Text(
                                'Accept',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.dash.bufferOrders.length > 1) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton.icon(
                            onPressed: widget.dash.nextBufferOrder,
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              size: 18,
                            ),
                            label: Text(
                              'Next order (${widget.dash.bufferOrders.length - 1} more)',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
