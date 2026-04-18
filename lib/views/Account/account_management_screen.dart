import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
import 'package:vegiffyy_vendor/navigation/vendor_navigation_provider.dart';
import 'package:vegiffyy_vendor/navigation/vendor_section.dart';

import 'add_edit_account_screen.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  String? vendorId;

  final String baseUrl = "https://api.vegiffyy.com/api/vendor";

  bool loading = false;
  List accounts = [];

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
    fetchAccounts();
  }

  /* ===================== API ===================== */

  Future<void> fetchAccounts() async {
    setState(() => loading = true);

    final res = await http.get(Uri.parse("$baseUrl/allaccounts/$vendorId"));
    final body = jsonDecode(res.body);

    if (body['success']) {
      accounts = body['data'] ?? [];
    }

    setState(() => loading = false);
  }

  Future<void> deleteAccount(String id) async {
    await http.delete(Uri.parse("$baseUrl/deleteaccount/$id"));
    fetchAccounts();
  }

  Future<void> setPrimary(String id) async {
    await http.put(
      Uri.parse("$baseUrl/updateaccount/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "vendorId": vendorId,
        "isPrimary": true,
      }),
    );
    fetchAccounts();
  }

  String maskAccount(String acc) =>
      acc.length > 4 ? "**** **** **** ${acc.substring(acc.length - 4)}" : acc;

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
          title: const Text("Account Management"),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddEditAccountScreen(vendorId: vendorId.toString()),
                  ),
                );
                fetchAccounts();
              },
            )
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : accounts.isEmpty
                ? const Center(child: Text("No accounts found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: accounts.length,
                    itemBuilder: (_, i) {
                      final acc = accounts[i];

                      return Card(
                        child: ListTile(
                          leading: acc['isPrimary']
                              ? const Icon(Icons.verified, color: Colors.green)
                              : const Icon(Icons.account_balance),
                          title: Text(acc['accountHolderName']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(maskAccount(acc['accountNumber'])),
                              Text(
                                "${acc['bankName']} • ${acc['accountType']}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),

                          /// ✅ SAFE POPUP MENU
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              switch (value) {
                                case 'edit':
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddEditAccountScreen(
                                        vendorId: vendorId.toString(),
                                        account: acc,
                                      ),
                                    ),
                                  );
                                  fetchAccounts();
                                  break;
                                case 'delete':
                                  deleteAccount(acc['_id']);
                                  break;
                                case 'primary':
                                  setPrimary(acc['_id']);
                                  break;
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text("Edit"),
                              ),
                              if (!acc['isPrimary'])
                                const PopupMenuItem(
                                  value: 'primary',
                                  child: Text("Set as Primary"),
                                ),
                              const PopupMenuDivider(),
                              const PopupMenuItem(
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
}
