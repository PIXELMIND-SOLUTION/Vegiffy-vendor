import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
import 'package:vegiffyy_vendor/navigation/vendor_navigation_provider.dart';
import 'package:vegiffyy_vendor/navigation/vendor_section.dart';
import 'package:vegiffyy_vendor/providers/Profile/vendor_provider.dart';

class CommissionReportScreen extends StatefulWidget {
  const CommissionReportScreen({super.key});

  @override
  State<CommissionReportScreen> createState() => _CommissionReportScreenState();
}

class _CommissionReportScreenState extends State<CommissionReportScreen> {
  String? vendorId;
  final String baseUrl = "https://api.vegiffyy.com/api";

  // Tax constants
  final int GST_RATE = 18;
  final double TDS_RATE = 0.5;

  bool loading = true;
  String? error;

  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> filteredOrders = [];

  // Filters
  String search = "";
  DateTime? startDate;
  DateTime? endDate;

  // Restaurant commission
  double restaurantCommission = 20.0;

  // Summary data
  Map<String, dynamic> summary = {
    "totalOrders": 0,
    "totalSubtotal": 0.0,
    "totalCommission": 0.0,
    "totalVendorEarning": 0.0,
    "totalGST": 0.0,
    "totalTDS": 0.0,
    "netPayable": 0.0,
    "avgCommissionPercent": 0.0,
  };

  // Selected order for modal
  Map<String, dynamic>? selectedOrder;

  @override
  void initState() {
    super.initState();
    _loadVendor();
  }

  void _loadVendor() {
    final vendor = VendorPreferences.getVendor();

    if (vendor == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expired. Please login again")),
        );
        Navigator.pop(context);
      });
      return;
    }

    vendorId = vendor.id;
    fetchRestaurantDetails();
  }

  /* ================= API ================= */

  Future<void> fetchRestaurantDetails() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/restaurant/$vendorId"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            restaurantCommission =
                (data['data']['commission'] ?? 20).toDouble();
          });
          debugPrint("✅ Restaurant commission loaded: $restaurantCommission%");
        }
      }
    } catch (e) {
      debugPrint("Error fetching restaurant details: $e");
    }

    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });

      final res = await http.get(
        Uri.parse("$baseUrl/vendor/restaurantorders/$vendorId"),
      );

      if (res.statusCode != 200) {
        throw "Failed to fetch orders";
      }

      final body = jsonDecode(res.body);

      if (body['success'] == true) {
        final allOrders = List<Map<String, dynamic>>.from(body['data']);

        // Filter only delivered orders
        final delivered = allOrders.where((o) {
          final status = o['orderStatus']?.toString().toLowerCase() ?? '';
          return status == 'delivered';
        }).toList();

        // Process orders with all tax calculations
        orders = delivered.map<Map<String, dynamic>>((order) {
          final subTotal = (order['subTotal'] ?? 0).toDouble();

          // Step 1: Commission to Vegiffy
          final commissionAmount = (subTotal * restaurantCommission) / 100;

          // Step 2: GST on commission
          final gstOnCommission = (commissionAmount * GST_RATE) / 100;

          // Step 3: Vendor's gross earning (subtotal - commission)
          final vendorGrossEarning = subTotal - commissionAmount;

          // Step 4: TDS on vendor earning
          final tdsOnVendorEarning = (vendorGrossEarning * TDS_RATE) / 100;

          // Step 5: Net payable = subtotal - commission - GST - TDS
          final netPayable = subTotal -
              commissionAmount -
              gstOnCommission -
              tdsOnVendorEarning;

          final orderDate = DateTime.parse(order['createdAt']);

          return {
            "orderId": order['_id'] ?? '',
            "date": orderDate,
            "dateTime": DateFormat('dd MMM yyyy, hh:mm a').format(orderDate),
            "dateOnly": DateFormat('yyyy-MM-dd').format(orderDate),
            "customerName":
                "${order['userId']?['firstName'] ?? ''} ${order['userId']?['lastName'] ?? ''}"
                    .trim(),
            "customerPhone": order['userId']?['phoneNumber'] ?? "N/A",
            "restaurantName": order['restaurantId']?['restaurantName'] ?? "N/A",

            // Order amounts
            "subTotal": double.parse(subTotal.toStringAsFixed(2)),
            "deliveryCharge": (order['deliveryCharge'] ?? 0).toDouble(),
            "couponDiscount": (order['couponDiscount'] ?? 0).toDouble(),
            "totalPayable": (order['totalPayable'] ?? 0).toDouble(),

            // Commission calculations
            "commissionPercent": restaurantCommission,
            "commissionAmount":
                double.parse(commissionAmount.toStringAsFixed(2)),

            // Vendor calculations
            "vendorGrossEarning":
                double.parse(vendorGrossEarning.toStringAsFixed(2)),

            // Tax calculations
            "gstOnCommission": double.parse(gstOnCommission.toStringAsFixed(2)),
            "tdsOnVendorEarning":
                double.parse(tdsOnVendorEarning.toStringAsFixed(2)),
            "netPayable": double.parse(netPayable.toStringAsFixed(2)),

            // Payment info
            "paymentMethod": order['paymentMethod'] ?? "N/A",
            "paymentStatus": order['paymentStatus'] ?? "N/A",
            "orderStatus": order['orderStatus'] ?? "N/A",
          };
        }).toList();

        applyFilters();
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() => loading = false);
    }
  }

  /* ================= FILTERS ================= */

  void applyFilters() {
    filteredOrders = orders.where((o) {
      // Search filter
      final matchesSearch = search.isEmpty ||
          o['orderId'].toLowerCase().contains(search.toLowerCase()) ||
          o['customerName'].toLowerCase().contains(search.toLowerCase()) ||
          o['customerPhone'].contains(search) ||
          o['restaurantName'].toLowerCase().contains(search.toLowerCase());

      // Date filter
      final matchesDate = (startDate == null || endDate == null)
          ? true
          : o['date'].isAfter(startDate!) &&
              o['date'].isBefore(endDate!.add(const Duration(days: 1)));

      return matchesSearch && matchesDate;
    }).toList();

    calculateSummary();
    setState(() {});
  }

  void calculateSummary() {
    final totalOrders = filteredOrders.length;

    final totalSubtotal =
        filteredOrders.fold<double>(0, (s, o) => s + o['subTotal']);

    final totalCommission =
        filteredOrders.fold<double>(0, (s, o) => s + o['commissionAmount']);

    final totalVendorGross =
        filteredOrders.fold<double>(0, (s, o) => s + o['vendorGrossEarning']);

    final totalGST =
        filteredOrders.fold<double>(0, (s, o) => s + o['gstOnCommission']);

    final totalTDS =
        filteredOrders.fold<double>(0, (s, o) => s + o['tdsOnVendorEarning']);

    final totalNetPayable =
        filteredOrders.fold<double>(0, (s, o) => s + o['netPayable']);

    final avgCommissionPercent = totalSubtotal > 0
        ? double.parse(
            ((totalCommission / totalSubtotal) * 100).toStringAsFixed(2))
        : 0.0;

    setState(() {
      summary = {
        "totalOrders": totalOrders,
        "totalSubtotal": double.parse(totalSubtotal.toStringAsFixed(2)),
        "totalCommission": double.parse(totalCommission.toStringAsFixed(2)),
        "totalVendorEarning": double.parse(totalVendorGross.toStringAsFixed(2)),
        "totalGST": double.parse(totalGST.toStringAsFixed(2)),
        "totalTDS": double.parse(totalTDS.toStringAsFixed(2)),
        "netPayable": double.parse(totalNetPayable.toStringAsFixed(2)),
        "avgCommissionPercent": avgCommissionPercent,
      };
    });
  }

  // Quick filters
  void setLast7Days() {
    final now = DateTime.now();
    setState(() {
      startDate = now.subtract(const Duration(days: 6));
      endDate = now;
    });
    applyFilters();
  }

  void setCurrentMonth() {
    final now = DateTime.now();
    setState(() {
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0);
    });
    applyFilters();
  }

  void clearFilters() {
    setState(() {
      search = "";
      startDate = null;
      endDate = null;
    });
    applyFilters();
  }

  // Format currency
  String formatCurrency(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  /* ================= UI ================= */

  Future<bool> _showExitConfirmationDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorProvider>();
    final vendor = provider.vendor;
    final nav = context.watch<VendorNavigationProvider>();

    return WillPopScope(
      onWillPop: () async {
        // If we're not on dashboard, go to dashboard instead of closing app
        if (nav.current != VendorSection.dashboard) {
          context
              .read<VendorNavigationProvider>()
              .setSection(VendorSection.dashboard);
          return false; // Don't pop, we handled it
        }
        // If already on dashboard, show exit confirmation
        return _showExitConfirmationDialog();
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            "Commission & Tax Report",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            // Export options (can be implemented later)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed:
                  filteredOrders.isEmpty ? null : () => _showExportOptions(),
            ),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchOrders,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchOrders,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Tax Rates Banner
                        _taxRatesBanner(),
                        const SizedBox(height: 16),

                        // Summary Cards Grid
                        _summaryCards(),
                        const SizedBox(height: 16),

                        // Filters Section
                        _filtersSection(),
                        const SizedBox(height: 16),

                        // Results Count
                        _resultsCount(),
                        const SizedBox(height: 12),

                        // Orders Table/List
                        _ordersList(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _taxRatesBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _taxRateItem(
            icon: Icons.percent,
            label: "Commission",
            value: "$restaurantCommission%",
            color: Colors.green,
          ),
          Container(width: 1, height: 30, color: Colors.green.shade200),
          _taxRateItem(
            icon: Icons.receipt,
            label: "GST",
            value: "$GST_RATE%",
            color: Colors.blue,
          ),
          Container(width: 1, height: 30, color: Colors.green.shade200),
          _taxRateItem(
            icon: Icons.money_off,
            label: "TDS",
            value: "$TDS_RATE%",
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _taxRateItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _summaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _summaryCard(
          title: "Total Orders",
          value: summary['totalOrders'].toString(),
          icon: Icons.shopping_bag,
          color: Colors.blue,
          subtitle: "Delivered orders",
        ),
        _summaryCard(
          title: "Subtotal",
          value: formatCurrency(summary['totalSubtotal']),
          icon: Icons.receipt,
          color: Colors.green,
        ),
        _summaryCard(
          title: "Commission",
          value: formatCurrency(summary['totalCommission']),
          icon: Icons.percent,
          color: Colors.red,
          subtitle: "$restaurantCommission% of subtotal",
        ),
        _summaryCard(
          title: "GST",
          value: formatCurrency(summary['totalGST']),
          icon: Icons.receipt,
          color: Colors.blue,
          subtitle: "$GST_RATE% on commission",
        ),
        _summaryCard(
          title: "TDS",
          value: formatCurrency(summary['totalTDS']),
          icon: Icons.money_off,
          color: Colors.orange,
          subtitle: "$TDS_RATE% on earnings",
        ),
        _summaryCard(
          title: "Vendor Gross",
          value: formatCurrency(summary['totalVendorEarning']),
          icon: Icons.account_balance,
          color: Colors.purple,
          subtitle: "Before TDS",
        ),
        _summaryCard(
          title: "NET PAYABLE",
          value: formatCurrency(summary['netPayable']),
          icon: Icons.payments,
          color: Colors.green.shade700,
          subtitle: "After all deductions",
          isLarge: true,
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
    bool isLarge = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(isLarge ? 16 : 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isLarge ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isLarge ? 13 : 12,
                      fontWeight: isLarge ? FontWeight.w600 : FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: isLarge ? 20 : 16, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isLarge ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filtersSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Field
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search by order ID, customer, restaurant...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (v) {
                search = v;
                applyFilters();
              },
            ),
            const SizedBox(height: 12),

            // Date Range
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => startDate = date);
                        applyFilters();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              startDate != null
                                  ? DateFormat('dd/MM/yyyy').format(startDate!)
                                  : "Start Date",
                              style: TextStyle(
                                color: startDate != null
                                    ? Colors.black
                                    : Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => endDate = date);
                        applyFilters();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              endDate != null
                                  ? DateFormat('dd/MM/yyyy').format(endDate!)
                                  : "End Date",
                              style: TextStyle(
                                color: endDate != null
                                    ? Colors.black
                                    : Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Quick Filters
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: setLast7Days,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Last 7 Days"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: setCurrentMonth,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("This Month"),
                  ),
                ),
                if (startDate != null ||
                    endDate != null ||
                    search.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: clearFilters,
                    icon: const Icon(Icons.clear),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultsCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Showing ${filteredOrders.length} orders",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "Updated: ${DateFormat('hh:mm a').format(DateTime.now())}",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ordersList() {
    if (filteredOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              Icon(
                orders.isEmpty ? Icons.receipt : Icons.filter_alt_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                orders.isEmpty
                    ? "No delivered orders found"
                    : "No orders match your filters",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                orders.isEmpty
                    ? "Commission report will appear here for delivered orders"
                    : "Try adjusting your search or date filters",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _orderCard(order);
      },
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showCalculationModal(order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Order #${order['orderId'].substring(0, 8)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      order['dateOnly'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Customer Info
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order['customerName'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Amounts Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Subtotal
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Subtotal",
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      Text(
                        formatCurrency(order['subTotal']),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Commission
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Commission",
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      Text(
                        formatCurrency(order['commissionAmount']),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[600],
                        ),
                      ),
                    ],
                  ),

                  // Net Payable
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Net Payable",
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      Text(
                        formatCurrency(order['netPayable']),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // View Details Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showCalculationModal(order),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text("View Full Calculation"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= MODAL ================= */

  void _showCalculationModal(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.calculate, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Complete Financial Breakdown",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            "Order #${order['orderId'].substring(0, 8)}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Scrollable Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // Order Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Order Information",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _infoRow("Date & Time", order['dateTime']),
                            _infoRow("Customer", order['customerName']),
                            _infoRow("Phone", order['customerPhone']),
                            _infoRow("Restaurant", order['restaurantName']),
                            _infoRow("Payment",
                                "${order['paymentMethod']} • ${order['paymentStatus']}"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Step 1: Subtotal
                      _calculationStep(
                        step: 1,
                        title: "Base Amount",
                        color: Colors.grey,
                        children: [
                          _calcRow(
                              "Subtotal", formatCurrency(order['subTotal']),
                              isBold: true),
                          _noteText(
                              "This is the ONLY amount used for all calculations"),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Step 2: Commission
                      _calculationStep(
                        step: 2,
                        title: "Commission to Vegiffy",
                        color: Colors.red,
                        children: [
                          _calcRow("Commission Rate",
                              "$restaurantCommission% of subtotal"),
                          _calcRow("Calculation",
                              "₹${order['subTotal']} × $restaurantCommission%"),
                          _calcRow(
                            "Commission Amount",
                            formatCurrency(order['commissionAmount']),
                            valueColor: Colors.red,
                            isBold: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Step 3: GST on Commission
                      _calculationStep(
                        step: 3,
                        title: "GST on Commission",
                        color: Colors.blue,
                        children: [
                          _calcRow("GST Rate", "$GST_RATE% of commission"),
                          _calcRow("Calculation",
                              "₹${order['commissionAmount']} × $GST_RATE%"),
                          _calcRow(
                            "GST Amount",
                            formatCurrency(order['gstOnCommission']),
                            valueColor: Colors.blue,
                            isBold: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Step 4: Vendor Gross
                      _calculationStep(
                        step: 4,
                        title: "Vendor Gross Earning",
                        color: Colors.purple,
                        children: [
                          _calcRow(
                              "Subtotal", formatCurrency(order['subTotal'])),
                          _calcRow("Less: Commission",
                              "-${formatCurrency(order['commissionAmount'])}",
                              valueColor: Colors.red),
                          _calcRow(
                            "Gross Earning",
                            formatCurrency(order['vendorGrossEarning']),
                            valueColor: Colors.purple,
                            isBold: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Step 5: TDS
                      _calculationStep(
                        step: 5,
                        title: "TDS Deduction",
                        color: Colors.orange,
                        children: [
                          _calcRow("TDS Rate", "$TDS_RATE% of vendor gross"),
                          _calcRow("Calculation",
                              "₹${order['vendorGrossEarning']} × $TDS_RATE%"),
                          _calcRow(
                            "TDS Amount",
                            "-${formatCurrency(order['tdsOnVendorEarning'])}",
                            valueColor: Colors.orange,
                            isBold: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Final Net Payable
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade50,
                              Colors.green.shade100
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.green.shade400, width: 2),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "NET PAYABLE TO YOU",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _calcRow(
                                "Subtotal", formatCurrency(order['subTotal'])),
                            _calcRow("Less: Commission",
                                "-${formatCurrency(order['commissionAmount'])}",
                                valueColor: Colors.red),
                            _calcRow("Less: GST",
                                "-${formatCurrency(order['gstOnCommission'])}",
                                valueColor: Colors.blue),
                            _calcRow("Less: TDS",
                                "-${formatCurrency(order['tdsOnVendorEarning'])}",
                                valueColor: Colors.orange),
                            const Divider(height: 24, thickness: 1),
                            _calcRow(
                              "NET PAYABLE",
                              formatCurrency(order['netPayable']),
                              isBold: true,
                              valueColor: Colors.green.shade700,
                              fontSize: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Summary for this Order",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _calcRow(
                                "Subtotal", formatCurrency(order['subTotal']),
                                isBold: true),
                            _calcRow("Vegiffy Commission",
                                "-${formatCurrency(order['commissionAmount'])}",
                                valueColor: Colors.red),
                            _calcRow("GST to Govt",
                                "-${formatCurrency(order['gstOnCommission'])}",
                                valueColor: Colors.blue),
                            _calcRow("TDS to Govt",
                                "-${formatCurrency(order['tdsOnVendorEarning'])}",
                                valueColor: Colors.orange),
                            const Divider(height: 20),
                            _calcRow(
                              "You Receive",
                              formatCurrency(order['netPayable']),
                              isBold: true,
                              valueColor: Colors.green.shade700,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _calculationStep({
    required int step,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "$step",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _calcRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize - 1,
              color: Colors.grey.shade700,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontStyle: FontStyle.italic,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text("Export as PDF"),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon();
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text("Export as Excel"),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Export feature coming soon!"),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
