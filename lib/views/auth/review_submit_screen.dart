// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class ReviewSubmitScreen extends StatefulWidget {
//   final Map<String, dynamic> formData;
//   final Map<String, File?> files;
//   final VoidCallback onBack;

//   const ReviewSubmitScreen({
//     super.key,
//     required this.formData,
//     required this.files,
//     required this.onBack,
//   });

//   @override
//   State<ReviewSubmitScreen> createState() => _ReviewSubmitScreenState();
// }

// class _ReviewSubmitScreenState extends State<ReviewSubmitScreen> {
//   bool _isSubmitting = false;
//   double _uploadProgress = 0.0;

//   Future<void> _submitRegistration() async {
//     // Show confirmation dialog
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Confirm Submission'),
//         content: const Text(
//           'Are you sure you want to submit your registration? Please ensure all information is correct.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('CANCEL'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('SUBMIT'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed != true) return;

//     setState(() {
//       _isSubmitting = true;
//       _uploadProgress = 0.0;
//     });

//     try {
//       final uri = Uri.parse("https://api.vegiffy.in/api/restaurant");
//       final request = http.MultipartRequest("POST", uri);

//       // Add form fields
//       widget.formData.forEach((key, value) {
//         if (value.toString().isNotEmpty && key != 'confirmPassword') {
//           request.fields[key] = value.toString();
//         }
//       });

//       // Add files
//       for (final entry in widget.files.entries) {
//         if (entry.value != null) {
//           request.files.add(
//             await http.MultipartFile.fromPath(
//               entry.key,
//               entry.value!.path,
//             ),
//           );
//         }
//       }

//       // Send request
//      final streamedResponse = await request.send();

// // ✅ Print status code
// debugPrint("🟢 STATUS CODE: ${streamedResponse.statusCode}");

// // ✅ Convert stream → response (ONLY ONCE)
// final response = await http.Response.fromStream(streamedResponse);

// // ✅ Print response body
// debugPrint("🟢 RESPONSE BODY:");
// debugPrint(response.body);

// // (Optional) Print headers
// debugPrint("🟢 RESPONSE HEADERS:");
// debugPrint(response.headers.toString());

// setState(() => _isSubmitting = false);

// // Decode safely
// final data = jsonDecode(response.body);

// if (data["success"] == true && mounted) {
//   _showSuccessDialog();
// } else {
//   _showError(data["message"] ?? "Registration failed. Please try again.");
// }

//     } catch (e) {
//       setState(() => _isSubmitting = false);
//       _showError("Network error. Please check your connection and try again.");
//     }
//   }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.green[50],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.check_circle,
//                 color: Colors.green[600],
//                 size: 64,
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Registration Successful!',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Your restaurant has been successfully registered. Our team will review your application and get back to you within 24-48 hours.',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context); // Close dialog
//                   Navigator.pop(context); // Go back to previous screen
//                 },
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text('Done'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 4),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: ListView(
//             padding: const EdgeInsets.all(20),
//             children: [
//               const Text(
//                 'Review & Submit',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Please review all your details before submitting',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Basic Information
//               _buildSection(
//                 title: 'Basic Information',
//                 icon: Icons.info_outline,
//                 children: [
//                   _buildInfoRow('Restaurant Name', widget.formData['restaurantName']),
//                   _buildInfoRow('Description', widget.formData['description']),
//                   _buildInfoRow('Location Name', widget.formData['locationName']),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // Contact Information
//               _buildSection(
//                 title: 'Contact Information',
//                 icon: Icons.contact_mail,
//                 children: [
//                   _buildInfoRow('Email', widget.formData['email']),
//                   _buildInfoRow('Mobile', widget.formData['mobile']),
//                   if (widget.formData['gstNumber']?.isNotEmpty ?? false)
//                     _buildInfoRow('GST Number', widget.formData['gstNumber']),
//                   if (widget.formData['referralCode']?.isNotEmpty ?? false)
//                     _buildInfoRow('Referral Code', widget.formData['referralCode']),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // Location Details
//               _buildSection(
//                 title: 'Location Details',
//                 icon: Icons.location_on,
//                 children: [
//                   _buildInfoRow('Latitude', widget.formData['lat']),
//                   _buildInfoRow('Longitude', widget.formData['lng']),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // Business Settings
//               _buildSection(
//                 title: 'Business Settings',
//                 icon: Icons.business_center,
//                 children: [
//                   _buildInfoRow('Commission', '${widget.formData['commission']}%'),
//                   _buildInfoRow('Discount', '${widget.formData['discount']}%'),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // Uploaded Documents
//               _buildSection(
//                 title: 'Uploaded Documents',
//                 icon: Icons.folder_open,
//                 children: widget.files.entries
//                     .where((e) => e.value != null)
//                     .map((e) => _buildDocumentRow(
//                           _formatDocumentName(e.key),
//                           e.value!.path.split('/').last,
//                         ))
//                     .toList(),
//               ),

//               const SizedBox(height: 24),

//               // Terms & Conditions
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.blue[200]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.verified_user, color: Colors.blue[700], size: 20),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Terms & Conditions',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue[900],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'By submitting this registration, you agree to our terms and conditions, privacy policy, and vendor agreement. All information provided will be verified by our team.',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.blue[900],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Loading indicator
//         if (_isSubmitting)
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             color: Colors.white,
//             child: Column(
//               children: [
//                 const Text(
//                   'Submitting your registration...',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 LinearProgressIndicator(
//                   value: _uploadProgress > 0 ? _uploadProgress : null,
//                   backgroundColor: Colors.grey[200],
//                 ),
//               ],
//             ),
//           ),

//         // Bottom buttons
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, -5),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: _isSubmitting ? null : widget.onBack,
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     side: BorderSide(color: Colors.grey[300]!),
//                   ),
//                   child: const Text(
//                     'Back',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 flex: 2,
//                 child: ElevatedButton(
//                   onPressed: _isSubmitting ? null : _submitRegistration,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: _isSubmitting
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         )
//                       : const Text(
//                           'Submit Registration',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSection({
//     required String title,
//     required IconData icon,
//     required List<Widget> children,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[300]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).primaryColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           ...children,
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, dynamic value) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: Colors.grey[200]!),
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value?.toString() ?? 'N/A',
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDocumentRow(String label, String fileName) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: Colors.grey[200]!),
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.check_circle, color: Colors.green[600], size: 18),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   fileName,
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.grey[500],
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDocumentName(String key) {
//     return key
//         .replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ')
//         .split(' ')
//         .map((word) => word[0].toUpperCase() + word.substring(1))
//         .join(' ');
//   }
// }

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReviewSubmitScreen extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Map<String, File?> files;
  final VoidCallback onBack;

  const ReviewSubmitScreen({
    super.key,
    required this.formData,
    required this.files,
    required this.onBack,
  });

  @override
  State<ReviewSubmitScreen> createState() => _ReviewSubmitScreenState();
}

class _ReviewSubmitScreenState extends State<ReviewSubmitScreen> {
  bool _isSubmitting = false;
  double _uploadProgress = 0.0;

  Future<void> _submitRegistration() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Submission'),
        content: const Text(
          'Are you sure you want to submit your registration? Please ensure all information is correct.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SUBMIT'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0.0;
    });

    try {
      final uri = Uri.parse("https://api.vegiffy.in/api/restaurant");
      final request = http.MultipartRequest("POST", uri);

      // Add form fields
      widget.formData.forEach((key, value) {
        if (value.toString().isNotEmpty && key != 'confirmPassword') {
          // Handle disclaimers array specially - convert to JSON string
          if (key == 'disclaimers' && value is List && value.isNotEmpty) {
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      // Add files
      for (final entry in widget.files.entries) {
        if (entry.value != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              entry.value!.path,
            ),
          );
        }
      }

      // Send request
      final streamedResponse = await request.send();

      // Print status code
      debugPrint("🟢 STATUS CODE: ${streamedResponse.statusCode}");

      // Convert stream → response (ONLY ONCE)
      final response = await http.Response.fromStream(streamedResponse);

      // Print response body
      debugPrint("🟢 RESPONSE BODY:");
      debugPrint(response.body);

      // (Optional) Print headers
      debugPrint("🟢 RESPONSE HEADERS:");
      debugPrint(response.headers.toString());

      setState(() => _isSubmitting = false);

      // Decode safely
      final data = jsonDecode(response.body);

      if (data["success"] == true && mounted) {
        _showSuccessDialog();
      } else {
        _showError(data["message"] ?? "Registration failed. Please try again.");
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showError("Network error. Please check your connection and try again.");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Registration Successful!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your restaurant has been successfully registered. Our team will review your application and get back to you within 24-48 hours.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to previous screen
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Review & Submit',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please review all your details before submitting',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Basic Information
              _buildSection(
                title: 'Basic Information',
                icon: Icons.info_outline,
                children: [
                  _buildInfoRow(
                      'Restaurant Name', widget.formData['restaurantName']),
                  _buildInfoRow('Description', widget.formData['description']),
                  _buildInfoRow(
                      'Location Name', widget.formData['locationName']),
                  // 👇 NEW: Full Address
                  _buildInfoRow('Full Address', widget.formData['fullAddress']),
                  // 👇 NEW: FSSAI Number
                  _buildInfoRow('FSSAI Number', widget.formData['fssaiNo']),
                ],
              ),

              const SizedBox(height: 16),

              // Contact Information
              _buildSection(
                title: 'Contact Information',
                icon: Icons.contact_mail,
                children: [
                  _buildInfoRow('Email', widget.formData['email']),
                  _buildInfoRow('Mobile', widget.formData['mobile']),
                  if (widget.formData['gstNumber']?.isNotEmpty ?? false)
                    _buildInfoRow('GST Number', widget.formData['gstNumber']),
                  if (widget.formData['referralCode']?.isNotEmpty ?? false)
                    _buildInfoRow(
                        'Referral Code', widget.formData['referralCode']),
                ],
              ),

              const SizedBox(height: 16),

              // Location Details
              _buildSection(
                title: 'Location Details',
                icon: Icons.location_on,
                children: [
                  _buildInfoRow('Latitude', widget.formData['lat']),
                  _buildInfoRow('Longitude', widget.formData['lng']),
                ],
              ),

              const SizedBox(height: 16),

              // Business Settings
              _buildSection(
                title: 'Business Settings',
                icon: Icons.business_center,
                children: [
                  _buildInfoRow(
                      'Commission', '${widget.formData['commission']}%'),
                  _buildInfoRow('Discount', '${widget.formData['discount']}%'),
                ],
              ),

              const SizedBox(height: 16),

              // 👇 NEW: Disclaimers Section
              if (widget.formData['disclaimers'] != null &&
                  (widget.formData['disclaimers'] as List).isNotEmpty)
                _buildSection(
                  title: 'Additional Disclaimers',
                  icon: Icons.warning_amber,
                  children: (widget.formData['disclaimers'] as List)
                      .map((disclaimer) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${(widget.formData['disclaimers'] as List).indexOf(disclaimer) + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              disclaimer.toString(),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),

              // Uploaded Documents
              _buildSection(
                title: 'Uploaded Documents',
                icon: Icons.folder_open,
                children: widget.files.entries
                    .where((e) => e.value != null)
                    .map((e) => _buildDocumentRow(
                          _formatDocumentName(e.key),
                          e.value!.path.split('/').last,
                        ))
                    .toList(),
              ),

              const SizedBox(height: 24),

              // Terms & Conditions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_user,
                            color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'By submitting this registration, you agree to our terms and conditions, privacy policy, and vendor agreement. All information provided will be verified by our team.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Loading indicator
        if (_isSubmitting)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Column(
              children: [
                const Text(
                  'Submitting your registration...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _uploadProgress > 0 ? _uploadProgress : null,
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ),
          ),

        // Bottom buttons
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : widget.onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit Registration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon,
                      color: Theme.of(context).primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(String label, String fileName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDocumentName(String key) {
    return key
        .replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
