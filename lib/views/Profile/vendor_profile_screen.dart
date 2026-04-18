import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
import 'package:vegiffyy_vendor/navigation/vendor_navigation_provider.dart';
import 'package:vegiffyy_vendor/navigation/vendor_section.dart';
import 'package:vegiffyy_vendor/providers/Profile/vendor_provider.dart';
import 'package:vegiffyy_vendor/providers/auth_provider.dart';
import 'package:vegiffyy_vendor/views/Profile/document_preview_screen.dart';
import 'package:vegiffyy_vendor/views/Profile/edit_vendor_profile_screen.dart';
import 'package:vegiffyy_vendor/views/widgets/global_back_control.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  String? vendorId;
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final vendor = VendorPreferences.getVendor();

      if (vendor == null) {
        // Session expired safety
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Session expired. Please login again"),
          ),
        );

        Navigator.pop(context);
        return;
      }

      vendorId = vendor.id;

      context.read<VendorProvider>().load(vendorId!);
    });
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              SystemNavigator.pop(); // ACTUALLY EXIT THE APP
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
  }

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

    if (provider.loading || vendor == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
        appBar: AppBar(
          title: const Text("Restaurant Profile"),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditVendorProfileScreen(vendor: vendor),
                  ),
                );
              },
            )
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// HEADER IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: vendor.imageUrl != null
                  ? Image.network(
                      vendor.imageUrl!,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.store, size: 60),
                    ),
            ),

            const SizedBox(height: 16),

            /// NAME + STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    vendor.restaurantName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(vendor.status.toUpperCase()),
                  backgroundColor: vendor.status == 'active'
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// RATING
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text("${vendor.rating} Rating"),
              ],
            ),

            const SizedBox(height: 16),

            /// REFERRAL CODE
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text("Referral Code"),
              subtitle: Text(vendor.referralCode),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: vendor.referralCode),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Referral code copied")),
                  );
                },
              ),
            ),

            /// WALLET
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text("Wallet Balance"),
                subtitle: Text("₹ ${vendor.walletBalance}"),
              ),
            ),

            const SizedBox(height: 16),

            /// DOCUMENTS
            const Text(
              "Business Documents",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ...vendor.documents.entries.map((entry) {
              final doc = entry.value;
              if (doc == null) return const SizedBox.shrink();

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(entry.key.toUpperCase()),
                  subtitle: Text(
                    doc.uploadedAt != null ? doc.uploadedAt!.toString() : '',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DocumentPreviewScreen(url: doc.url),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
