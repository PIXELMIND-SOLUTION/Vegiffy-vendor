import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegiffyy_vendor/providers/auth_provider.dart';
import 'package:vegiffyy_vendor/providers/vendor_plan_provider.dart';
import 'package:vegiffyy_vendor/views/auth/login_screen.dart';
import 'package:vegiffyy_vendor/views/dashboard/vendor_main_screen.dart';
import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
import 'package:vegiffyy_vendor/utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = false;
  String _loadingMessage = "Loading...";

  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  Future<void> _startFlow() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = "Initializing...";
    });

    try {
      // Step 1: Initialize preferences
      setState(() {
        _loadingMessage = "Setting up preferences...";
      });
      await VendorPreferences.init();

      // Step 2: Get providers
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final planProvider =
          Provider.of<VendorPlanProvider>(context, listen: false);

      // Step 3: Check login status
      setState(() {
        _loadingMessage = "Checking login status...";
      });
      await authProvider.checkLoginStatus();

      // Step 4: If logged in, check vendor plan
      if (authProvider.isLoggedIn) {
        final vendorId = authProvider.vendor?.id;
        if (vendorId != null) {
          setState(() {
            _loadingMessage = "Verifying your plan...";
          });

          // ✅ Wait for plan check to COMPLETE
          await planProvider.checkVendorPlan(vendorId);

          // ✅ Wait for isChecking to become false
          while (planProvider.isChecking) {
            await Future.delayed(const Duration(milliseconds: 50));
          }

          // Debug: Check what was loaded
          print(
              'Final Plan Status - Has Active Plan: ${planProvider.hasActivePlan}');
          print('Final Plan Status - Is Checking: ${planProvider.isChecking}');
        }
      }

      // Step 5: Final delay for smooth transition
      setState(() {
        _loadingMessage = "Ready!";
      });
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('Error during splash flow: $e');
      setState(() {
        _loadingMessage = "Error loading...";
      });
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Navigate based on login status
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      body:
          isDesktop ? _buildWebContent(context) : _buildMobileContent(context),
    );
  }

  // Mobile Content
  Widget _buildMobileContent(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/veg.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.store,
                        size: 80,
                        color: Color(0xFF4CAF50),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title Text
              const Text(
                "Vegiffy Partner",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle Text
              Text(
                "Partner With Us",
                style: GoogleFonts.tangerine(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 48),

              // Loading indicator with message
              if (_isLoading) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _loadingMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Web Content
  Widget _buildWebContent(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Row(
      children: [
        // Left side - Logo and Branding
        Container(
          width: screenSize.width * 0.5,
          height: screenSize.height,
          color: const Color(0xFF4CAF50),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/veg.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.store,
                          size: 100,
                          color: Color(0xFF4CAF50),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Vegiffy Vendor",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Partner With Us",
                  style: GoogleFonts.tangerine(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right side - Content
        Container(
          width: screenSize.width * 0.5,
          height: screenSize.height,
          color: Colors.white,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome Vendor!",
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Join the Vegiffy family and grow your business with India's favorite pure veg delivery platform.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _buildFeatureItem(icon: Icons.eco, label: "Pure Veg"),
                      const SizedBox(width: 24),
                      _buildFeatureItem(
                        icon: Icons.trending_up,
                        label: "Grow Business",
                      ),
                      const SizedBox(width: 24),
                      _buildFeatureItem(
                        icon: Icons.support_agent,
                        label: "24/7 Support",
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (_isLoading) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _loadingMessage,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Powered by Nemishhrree",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.withOpacity(0.7),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Operated by JEIPLX",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50), size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
