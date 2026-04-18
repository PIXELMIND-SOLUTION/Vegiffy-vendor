import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vegiffyy_vendor/navigation/vendor_navigation_provider.dart';
import 'package:vegiffyy_vendor/navigation/vendor_section.dart';

class VendorSupportScreen extends StatefulWidget {
  const VendorSupportScreen({super.key});

  @override
  State<VendorSupportScreen> createState() => _VendorSupportScreenState();
}

class _VendorSupportScreenState extends State<VendorSupportScreen> {
  final String email = "vendor@vegiffyy.com";
  final String phone = "9391950503";

  bool copiedEmail = false;
  bool copiedPhone = false;

  /* ================= ACTIONS ================= */

  void copyEmail() {
    Clipboard.setData(ClipboardData(text: email));
    setState(() => copiedEmail = true);
    Future.delayed(
        const Duration(seconds: 2), () => setState(() => copiedEmail = false));
  }

  void copyPhone() {
    Clipboard.setData(ClipboardData(text: phone));
    setState(() => copiedPhone = true);
    Future.delayed(
        const Duration(seconds: 2), () => setState(() => copiedPhone = false));
  }

  Future<void> sendEmail() async {
    final uri = Uri.parse(
        "mailto:$email?subject=Vendor Support&body=Hello Vegiffyy Vendor Support Team,");
    await launchUrl(uri);
  }

  Future<void> callPhone() async {
    await launchUrl(Uri.parse("tel:$phone"));
  }

  Future<void> openWhatsApp() async {
    final msg = Uri.encodeComponent("Hello Vegiffyy Vendor Support Team,");
    final uri = Uri.parse("https://wa.me/$phone?text=$msg");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8F5E9), Color(0xFFD1FAE5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _mainCard(),
                  const SizedBox(height: 16),
                  _quickTips(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mainCard() {
    return Container(
      width: 420,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _intro(),
                const SizedBox(height: 20),
                _emailCard(),
                const SizedBox(height: 16),
                _phoneCard(),
                const SizedBox(height: 20),
                _footer(),
              ],
            ),
          )
        ],
      ),
    );
  }

  /* ================= SECTIONS ================= */

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: const [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.support_agent, color: Colors.white, size: 28),
          ),
          SizedBox(height: 12),
          Text(
            "Vendor Support",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "24/7 Support for Vendor Partners",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _intro() {
    return Column(
      children: [
        const Text(
          "Need help? Contact our vendor support team",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircleAvatar(radius: 4, backgroundColor: Colors.green),
              SizedBox(width: 8),
              Text(
                "Quick Response Guaranteed",
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emailCard() {
    return _contactCard(
      icon: Icons.email,
      iconColor: Colors.blue,
      title: "Email Support",
      subtitle: "For detailed queries",
      value: email,
      copied: copiedEmail,
      onCopy: copyEmail,
      primaryButton: ElevatedButton(
        onPressed: sendEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("Email"),
      ),
    );
  }

  Widget _phoneCard() {
    return _contactCard(
      icon: Icons.phone,
      iconColor: Colors.green,
      title: "Phone Support",
      subtitle: "Call for immediate assistance",
      value: phone,
      copied: copiedPhone,
      onCopy: copyPhone,
      primaryButton: Row(
        children: [
          ElevatedButton(
            onPressed: callPhone,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Call"),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: openWhatsApp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.chat),
            label: const Text("Chat"),
          ),
        ],
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
    required bool copied,
    required VoidCallback onCopy,
    required Widget primaryButton,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(.15),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: onCopy,
                icon: Icon(copied ? Icons.check : Icons.copy),
                color: iconColor,
              ),
              primaryButton,
            ],
          )
        ],
      ),
    );
  }

  Widget _footer() {
    return Column(
      children: const [
        Divider(),
        Text(
          "⏰ Response time: Within 2 hours on working days",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        SizedBox(height: 4),
        Text(
          "© Vegiffyy Vendor Program • Partner Success Team",
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _quickTips() {
    Widget chip(String text) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(text, style: const TextStyle(fontSize: 12)),
        );

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        chip("📞 Call for urgent issues"),
        chip("✉️ Email for documentation"),
        chip("💬 WhatsApp for quick chat"),
      ],
    );
  }
}
