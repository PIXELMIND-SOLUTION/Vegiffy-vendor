// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';

// import 'vendor_joining_success_screen.dart';

// class VendorJoiningFeeScreen extends StatefulWidget {
//   const VendorJoiningFeeScreen({super.key});

//   @override
//   State<VendorJoiningFeeScreen> createState() =>
//       _VendorJoiningFeeScreenState();
// }

// class _VendorJoiningFeeScreenState extends State<VendorJoiningFeeScreen> {
//    String? vendorId;
//   final String baseUrl = "https://api.vegiffyy.com/api";

//   final int GST_RATE = 18;

//   bool loading = false;
//   bool plansLoading = true;
//   String error = "";

//   List<Map<String, dynamic>> plans = [];
//   Map<String, dynamic>? selectedPlan;
//   Map<String, dynamic>? vendor;

//   late Razorpay _razorpay;

//   @override
//   void initState() {
//     super.initState();
//               _loadVendor();

//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);


//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }


//         void _loadVendor() {
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

//          fetchVendor();
//     fetchPlans();


// }

//   /* ===================== API ===================== */

//   Future<void> fetchVendor() async {
//     try {
//       final res =
//           await http.get(Uri.parse("$baseUrl/vendor/profile/$vendorId"));
//       final body = jsonDecode(res.body);

//       if (body['success'] == true) {
//         vendor = body['data'];
//       }
//     } catch (_) {}
//     setState(() {});
//   }

//   Future<void> fetchPlans() async {
//     try {
//       final res =
//           await http.get(Uri.parse("$baseUrl/admin/vendorplans"));
//       final body = jsonDecode(res.body);

//       if (body['success'] == true) {
//         plans = List<Map<String, dynamic>>.from(body['data']);
//         if (plans.isNotEmpty) {
//           selectedPlan = plans.first;
//         }
//       }
//     } catch (_) {
//       error = "Failed to load plans";
//     }

//     setState(() => plansLoading = false);
//   }

//   /* ===================== GST ===================== */

//   Map<String, int> gstCalc(num price) {
//     final base = price.round();
//     final gst = ((base * GST_RATE) / 100).round();
//     return {
//       "base": base,
//       "gst": gst,
//       "total": base + gst,
//     };
//   }

//   /* ===================== PAYMENT ===================== */

//   void startPayment() {
//     if (selectedPlan == null) return;

//     final gst = gstCalc(selectedPlan!['price']);

//     final options = {
//       'key': 'rzp_test_BxtRNvflG06PTV',
//       'amount': gst['total']! * 100,
//       'name': 'Vegiffyy Vendor Program',
//       'description': selectedPlan!['name'],
//       'prefill': {
//         'contact': vendor?['mobile'] ?? '',
//         'email': vendor?['email'] ?? '',
//         'name': vendor?['restaurantName'] ?? 'Vendor',
//       },
//       'theme': {'color': '#10B981'}
//     };

//     _razorpay.open(options);
//   }

//   void _onSuccess(PaymentSuccessResponse response) async {
//     try {
//       await http.post(
//         Uri.parse("$baseUrl/vendor/pay/$vendorId"),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "planId": selectedPlan!['_id'],
//           "transactionId": response.paymentId,
//         }),
//       );

//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => VendorJoiningSuccessScreen(
//               plan: selectedPlan!,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() => error = "Payment verification failed");
//     }
//   }

//   void _onError(PaymentFailureResponse response) {
//     setState(() => error = response.message ?? "Payment failed");
//   }

//   /* ===================== UI ===================== */

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5FDF9),
//       appBar: AppBar(
//         title: const Text("Activate Restaurant"),
//         backgroundColor: Colors.green,
//       ),
//       body: plansLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _body(),
//     );
//   }

//   Widget _body() {
//     if (plans.isEmpty) {
//       return const Center(child: Text("No plans available"));
//     }

//     final gst = selectedPlan != null
//         ? gstCalc(selectedPlan!['price'])
//         : {"base": 0, "gst": 0, "total": 0};

//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         _vendorCard(),
//         const SizedBox(height: 16),

//         /// PLANS
//         ...plans.map(_planCard),

//         const SizedBox(height: 16),

//         /// PAYMENT SUMMARY
//         Card(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 _row("Plan Price", "₹${gst['base']}"),
//                 _row("GST (18%)", "₹${gst['gst']}"),
//                 const Divider(),
//                 _row(
//                   "Total",
//                   "₹${gst['total']}",
//                   bold: true,
//                 ),
//               ],
//             ),
//           ),
//         ),

//         const SizedBox(height: 16),

//         /// PAY BUTTON
//         ElevatedButton(
//           onPressed: loading ? null : startPayment,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green,
//             padding: const EdgeInsets.all(16),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//           child: const Text(
//             "Pay & Activate",
//             style: TextStyle(fontSize: 18),
//           ),
//         ),

//         if (error.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.only(top: 12),
//             child: Text(
//               error,
//               style: const TextStyle(color: Colors.red),
//               textAlign: TextAlign.center,
//             ),
//           )
//       ],
//     );
//   }

//   Widget _vendorCard() {
//     return Card(
//       child: ListTile(
//         leading: const Icon(Icons.store, color: Colors.green),
//         title: Text(vendor?['restaurantName'] ?? "Your Restaurant"),
//         subtitle: Text(vendor?['locationName'] ?? ""),
//       ),
//     );
//   }

//   Widget _planCard(Map<String, dynamic> plan) {
//     final selected = selectedPlan?['_id'] == plan['_id'];

//     return GestureDetector(
//       onTap: () => setState(() => selectedPlan = plan),
//       child: Card(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         color: selected ? Colors.green.shade50 : null,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(plan['name'],
//                         style: const TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 6),
//                     Text("₹${plan['price']} • ${plan['validity']} days"),
//                     const SizedBox(height: 8),
//                     ...List<String>.from(plan['benefits'] ?? [])
//                         .take(3)
//                         .map((b) => Row(
//                               children: const [
//                                 Icon(Icons.check,
//                                     size: 16, color: Colors.green),
//                               ],
//                             ))
//                   ],
//                 ),
//               ),
//               if (selected)
//                 const Icon(Icons.check_circle, color: Colors.green)
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _row(String t, String v, {bool bold = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(t),
//         Text(v,
//             style: TextStyle(
//                 fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
//       ],
//     );
//   }
// }


























import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
import 'package:path/path.dart' as path;
import 'vendor_joining_success_screen.dart';

class VendorJoiningFeeScreen extends StatefulWidget {
  const VendorJoiningFeeScreen({super.key});

  @override
  State<VendorJoiningFeeScreen> createState() => _VendorJoiningFeeScreenState();
}

class _VendorJoiningFeeScreenState extends State<VendorJoiningFeeScreen> {
  String? vendorId;
  final String baseUrl = "https://api.vegiffyy.com/api";

  final int GST_RATE = 18;

  bool loading = false;
  bool plansLoading = true;
  String error = "";

  List<Map<String, dynamic>> plans = [];
  Map<String, dynamic>? selectedPlan;
  Map<String, dynamic>? vendor;

  // Bank transfer related variables
  bool showBankDetails = false;
  File? paymentScreenshot;
  String? screenshotPreviewPath;
  double uploadProgress = 0;
  bool uploading = false;

  // Track if user has started payment process
  bool hasStartedPayment = false;

  // Bank account details (hardcoded as in React)
  final Map<String, String> bankAccountDetails = {
    "accountName": "JAINITY EATS INDIA PRIVATE LIMITED",
    "accountNumber": "259391973675",
    "bankName": "INDUSIND BANK",
    "ifscCode": "INDB0001764",
    "upiId": "9292103965-xad8-4@ybl",
    "accountType": "Current Account"
  };

  // WhatsApp contact for vendors
  final Map<String, String> whatsappContact = {
    "number": "9391973675",
    "message": "Hi, I have made payment for Vegiffy Vendor Program. Here is my payment screenshot:"
  };

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadVendor();
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
    fetchVendor();
    fetchPlans();
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    // If user hasn't started payment, allow normal back navigation
    if (!hasStartedPayment && !showBankDetails) {
      return true;
    }

    // Show confirmation dialog
    final bool? shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => true, // Allow dialog to be dismissed by back button
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[700],
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Exit App?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to exit the app?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.orange[800],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your payment progress will be lost if you exit now.',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              child: const Text(
                'STAY',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'EXIT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    return shouldPop ?? false;
  }

  /* ===================== API ===================== */

  Future<void> fetchVendor() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/vendor/profile/$vendorId"));
      final body = jsonDecode(res.body);

      if (body['success'] == true) {
        setState(() {
          vendor = body['data'];
        });
      }
    } catch (_) {}
  }

  Future<void> fetchPlans() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/admin/vendorplans"));
      final body = jsonDecode(res.body);

      if (body['success'] == true) {
        setState(() {
          plans = List<Map<String, dynamic>>.from(body['data']);
          if (plans.isNotEmpty) {
            selectedPlan = plans.first;
          }
        });
      }
    } catch (_) {
      setState(() {
        error = "Failed to load plans";
      });
    } finally {
      setState(() => plansLoading = false);
    }
  }

  /* ===================== GST ===================== */

  Map<String, int> gstCalc(num price) {
    final base = price.round();
    final gst = ((base * GST_RATE) / 100).round();
    return {
      "base": base,
      "gst": gst,
      "total": base + gst,
    };
  }

  /* ===================== SCREENSHOT PICKER ===================== */

  Future<void> _pickScreenshot() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();

        // Check file size (max 5MB)
        if (fileSize > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File size should be less than 5MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          paymentScreenshot = file;
          screenshotPreviewPath = pickedFile.path;
          error = '';
          hasStartedPayment = true; // Mark that user has started payment process
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error picking image: $e';
      });
    }
  }

  void _removeScreenshot() {
    setState(() {
      paymentScreenshot = null;
      screenshotPreviewPath = null;
      // Don't reset hasStartedPayment here as user might have other progress
    });
  }

  /* ===================== BANK PAYMENT ===================== */

  Future<void> handleBankPayment() async {
    if (selectedPlan == null) {
      setState(() {
        error = 'Please select a plan';
      });
      return;
    }

    setState(() {
      loading = true;
      uploading = true;
      uploadProgress = 0;
      error = '';
      hasStartedPayment = true;
    });

    try {
      if (vendorId == null) {
        setState(() {
          error = 'Please login again to continue';
          loading = false;
          uploading = false;
        });
        return;
      }

      final gst = gstCalc(selectedPlan!['price']);

      // Create bank details object
      final bankDetails = {
        'accountName': bankAccountDetails['accountName'],
        'accountNumber': bankAccountDetails['accountNumber'],
        'bankName': bankAccountDetails['bankName'],
        'ifscCode': bankAccountDetails['ifscCode'],
      };

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/vendor/pay/$vendorId"),
      );

      // Add fields
      request.fields['planId'] = selectedPlan!['_id'];
      request.fields['paymentMethod'] = 'bank_transfer';
      request.fields['bankDetails'] = jsonEncode(bankDetails);
      request.fields['amount'] = gst['total'].toString();
      request.fields['restaurantName'] = vendor?['restaurantName'] ?? 
          VendorPreferences.getVendor()?.restaurantName ?? 'N/A';

      // Add screenshot if selected
      if (paymentScreenshot != null) {
        var fileStream = http.ByteStream(paymentScreenshot!.openRead());
        var fileLength = await paymentScreenshot!.length();
        var multipartFile = http.MultipartFile(
          'paymentScreenshot',
          fileStream,
          fileLength,
          filename: path.basename(paymentScreenshot!.path),
        );
        request.files.add(multipartFile);
      }

      // Simulate upload progress (since http client doesn't provide progress easily)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            uploadProgress = 0.3;
          });
        }
      });

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            uploadProgress = 0.6;
          });
        }
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            uploadProgress = 0.9;
          });
        }
      });

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var body = jsonDecode(response.body);

      setState(() {
        uploadProgress = 1.0;
      });

      print("llllllllllllllllllllllllllllllllll$body");

      if (body['success'] == true) {
        // Save pending payment info to local storage
        final vendorData = VendorPreferences.getVendor();
        // if (vendorData != null) {
        //   vendorData.currentPlan = selectedPlan!['_id'];
        //   vendorData.planStatus = 'pending_verification';
        //   vendorData.pendingPlan = selectedPlan!['_id'];
        //   await VendorPreferences.saveVendor(vendorData);
        // }

        if (mounted) {
          // Navigate to success screen and remove all previous routes
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => VendorJoiningSuccessScreen(
                plan: selectedPlan!,
              ),
            ),
            (route) => false, // Remove all previous routes
          );
        }
      } else {
        setState(() {
          error = body['message'] ?? 'Bank payment submission failed';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Bank payment submission failed. Please try again.';
      });
    } finally {
      setState(() {
        loading = false;
        uploading = false;
        uploadProgress = 0;
      });
    }
  }

  /* ===================== UI ===================== */

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5FDF9),
        appBar: AppBar(
          title: const Text("Activate Restaurant"),
          backgroundColor: Colors.green,
          elevation: 0,
        ),
        body: plansLoading
            ? const Center(child: CircularProgressIndicator())
            : _body(),
      ),
    );
  }

  Widget _body() {
    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("No plans available"),
            const SizedBox(height: 8),
            Text(
              "Please contact support",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final gst = selectedPlan != null
        ? gstCalc(selectedPlan!['price'])
        : {"base": 0, "gst": 0, "total": 0};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _vendorCard(),
          const SizedBox(height: 16),

          /// PLANS
          ...plans.map(_planCard).toList(),

          const SizedBox(height: 16),

          /// PAYMENT SUMMARY
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row("Plan Price", "₹${gst['base']}"),
                  _row("GST (18%)", "₹${gst['gst']}"),
                  const Divider(height: 24),
                  _row(
                    "Total",
                    "₹${gst['total']}",
                    bold: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// BANK DETAILS TOGGLE
          if (!showBankDetails)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showBankDetails = true;
                  hasStartedPayment = true; // Mark that user has started payment process
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Pay via Bank Transfer",
                style: TextStyle(fontSize: 18),
              ),
            ),

          if (showBankDetails) _buildBankTransferSection(gst),

          const SizedBox(height: 16),

          /// BACK BUTTON
          if (showBankDetails)
            TextButton(
              onPressed: () async {
                // Show confirmation before going back if there's progress
                if (paymentScreenshot != null || hasStartedPayment) {
                  final shouldGoBack = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text('Discard Changes?'),
                      content: const Text(
                        'Are you sure you want to go back? Your payment progress will be lost.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('CANCEL'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('DISCARD'),
                        ),
                      ],
                    ),
                  );

                  if (shouldGoBack == true) {
                    setState(() {
                      showBankDetails = false;
                      paymentScreenshot = null;
                      screenshotPreviewPath = null;
                      hasStartedPayment = false;
                    });
                  }
                } else {
                  setState(() {
                    showBankDetails = false;
                  });
                }
              },
              child: const Text(
                "Back to Plans",
                style: TextStyle(color: Colors.grey),
              ),
            ),

          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          const SizedBox(height: 16),

          /// SECURITY NOTE
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.security, size: 16, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  "Secure banking • Manual verification within 1-2 hours",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// SUPPORT INFO
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.call, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  "Need help? WhatsApp: ${whatsappContact['number']}",
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferSection(Map<String, int> gst) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bank Transfer Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Offline Payment",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...bankAccountDetails.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key.replaceAllMapped(
                            RegExp(r'([A-Z])'),
                            (match) => ' ${match.group(1)}',
                          ).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Copy to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${entry.key} copied to clipboard'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Copy",
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 16),

          /// IMPORTANT INSTRUCTIONS
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.yellow[800], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Important Instructions",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "• Transfer ₹${gst['total']} (₹${gst['base']} + ₹${gst['gst']} GST)\n"
                        "• Plan will be activated after manual verification (1-2 hours)\n"
                        "• Include your Restaurant Name in payment description\n"
                        "• Upload screenshot below OR send to WhatsApp: ${whatsappContact['number']}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.yellow[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// SCREENSHOT UPLOAD SECTION
          _buildScreenshotUploadSection(),

          const SizedBox(height: 16),

          /// UPLOAD PROGRESS
          if (uploading)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Uploading...",
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${(uploadProgress * 100).toInt()}%",
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: uploadProgress,
                  backgroundColor: Colors.blue.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                ),
              ],
            ),

          const SizedBox(height: 16),

          /// SUBMIT BUTTON
          ElevatedButton(
            onPressed: (loading || uploading) ? null : handleBankPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: loading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text("Processing..."),
                    ],
                  )
                : const Text(
                    "Submit Payment Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),

          const SizedBox(height: 8),

          Text(
            "Screenshot upload is optional but recommended for faster verification.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.camera_alt, size: 18, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Text(
              "Payment Receipt Proof",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "Optional",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (paymentScreenshot == null)
          GestureDetector(
            onTap: _pickScreenshot,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade300, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue.shade50,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.upload,
                      size: 32,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Upload Payment Receipt",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Screenshot or photo of bank transfer",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Choose File",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "JPG, PNG (Max 5MB)",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                if (screenshotPreviewPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(screenshotPreviewPath!),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.file_present, color: Colors.blue[700]),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        path.basename(paymentScreenshot!.path),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "✓ File uploaded successfully",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _removeScreenshot,
                  icon: Icon(Icons.close, color: Colors.red[400]),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),

        /// WhatsApp option
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.call, color: Colors.green[700], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Send via WhatsApp",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    Text(
                      "Send screenshot to: ${whatsappContact['number']}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vendorCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.store, color: Colors.green[700], size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor?['restaurantName'] ?? "Your Restaurant",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vendor?['locationName'] ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planCard(Map<String, dynamic> plan) {
    final selected = selectedPlan?['_id'] == plan['_id'];
    final gst = gstCalc(plan['price']);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = plan;
          // Reset payment progress when changing plans
          paymentScreenshot = null;
          screenshotPreviewPath = null;
          showBankDetails = false;
          hasStartedPayment = false;
          error = '';
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: selected ? Colors.green.shade50 : Colors.white,
          elevation: selected ? 4 : 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              plan['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "₹${plan['price']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (plan['tagline'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          plan['tagline'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      ...List<String>.from(plan['benefits'] ?? [])
                          .take(3)
                          .map((benefit) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Colors.green[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        benefit,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${plan['validity']} days validity",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String t, String v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            t,
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            v,
            style: TextStyle(
              fontSize: bold ? 18 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? Colors.green[700] : null,
            ),
          ),
        ],
      ),
    );
  }
}