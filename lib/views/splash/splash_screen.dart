
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegiffyy_vendor/providers/auth_provider.dart';
import 'package:vegiffyy_vendor/providers/vendor_plan_provider.dart';
import 'package:vegiffyy_vendor/views/auth/login_screen.dart';
import 'package:vegiffyy_vendor/views/dashboard/vendor_main_screen.dart';
import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
import 'package:vegiffyy_vendor/utils/responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startFlow();
  }

Future<void> _startFlow() async {
  await VendorPreferences.init();

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final planProvider = Provider.of<VendorPlanProvider>(context, listen: false);

  await authProvider.checkLoginStatus();

  if (authProvider.isLoggedIn) {
    final vendorId = authProvider.vendor?.id;
    if (vendorId != null) {
      await planProvider.checkVendorPlan(vendorId);
    }
  }

  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => authProvider.isLoggedIn
          ? const VendorMainScreen()
          : const LoginScreen(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔥 FULL SCREEN SPLASH IMAGE
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/vegsplash.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),

          // 🌑 OPTIONAL DARK OVERLAY
          Container(
            color: Colors.black.withOpacity(0.25),
          ),

          // 🌀 CENTER LOADER / LOGO (OPTIONAL)
          SafeArea(
            child: Column(
              children: const [
                Spacer(),
                CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Spacer(),
              ],
            ),
          ),

          // 👇 OPTIONAL BRANDING (BOTTOM)
          /*
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "Powered by Nemishhrree",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Operated by JEIPLX",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          */
        ],
      ),
    );
  }
}
