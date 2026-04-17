// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:vegiffyy_vendor/providers/auth_provider.dart';
// import 'package:vegiffyy_vendor/utils/responsive.dart';
// import 'package:vegiffyy_vendor/views/dashboard/vendor_dashboard_screen.dart';
// import 'package:vegiffyy_vendor/views/dashboard/vendor_main_screen.dart';

// import '../../Providers/theme_provider.dart' show ThemeProvider;

// class OtpScreen extends StatelessWidget {
//   const OtpScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final auth = context.watch<AuthProvider>();
//     final theme = Theme.of(context);
//     final isDesktop = Responsive.isDesktop(context);
//     final isTablet = Responsive.isTablet(context);
//     final isWide = isDesktop || isTablet;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             auth.goBackToLogin();
//             Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           'Vegiffyy Vendor',
//           style: theme.textTheme.titleLarge
//               ?.copyWith(fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(theme.brightness == Brightness.dark
//                 ? Icons.light_mode
//                 : Icons.dark_mode),
//             onPressed: () {
//               context.read<ThemeProvider>().toggleTheme();
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 650),
//           child: Card(
//             elevation: 2,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//             child: isWide
//                 ? Row(
//                     children: [
//                       Expanded(child: _OtpForm(auth: auth)),
//                     ],
//                   )
//                 : Column(
//                     children: [
//                       Expanded(child: _OtpForm(auth: auth)),
//                     ],
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _OtpForm extends StatelessWidget {
//   final AuthProvider auth;

//   const _OtpForm({required this.auth});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isLoading = auth.status == AuthStatus.loading;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Text(
//                   'Vegiffyy',
//                   style: theme.textTheme.headlineMedium?.copyWith(
//                     color: theme.colorScheme.primary,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(999),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(Icons.circle, size: 8, color: Colors.green),
//                       const SizedBox(width: 4),
//                       Text(
//                         '100% Pure Vegetarian',
//                         style: theme.textTheme.labelSmall,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: const [
//                 _StepChip(label: 'Login', isActive: false, index: 1),
//                 SizedBox(width: 8),
//                 SizedBox(width: 32, child: Divider()),
//                 SizedBox(width: 8),
//                 _StepChip(label: 'Verify OTP', isActive: true, index: 2),
//               ],
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'OTP Verification',
//               style: theme.textTheme.titleLarge
//                   ?.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Enter the 4-digit OTP sent to ${auth.emailController.text.trim()}',
//               style: theme.textTheme.bodyMedium,
//             ),
//             const SizedBox(height: 16),

//             if (auth.demoOtp != null && auth.demoOtp!.isNotEmpty)
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.amber.shade100,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         'Demo OTP Available\nClick "Auto-fill" to use: ${auth.demoOtp}',
//                         style: theme.textTheme.bodySmall,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     TextButton(
//                       onPressed: () {
//                         auth.otpController.text = auth.demoOtp!;
//                       },
//                       child: const Text('Auto-fill'),
//                     ),
//                   ],
//                 ),
//               ),

//             const SizedBox(height: 24),
//             Text(
//               '4-Digit OTP',
//               style: theme.textTheme.labelMedium,
//             ),
//             const SizedBox(height: 8),

//             _OtpBoxes(controller: auth.otpController),

//             const SizedBox(height: 24),
// SizedBox(
//   width: double.infinity,
//   height: 48,
//   child: FilledButton(
//     onPressed: isLoading
//         ? null
//         : () async {
//             final ok = await auth.verifyOtp();

//             if (!context.mounted) return;

//             if (ok) {
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const VendorMainScreen(),
//                 ),
//                 (route) => false,
//               );
//             }
//           },
//     child: isLoading
//         ? const SizedBox(
//             height: 22,
//             width: 22,
//             child: CircularProgressIndicator(strokeWidth: 2),
//           )
//         : const Text('Verify & Continue'),
//   ),
// ),

//             if (auth.status == AuthStatus.error && auth.errorMessage != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16),
//                 child: Text(
//                   auth.errorMessage!,
//                   style: TextStyle(color: theme.colorScheme.error),
//                 ),
//               ),
//             const SizedBox(height: 16),
//             TextButton(
//               onPressed: () {
//                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>VendorDashboardScreen()));
//               },
//               child: const Text('Resend OTP'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _OtpBoxes extends StatelessWidget {
//   final TextEditingController controller;

//   const _OtpBoxes({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 64,
//       child: TextField(
//         controller: controller,
//         maxLength: 4,
//         keyboardType: TextInputType.number,
//         inputFormatters: [
//           FilteringTextInputFormatter.digitsOnly,
//           LengthLimitingTextInputFormatter(4),
//         ],
//         textAlign: TextAlign.center,
//         style: Theme.of(context)
//             .textTheme
//             .headlineMedium
//             ?.copyWith(letterSpacing: 16),
//         decoration: const InputDecoration(
//           counterText: '',
//           hintText: '____',
//         ),
//       ),
//     );
//   }
// }

// class _StepChip extends StatelessWidget {
//   final String label;
//   final bool isActive;
//   final int index;

//   const _StepChip({
//     required this.label,
//     required this.isActive,
//     required this.index,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         CircleAvatar(
//           radius: 14,
//           backgroundColor:
//               isActive ? theme.colorScheme.primary : theme.disabledColor,
//           child: Text(
//             index.toString(),
//             style: const TextStyle(color: Colors.white, fontSize: 12),
//           ),
//         ),
//         const SizedBox(width: 6),
//         Text(
//           label,
//           style: theme.textTheme.bodyMedium?.copyWith(
//             fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vegiffyy_vendor/providers/auth_provider.dart';
import 'package:vegiffyy_vendor/providers/vendor_plan_provider.dart';
import 'package:vegiffyy_vendor/utils/responsive.dart';
import 'package:vegiffyy_vendor/views/dashboard/vendor_main_screen.dart';
import 'package:vegiffyy_vendor/views/Plan/vendor_joining_fee_screen.dart';

import '../../Providers/theme_provider.dart' show ThemeProvider;

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isWide = isDesktop || isTablet;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            auth.goBackToLogin();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Vegiffyy Vendor',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(theme.brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 650),
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: isWide
                ? Row(
                    children: [
                      Expanded(child: _OtpForm(auth: auth)),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(child: _OtpForm(auth: auth)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _OtpForm extends StatefulWidget {
  final AuthProvider auth;

  const _OtpForm({required this.auth});

  @override
  State<_OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<_OtpForm> {
  bool _isNavigating = false;

  Future<void> _handleVerifyOtp() async {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    try {
      final ok = await widget.auth.verifyOtp();

      if (!mounted) return;

      if (ok) {
        // After successful OTP verification, check plan status
        final vendorId = widget.auth.vendor?.id;

        if (vendorId != null) {
          // Show loading dialog while checking plan
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Verifying your plan...'),
                    ],
                  ),
                ),
              ),
            ),
          );

          // Check vendor plan
          final planProvider = Provider.of<VendorPlanProvider>(
            context,
            listen: false,
          );

          await planProvider.checkVendorPlan(vendorId);

          // Wait for checking to complete
          while (planProvider.isChecking) {
            await Future.delayed(const Duration(milliseconds: 50));
          }

          if (!mounted) return;

          // Close the loading dialog
          Navigator.pop(context);

          // Navigate based on plan status
          if (planProvider.hasActivePlan) {
            // User has active plan, go to main screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const VendorMainScreen(),
              ),
              (route) => false,
            );
          } else {
            // User doesn't have plan, go to joining fee screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const VendorJoiningFeeScreen(),
              ),
              (route) => false,
            );
          }
        } else {
          // No vendor ID found (should not happen)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: Vendor information not found'),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error during OTP verification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = widget.auth.status == AuthStatus.loading || _isNavigating;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Vegiffyy',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, size: 8, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        '100% Pure Vegetarian',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                _StepChip(label: 'Login', isActive: false, index: 1),
                SizedBox(width: 8),
                SizedBox(width: 32, child: Divider()),
                SizedBox(width: 8),
                _StepChip(label: 'Verify OTP', isActive: true, index: 2),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'OTP Verification',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 4-digit OTP sent to ${widget.auth.emailController.text.trim()}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (widget.auth.demoOtp != null && widget.auth.demoOtp!.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Demo OTP Available\nClick "Auto-fill" to use: ${widget.auth.demoOtp}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        widget.auth.otpController.text = widget.auth.demoOtp!;
                      },
                      child: const Text('Auto-fill'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Text(
              '4-Digit OTP',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            _OtpBoxes(controller: widget.auth.otpController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: isLoading ? null : _handleVerifyOtp,
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify & Continue'),
              ),
            ),
            if (widget.auth.status == AuthStatus.error &&
                widget.auth.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  widget.auth.errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Handle resend OTP logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('OTP resent successfully!')),
                );
              },
              child: const Text('Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpBoxes extends StatelessWidget {
  final TextEditingController controller;

  const _OtpBoxes({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: TextField(
        controller: controller,
        maxLength: 4,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .headlineMedium
            ?.copyWith(letterSpacing: 16),
        decoration: const InputDecoration(
          counterText: '',
          hintText: '____',
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final int index;

  const _StepChip({
    required this.label,
    required this.isActive,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor:
              isActive ? theme.colorScheme.primary : theme.disabledColor,
          child: Text(
            index.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
