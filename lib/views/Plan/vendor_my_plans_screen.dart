import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
import 'package:vegiffyy_vendor/navigation/vendor_navigation_provider.dart';
import 'package:vegiffyy_vendor/navigation/vendor_section.dart';
import 'package:vegiffyy_vendor/providers/auth_provider.dart';

class VendorMyPlansScreen extends StatefulWidget {
  const VendorMyPlansScreen({super.key});

  @override
  State<VendorMyPlansScreen> createState() => _VendorMyPlansScreenState();
}

class _VendorMyPlansScreenState extends State<VendorMyPlansScreen> {
  String? vendorId;

  final String baseUrl = "https://api.vegiffy.in/api/vendor";

  bool loading = true;
  List<Map<String, dynamic>> plans = [];

  Map<String, dynamic>? selectedPlan;
  bool showPlanModal = false;

  @override
  void initState() {
    super.initState();
    _loadVendor();
  }

  void _loadVendor() {
    final vendor = VendorPreferences.getVendor();

    if (vendor == null) {
      // Safety fallback (auto logout / redirect)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expired. Please login again")),
        );
        Navigator.pop(context);
      });
      return;
    }

    vendorId = vendor.id;

    fetchMyPlans();
  }

  /* ===================== API ===================== */

  Future<void> fetchMyPlans() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/myplan/$vendorId"));

      final body = jsonDecode(res.body);
      print("pppppppppppppppppppppppppppppp${res.body}");

      if (body['success'] == true && body['data'] != null) {
        plans = [_formatPlan(body['data'])];
      } else {
        plans = [];
      }
    } catch (e) {
      debugPrint("Plan fetch error: $e");
      plans = [];
    }

    setState(() => loading = false);
  }

  /* ===================== FORMAT PLAN ===================== */

  Map<String, dynamic> _formatPlan(dynamic plan) {
    final purchaseDate = DateTime.parse(plan['planPurchaseDate']);
    final expiryDate = DateTime.parse(plan['expiryDate']);
    final isActive = DateTime.now().isBefore(expiryDate);

    return {
      "_id": plan['_id'],
      "planName": "Vendor Subscription Plan",
      "baseAmount": (plan['amount'] ?? 0).toDouble(),
      "gstAmount": (plan['gstAmount'] ?? 0).toDouble(),
      "totalAmount": (plan['totalAmount'] ?? 0).toDouble(),
      "benefits": const [
        "Restaurant listing",
        "Order management",
        "Customer analytics"
      ],
      "transactionId": plan['transactionId'] ?? "N/A",
      "razorpayPaymentId": plan['razorpayPaymentId'] ?? "N/A",
      "purchaseDate": purchaseDate,
      "expiryDate": expiryDate,
      "status": isActive ? "active" : "expired",
      "daysRemaining":
          isActive ? expiryDate.difference(DateTime.now()).inDays : 0,
      "isActive": isActive,
      "vendorId": plan['vendorId'],
    };
  }

  /* ===================== UI ===================== */

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
    final nav = context.watch<VendorNavigationProvider>();
    final vendor = context.watch<AuthProvider>().vendor;
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
        appBar: AppBar(title: const Text("My Vendor Plans")),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : plans.isEmpty
                ? _noPlans()
                : _plansGrid(),
      ),
    );
  }

  Widget _noPlans() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.card_membership, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            "No Plans Found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "You haven't purchased any vendor plans yet",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _plansGrid() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (_, i) {
        final plan = plans[i];
        return _planCard(plan);
      },
    );
  }

  Widget _planCard(Map<String, dynamic> plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan['planName'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      plan['isActive']
                          ? "${plan['daysRemaining']} days remaining"
                          : "Expired",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${plan['totalAmount'].toStringAsFixed(1)}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "GST ₹${plan['gstAmount'].toStringAsFixed(1)}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// BODY
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow("Base Amount", "₹${plan['baseAmount']}"),
                _infoRow("Purchase Date", _formatDate(plan['purchaseDate'])),
                _infoRow("Expiry Date", _formatDate(plan['expiryDate'])),
                const SizedBox(height: 12),
                const Text("Benefits",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ...plan['benefits'].map<Widget>((b) => Row(
                      children: [
                        const Icon(Icons.check, size: 16, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(b),
                      ],
                    )),
                // const SizedBox(height: 12),
                // SizedBox(
                //   width: double.infinity,
                //   child: OutlinedButton(
                //     onPressed: () {
                //       setState(() {
                //         selectedPlan = plan;
                //         showPlanModal = true;
                //       });
                //     },
                //     child: const Text("View Details"),
                //   ),
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day}-${d.month}-${d.year}";
  }
}
