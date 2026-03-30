// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:vegiffyy_vendor/providers/auth_provider.dart';
// import 'package:vegiffyy_vendor/providers/vendor_plan_provider.dart';
// import 'package:vegiffyy_vendor/views/auth/login_screen.dart';
// import 'package:vegiffyy_vendor/views/dashboard/vendor_main_screen.dart';
// import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
// import 'package:vegiffyy_vendor/utils/responsive.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _startFlow();
//   }

// Future<void> _startFlow() async {
//   await VendorPreferences.init();

//   final authProvider = Provider.of<AuthProvider>(context, listen: false);
//   final planProvider = Provider.of<VendorPlanProvider>(context, listen: false);

//   await authProvider.checkLoginStatus();

//   if (authProvider.isLoggedIn) {
//     final vendorId = authProvider.vendor?.id;
//     if (vendorId != null) {
//       await planProvider.checkVendorPlan(vendorId);
//     }
//   }

//   await Future.delayed(const Duration(seconds: 2));

//   if (!mounted) return;

//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(
//       builder: (_) => authProvider.isLoggedIn
//           ? const VendorMainScreen()
//           : const LoginScreen(),
//     ),
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // 🔥 FULL SCREEN SPLASH IMAGE
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/vegsplash.png'),
//                 fit: BoxFit.fill,
//               ),
//             ),
//           ),

//           // 🌑 OPTIONAL DARK OVERLAY
//           Container(
//             color: Colors.black.withOpacity(0.25),
//           ),

//           // 🌀 CENTER LOADER / LOGO (OPTIONAL)
//           SafeArea(
//             child: Column(
//               children: const [
//                 Spacer(),
//                 CircularProgressIndicator(
//                   strokeWidth: 3,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//                 Spacer(),
//               ],
//             ),
//           ),

//           // 👇 OPTIONAL BRANDING (BOTTOM)
//           /*
//           Positioned(
//             bottom: 24,
//             left: 0,
//             right: 0,
//             child: Column(
//               children: [
//                 Text(
//                   "Powered by Nemishhrree",
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.white70,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   "Operated by JEIPLX",
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           */
//         ],
//       ),
//     );
//   }
// }

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

  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  Future<void> _startFlow() async {
    setState(() {
      _isLoading = true;
    });

    await VendorPreferences.init();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final planProvider =
        Provider.of<VendorPlanProvider>(context, listen: false);

    await authProvider.checkLoginStatus();

    if (authProvider.isLoggedIn) {
      final vendorId = authProvider.vendor?.id;
      if (vendorId != null) {
        await planProvider.checkVendorPlan(vendorId);
      }
    }

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

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
      backgroundColor: const Color(0xFF4CAF50), // Full green background
      body:
          isDesktop ? _buildWebContent(context) : _buildMobileContent(context),
    );
  }

  // Mobile Content - Centered with full green background
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

              // Loading indicator
              if (_isLoading) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Loading...",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],

              // const SizedBox(height: 32),

              // // Powered by text at bottom
              // Column(
              //   children: [
              //     Text(
              //       "Powered by Nemishhrree",
              //       style: TextStyle(
              //         fontSize: 12,
              //         color: Colors.white.withOpacity(0.7),
              //         letterSpacing: 1.2,
              //       ),
              //     ),
              //     const SizedBox(height: 4),
              //     Text(
              //       "Operated by JEIPLX",
              //       style: TextStyle(
              //         fontSize: 14,
              //         fontWeight: FontWeight.w600,
              //         color: Colors.white.withOpacity(0.9),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Web Content - Split screen layout
  Widget _buildWebContent(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Row(
      children: [
        // Left side - Logo and Branding (50% width)
        Container(
          width: screenSize.width * 0.5,
          height: screenSize.height,
          color: const Color(0xFF4CAF50),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
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

        // Right side - Content (50% width)
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
                  // Welcome message
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

                  // Feature items
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

                  // Loading indicator
                  if (_isLoading) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Loading...",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const SizedBox(height: 32),

                  // Powered by text
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
