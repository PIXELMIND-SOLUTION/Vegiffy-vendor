import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
import 'package:vegiffyy_vendor/navigation/vendor_navigation_provider.dart';
import 'package:vegiffyy_vendor/navigation/vendor_section.dart';
import 'package:vegiffyy_vendor/providers/auth_provider.dart';
import 'package:vegiffyy_vendor/services/Wallet/wallet_service.dart';

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({super.key});

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  String? vendorId;

  bool loading = true;
  bool refreshing = false;
  String error = "";

  Map<String, dynamic>? wallet;
  List<dynamic> accounts = [];

  // withdraw
  bool showWithdraw = false;
  bool withdrawLoading = false;
  String withdrawAmount = "";
  String selectedAccountId = "";

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

    load();
  }

  Future<void> load() async {
    try {
      setState(() {
        error = "";
        loading = true;
      });

      final w = await WalletService.getWallet(vendorId.toString());
      final a = await WalletService.getAccounts(vendorId.toString());

      if (!w['success']) {
        throw Exception(w['message']);
      }

      final primary = a.firstWhere(
        (e) => e['isPrimary'] == true,
        orElse: () => null,
      );

      setState(() {
        wallet = w['data'];
        accounts = a;
        selectedAccountId = primary?['_id'] ?? "";
      });
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      refreshing = false;
      setState(() {});
    }
  }

  double get fee =>
      withdrawAmount.isEmpty ? 0 : double.parse(withdrawAmount) * 0.02;

  double get net =>
      withdrawAmount.isEmpty ? 0 : double.parse(withdrawAmount) - fee;

  // ================== UI ==================

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
      return const Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return _errorState();
    }

    if (wallet == null) {
      return const Center(child: Text("No wallet data"));
    }

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
          title: const Text("My Wallet"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: refreshing
                  ? null
                  : () {
                      setState(() => refreshing = true);
                      load();
                    },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed:
              wallet!['walletBalance'] <= 0 ? null : () => _openWithdrawSheet(),
          label: const Text("Withdraw"),
          icon: const Icon(Icons.currency_rupee),
        ),
        body: RefreshIndicator(
          onRefresh: load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _summaryCards(),
              const SizedBox(height: 16),
              _transactions(),
              const SizedBox(height: 16),
              _withdrawals(),
            ],
          ),
        ),
      ),
    );
  }

  // ================== SECTIONS ==================

  Widget _summaryCards() {
    return Column(
      children: [
        _card(
            "Balance", wallet!['walletBalance'], Icons.account_balance_wallet),
        _card("Total Earnings", wallet!['totalEarnings'], Icons.trending_up),
        _card("Restaurant", wallet!['restaurantName'], Icons.store),
      ],
    );
  }

  Widget _transactions() {
    final tx = wallet!['transactions'] ?? [];
    return _section(
      "Recent Transactions",
      tx.isEmpty
          ? const Text("No transactions")
          : Column(
              children: tx.map<Widget>((t) {
                final isCredit = t['type'] == 'credit';
                return ListTile(
                  leading: Icon(
                    isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isCredit ? Colors.green : Colors.red,
                  ),
                  title: Text(t['description']),
                  subtitle: Text(t['createdAt']),
                  trailing: Text(
                    "${isCredit ? '+' : '-'}₹${t['amount']}",
                    style: TextStyle(
                      color: isCredit ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _withdrawals() {
    final wr = wallet!['withdrawalRequests'] ?? [];
    return _section(
      "Withdrawal Requests",
      wr.isEmpty
          ? const Text("No withdrawal requests")
          : Column(
              children: wr.map<Widget>((w) {
                return ListTile(
                  title: Text("₹${w['amount']}"),
                  subtitle: Text(w['createdAt']),
                  trailing: Chip(
                    label: Text(w['status']),
                    backgroundColor: _statusColor(w['status']),
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ================== WITHDRAW ==================

  void _openWithdrawSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Withdraw Funds",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Amount (₹)",
                    ),
                    onChanged: (v) {
                      setModal(() => withdrawAmount = v);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text("Fee (2%): ₹${fee.toStringAsFixed(2)}"),
                  Text("You get: ₹${net.toStringAsFixed(2)}"),
                  const SizedBox(height: 12),
                  ...accounts.map((a) {
                    return RadioListTile<String>(
                      value: a['_id'],
                      groupValue: selectedAccountId,
                      title: Text(a['bankName']),
                      subtitle: Text(
                          "****${a['accountNumber'].toString().substring(a['accountNumber'].length - 4)}"),
                      onChanged: (v) {
                        setModal(() => selectedAccountId = v!);
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: withdrawLoading ? null : _submitWithdraw,
                    child: withdrawLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submitWithdraw() async {
    final amt = double.tryParse(withdrawAmount) ?? 0;

    if (amt < 100) {
      _snack("Minimum withdrawal is ₹100");
      return;
    }

    if (amt > wallet!['walletBalance']) {
      _snack("Insufficient balance");
      return;
    }

    final account = accounts.firstWhere((a) => a['_id'] == selectedAccountId);

    setState(() => withdrawLoading = true);

    try {
      await WalletService.withdraw(
        vendorId: vendorId.toString(),
        amount: amt,
        account: {
          "bankName": account['bankName'],
          "accountNumber": account['accountNumber'],
          "ifsc": account['ifscCode'],
          "accountHolder": account['accountHolderName'],
          "accountType": account['accountType'],
          "branchName": account['branchName'],
        },
      );

      Navigator.pop(context);
      _snack("Withdrawal request submitted");
      load();
    } catch (e) {
      _snack(e.toString());
    } finally {
      withdrawLoading = false;
    }
  }

  // ================== HELPERS ==================

  Widget _card(String title, dynamic value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value.toString()),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(error, style: const TextStyle(color: Colors.red)),
          ElevatedButton(onPressed: load, child: const Text("Retry")),
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case "approved":
        return Colors.green.shade100;
      case "pending":
        return Colors.orange.shade100;
      case "rejected":
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
