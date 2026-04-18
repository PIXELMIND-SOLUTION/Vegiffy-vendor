import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
import 'package:vegiffyy_vendor/models/Booking/booking_model.dart';
import 'package:vegiffyy_vendor/navigation/vendor_navigation_provider.dart';
import 'package:vegiffyy_vendor/navigation/vendor_section.dart';
import 'package:vegiffyy_vendor/providers/auth_provider.dart';
import 'package:vegiffyy_vendor/services/Booking/booking_service.dart';
import 'package:vegiffyy_vendor/utils/invoice_pdf.dart';
import 'booking_view_screen.dart';
import 'booking_edit_screen.dart';

class PendingBooking extends StatefulWidget {
  const PendingBooking({super.key});

  @override
  State<PendingBooking> createState() => _PendingBookingState();
}

class _PendingBookingState extends State<PendingBooking> {
  List<BookingModel> bookings = [];
  bool loading = true;
  String statusFilter = "All";
  String? vendorId;

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

    loadBookings();
  }

  Future<void> loadBookings() async {
    final vendor = vendorId.toString();
    try {
      bookings = await BookingService.fetchPendingBookings(vendor);
    } catch (_) {
      bookings = [];
    } finally {
      setState(() => loading = false);
    }
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
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = statusFilter == "All"
        ? bookings
        : bookings.where((b) => b.status == statusFilter).toList();
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
        appBar: AppBar(
          title: const Text("Pending Orders"),
          centerTitle: true,
        ),
        body: filtered.isEmpty
            ? _emptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final b = filtered[i];

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.shade100,
                        child: const Icon(Icons.receipt_long,
                            color: Colors.orange),
                      ),
                      title: Text(
                        "₹${b.total}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.userName,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          _statusChip(b.status),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) async {
                          if (value == 'view') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingViewScreen(booking: b),
                              ),
                            );
                          } else if (value == 'edit') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingEditScreen(booking: b),
                              ),
                            );
                            loadBookings();
                          }
                          // else if (value == 'pdf') {
                          //   await generateInvoicePdf(b);
                          // }
                          else if (value == 'delete') {
                            await BookingService.deleteOrder(b.id);
                            loadBookings();
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'view',
                            child: Text("View"),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Text("Update Status"),
                          ),
                          // PopupMenuItem(
                          //   value: 'pdf',
                          //   child: Text("Invoice PDF"),
                          // ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // ================= EMPTY UI =================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              "No Pending Orders",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You don't have any pending orders right now.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= STATUS CHIP =================

  Widget _statusChip(String status) {
    Color color;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
