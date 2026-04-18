// import 'package:flutter/material.dart';
// import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
// import 'package:vegiffyy_vendor/models/Booking/booking_model.dart';
// import 'package:vegiffyy_vendor/services/Booking/booking_service.dart';
// import 'package:vegiffyy_vendor/utils/invoice_pdf.dart';
// import 'booking_view_screen.dart';
// import 'booking_edit_screen.dart';

// class BookingListScreen extends StatefulWidget {
//   const BookingListScreen({super.key});

//   @override
//   State<BookingListScreen> createState() => _BookingListScreenState();
// }

// class _BookingListScreenState extends State<BookingListScreen> {
//   List<BookingModel> bookings = [];
//   bool loading = true;
//   String statusFilter = "All";
//       String? vendorId;

//   @override
//   void initState() {
//     super.initState();
//           _loadVendor();

//   }

//     void _loadVendor() {
//   final vendor = VendorPreferences.getVendor();

//   if (vendor == null) {
//     // Safety fallback (auto logout / redirect)
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Session expired. Please login again")),
//       );
//       Navigator.pop(context);
//     });
//     return;
//   }

//   vendorId = vendor.id;

//       loadBookings();

// }

//   Future<void> loadBookings() async {
//     final vendor = vendorId.toString();
//     bookings = await BookingService.fetchBookings(vendor);
//     setState(() => loading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final filtered = statusFilter == "All"
//         ? bookings
//         : bookings.where((b) => b.status == statusFilter).toList();

//     return Scaffold(
//       appBar: AppBar(title: const Text("Order Management")),
//       body: ListView.builder(
//         itemCount: filtered.length,
//         itemBuilder: (_, i) {
//           final b = filtered[i];
//           return Card(
//             margin: const EdgeInsets.all(8),
//             child: ListTile(
//               title: Text("₹${b.total} • ${b.status}"),
//               subtitle: Text(b.userName),
//               trailing: PopupMenuButton(
//                 onSelected: (value) async {
//                   if (value == 'view') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => BookingViewScreen(booking: b),
//                       ),
//                     );
//                   } else if (value == 'edit') {
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => BookingEditScreen(booking: b),
//                       ),
//                     );
//                     loadBookings();
//                   } else if (value == 'pdf') {
//                     await generateInvoicePdf(b);
//                   } else if (value == 'delete') {
//                     await BookingService.deleteOrder(b.id);
//                     loadBookings();
//                   }
//                 },
//                 itemBuilder: (_) => const [
//                   PopupMenuItem(value: 'view', child: Text("View")),
//                   PopupMenuItem(value: 'edit', child: Text("Update Status")),
//                   PopupMenuItem(value: 'pdf', child: Text("Invoice PDF")),
//                   PopupMenuItem(value: 'delete', child: Text("Delete")),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
import 'package:vegiffyy_vendor/models/Booking/booking_model.dart';
import 'package:vegiffyy_vendor/navigation/vendor_navigation_provider.dart';
import 'package:vegiffyy_vendor/navigation/vendor_section.dart';
import 'package:vegiffyy_vendor/providers/auth_provider.dart';
import 'package:vegiffyy_vendor/services/Booking/booking_service.dart';
import 'package:vegiffyy_vendor/utils/invoice_pdf.dart';
import 'package:vegiffyy_vendor/views/widgets/global_back_control.dart';
import 'booking_view_screen.dart';
import 'booking_edit_screen.dart';
import 'package:intl/intl.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  List<BookingModel> bookings = [];
  List<BookingModel> filteredBookings = [];
  bool loading = true;
  String? vendorId;

  // Filter variables
  String statusFilter = "All";
  DateTimeRange? dateRange;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> statusOptions = [
    "All",
    "Pending",
    "Accepted",
    "Delivered",
    "Cancelled",
    "Rejected",
  ];

  @override
  void initState() {
    super.initState();
    _loadVendor();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
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
    loadBookings();
  }

  Future<void> loadBookings() async {
    setState(() => loading = true);
    final vendor = vendorId.toString();
    bookings = await BookingService.fetchBookings(vendor);
    _applyFilters();
    setState(() => loading = false);
  }

  void _applyFilters() {
    filteredBookings = bookings.where((booking) {
      // Status filter
      if (statusFilter != "All" && booking.status != statusFilter) {
        return false;
      }

      // Date filter
      if (dateRange != null) {
        final bookingDate = booking.createdAt;
        if (bookingDate.isBefore(dateRange!.start) ||
            bookingDate.isAfter(dateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final userName = booking.userName.toLowerCase();
        final orderId = booking.id.toLowerCase();
        final total = booking.total.toString();

        return userName.contains(_searchQuery) ||
            orderId.contains(_searchQuery) ||
            total.contains(_searchQuery);
      }

      return true;
    }).toList();

    // Sort by date (newest first)
    filteredBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade600,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateRange = picked;
        _applyFilters();
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      dateRange = null;
      _applyFilters();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return const Color.fromARGB(255, 18, 223, 49);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.restaurant;
      case 'cancelled':
        return Icons.done_all;
      default:
        return Icons.info;
    }
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
        backgroundColor: Colors.grey.shade50,
        body: Column(
          children: [
            // Header with Search and Filters
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Orders",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if (!loading)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "${filteredBookings.length} orders",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText:
                                    "Search by customer, order ID, amount...",
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade500),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey.shade600,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.grey.shade600,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // Date Filter Chip
                          GestureDetector(
                            onTap: _selectDateRange,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: dateRange != null
                                    ? Colors.green.shade50
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: dateRange != null
                                      ? Colors.green.shade300
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: dateRange != null
                                        ? Colors.green.shade700
                                        : Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    dateRange != null
                                        ? "${DateFormat('MMM dd').format(dateRange!.start)} - ${DateFormat('MMM dd').format(dateRange!.end)}"
                                        : "Date Range",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: dateRange != null
                                          ? Colors.green.shade700
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                  if (dateRange != null) ...[
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: _clearDateFilter,
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Status Filter Chips
                          ...statusOptions.map((status) {
                            final isSelected = statusFilter == status;
                            final color = status == "All"
                                ? Colors.grey
                                : _getStatusColor(status);

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(status),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    statusFilter = status;
                                    _applyFilters();
                                  });
                                },
                                selectedColor: color.withOpacity(0.2),
                                backgroundColor: Colors.grey.shade100,
                                labelStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade700,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade300,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (bookings.isEmpty) {
      return _buildEmptyState();
    }

    if (filteredBookings.isEmpty) {
      return _buildNoResults();
    }

    return RefreshIndicator(
      onRefresh: loadBookings,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredBookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildBookingCard(filteredBookings[i]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Orders Yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Orders will appear here once customers\nstart placing them.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              "No Orders Found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your filters or search terms",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final statusColor = _getStatusColor(booking.status);
    final statusIcon = _getStatusIcon(booking.status);
    final orderDate = booking.createdAt;
    final formattedDate =
        DateFormat('MMM dd, yyyy • hh:mm a').format(orderDate);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingViewScreen(booking: booking),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          booking.status,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // More Options Menu
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) async {
                      if (value == 'view') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingViewScreen(booking: booking),
                          ),
                        );
                      } else if (value == 'edit') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingEditScreen(booking: booking),
                          ),
                        );
                        loadBookings();
                      }
                      //  else if (value == 'pdf') {
                      //   await generateInvoicePdf(booking);
                      // }
                      else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Order"),
                            content: const Text(
                              "Are you sure you want to delete this order?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await BookingService.deleteOrder(booking.id);
                          loadBookings();
                        }
                      }
                    },
                    itemBuilder: (_) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 12),
                            Text("View Details"),
                          ],
                        ),
                      ),
                      if (booking.status != 'Delivered')
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 12),
                              Text("Update Status"),
                            ],
                          ),
                        ),
                      // const PopupMenuItem<String>(
                      //   value: 'pdf',
                      //   child: Row(
                      //     children: [
                      //       Icon(Icons.picture_as_pdf, size: 20),
                      //       SizedBox(width: 12),
                      //       Text("Generate Invoice"),
                      //     ],
                      //   ),
                      // ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text("Delete", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Order ID
              Text(
                "Order #${booking.id.substring(0, 8).toUpperCase()}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // Customer Info
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    booking.userName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Date
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Divider
              Divider(color: Colors.grey.shade200),

              const SizedBox(height: 8),

              // Total Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    "₹${booking.total.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
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
}
