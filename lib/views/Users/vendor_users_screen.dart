import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
import 'package:vegiffyy_vendor/navigation/vendor_navigation_provider.dart';
import 'package:vegiffyy_vendor/navigation/vendor_section.dart';

class VendorUsersScreen extends StatefulWidget {
  const VendorUsersScreen({super.key});

  @override
  State<VendorUsersScreen> createState() => _VendorUsersScreenState();
}

class _VendorUsersScreenState extends State<VendorUsersScreen> {
  String? vendorId;

  final String baseUrl = "https://api.vegiffyy.com/api/vendor";

  bool loading = true;
  List<Map<String, dynamic>> users = [];
  String search = "";

  Map<String, dynamic>? selectedUser;

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

    fetchUsers();
  }

  /* ================= API ================= */

  Future<void> fetchUsers() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/allusers/$vendorId"),
      );
      final body = jsonDecode(res.body);

      if (body['message'] == "Users found successfully") {
        users = List<Map<String, dynamic>>.from(body['data'] ?? []);
      }
    } catch (e) {
      debugPrint("Fetch users error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  /* ================= HELPERS ================= */

  Map<String, dynamic> formatUser(Map u) {
    return {
      "id": u['_id'],
      "name": "${u['firstName'] ?? ''} ${u['lastName'] ?? ''}".trim().isEmpty
          ? "N/A"
          : "${u['firstName'] ?? ''} ${u['lastName'] ?? ''}".trim(),
      "email": u['email'] ?? "No email",
      "phone": u['phoneNumber'] ?? "N/A",
      "city": (u['addresses'] != null &&
              u['addresses'].isNotEmpty &&
              u['addresses'][0]['city'] != null)
          ? u['addresses'][0]['city']
          : "N/A",
      "joinDate": u['createdAt'],
      "status": u['isVerified'] == true ? "verified" : "pending",
      "referral": u['referralCode'] ?? "N/A",
    };
  }

  List<Map<String, dynamic>> get filteredUsers {
    return users
        .map(formatUser)
        .where((u) =>
            u['name'].toLowerCase().contains(search.toLowerCase()) ||
            u['email'].toLowerCase().contains(search.toLowerCase()) ||
            u['phone'].contains(search) ||
            u['city'].toLowerCase().contains(search.toLowerCase()) ||
            u['referral'].toLowerCase().contains(search.toLowerCase()))
        .toList();
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
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text("Restaurant Customers"),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _header(),
                    const SizedBox(height: 16),
                    _searchBar(),
                    const SizedBox(height: 16),
                    Expanded(child: _usersList()),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _header() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.people, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Restaurant Customers",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Text(
              "${filteredUsers.length}",
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search by name, email, mobile, city or referral code...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (v) => setState(() => search = v),
    );
  }

  Widget _usersList() {
    if (filteredUsers.isEmpty) {
      return const Center(
        child: Text("No customers found", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.separated(
      itemCount: filteredUsers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final u = filteredUsers[i];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.person, color: Colors.blue),
            ),
            title: Text(u['name'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u['email']),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(u['phone']),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(u['city']),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statusChip(u['status']),
                TextButton.icon(
                  onPressed: () => _openUserDetails(u),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text("View"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusChip(String status) {
    Color bg;
    Color fg;

    if (status == "verified") {
      bg = Colors.green.shade100;
      fg = Colors.green.shade800;
    } else {
      bg = Colors.orange.shade100;
      fg = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: fg, fontSize: 12)),
    );
  }

  /* ================= MODAL ================= */

  void _openUserDetails(Map<String, dynamic> u) {
    setState(() => selectedUser = u);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text("Customer Details",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 12),
              _detailTile(Icons.person, "Name", u['name']),
              _detailTile(Icons.email, "Email", u['email']),
              _detailTile(Icons.phone, "Mobile", u['phone']),
              _detailTile(Icons.location_on, "City", u['city']),
              _detailTile(
                Icons.calendar_today,
                "Join Date",
                u['joinDate'] != null
                    ? DateFormat('dd MMM yyyy')
                        .format(DateTime.parse(u['joinDate']))
                    : "N/A",
              ),
              _detailTile(Icons.code, "Referral", u['referral']),
              const SizedBox(height: 12),
              _statusChip(u['status']),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20),
      title:
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      subtitle:
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
