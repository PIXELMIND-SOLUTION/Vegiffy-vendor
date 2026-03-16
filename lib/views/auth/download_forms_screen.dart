// import 'package:flutter/material.dart';
// import 'package:vegiffyy_vendor/helper/pdf_form.dart';

// class DownloadFormsScreen extends StatefulWidget {
//   final VoidCallback onNext;
//   final VoidCallback onBack;

//   const DownloadFormsScreen({
//     super.key,
//     required this.onNext,
//     required this.onBack,
//   });

//   @override
//   State<DownloadFormsScreen> createState() => _DownloadFormsScreenState();
// }

// class _DownloadFormsScreenState extends State<DownloadFormsScreen> {
//   bool _declarationDownloaded = false;
//   bool _agreementDownloaded = false;
//   bool _isDownloading = false;

//   Future<void> _downloadPdf({
//     required String assetPath,
//     required String fileName,
//     required bool isDeclaration,
//   }) async {
//     setState(() => _isDownloading = true);

//     try {
//       await downloadAndOpenPdf(
//         assetPath: assetPath,
//         fileName: fileName,
//       );

//       setState(() {
//         if (isDeclaration) {
//           _declarationDownloaded = true;
//         } else {
//           _agreementDownloaded = true;
//         }
//         _isDownloading = false;
//       });

//       _showSuccess('$fileName downloaded successfully');
//     } catch (e) {
//       setState(() => _isDownloading = false);
//       _showError('Failed to download: ${e.toString()}');
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   bool _canProceed() {
//     return _declarationDownloaded && _agreementDownloaded;
//   }

//   void _handleNext() {
//     if (_canProceed()) {
//       widget.onNext();
//     } else {
//       _showError('Please download and review both documents before proceeding');
//     }
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
//                 'Legal Documents',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Please download and review the following documents carefully',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               const SizedBox(height: 32),
              
//               // Declaration card
//               _buildDocumentCard(
//                 title: 'Vegiffyy Declaration',
//                 description: 'Official declaration form that outlines your responsibilities as a vendor partner',
//                 icon: Icons.description,
//                 iconColor: Colors.blue,
//                 isDownloaded: _declarationDownloaded,
//                 onDownload: () => _downloadPdf(
//                   assetPath: 'assets/pdfs/declaration.pdf',
//                   fileName: 'Vegiffyy_Declaration.pdf',
//                   isDeclaration: true,
//                 ),
//               ),
              
//               const SizedBox(height: 16),
              
//               // Agreement card
//               _buildDocumentCard(
//                 title: 'Vendor Agreement',
//                 description: 'Terms and conditions of partnership between you and Vegiffyy',
//                 icon: Icons.article,
//                 iconColor: Colors.purple,
//                 isDownloaded: _agreementDownloaded,
//                 onDownload: () => _downloadPdf(
//                   assetPath: 'assets/pdfs/vendor_agreement.pdf',
//                   fileName: 'Vegiffyy_Vendor_Agreement.pdf',
//                   isDeclaration: false,
//                 ),
//               ),
              
//               const SizedBox(height: 24),
              
//               // Info card
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.orange[50],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.orange[200]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.lightbulb_outline, color: Colors.orange[700], size: 20),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Important Information',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.orange[900],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     _buildInfoPoint('Please read all documents carefully before proceeding'),
//                     _buildInfoPoint('You will need to print, sign, and upload these documents'),
//                     _buildInfoPoint('Keep copies of all signed documents for your records'),
//                     _buildInfoPoint('Contact support if you have any questions'),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 24),
              
//               // Progress indicator
//               if (_declarationDownloaded || _agreementDownloaded)
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Theme.of(context).primaryColor.withOpacity(0.1),
//                         Theme.of(context).primaryColor.withOpacity(0.05),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Download Progress',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                           Text(
//                             '${(_declarationDownloaded ? 1 : 0) + (_agreementDownloaded ? 1 : 0)}/2 completed',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: LinearProgressIndicator(
//                           value: ((_declarationDownloaded ? 1 : 0) + (_agreementDownloaded ? 1 : 0)) / 2,
//                           minHeight: 8,
//                           backgroundColor: Colors.grey[300],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
        
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
//                   onPressed: widget.onBack,
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
//                   onPressed: _canProceed() ? _handleNext : null,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: const Text(
//                     'Continue to Review',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDocumentCard({
//     required String title,
//     required String description,
//     required IconData icon,
//     required Color iconColor,
//     required bool isDownloaded,
//     required VoidCallback onDownload,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: isDownloaded ? Colors.green[300]! : Colors.grey[300]!,
//           width: isDownloaded ? 2 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: isDownloaded ? Colors.green[50] : iconColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     isDownloaded ? Icons.check_circle : icon,
//                     color: isDownloaded ? Colors.green : iconColor,
//                     size: 32,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       if (isDownloaded)
//                         Row(
//                           children: [
//                             Icon(Icons.check, size: 14, color: Colors.green[700]),
//                             const SizedBox(width: 4),
//                             Text(
//                               'Downloaded',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.green[700],
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               description,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Colors.grey[600],
//                 height: 1.4,
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _isDownloading ? null : onDownload,
//                 icon: _isDownloading 
//                   ? const SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                   : Icon(isDownloaded ? Icons.download_done : Icons.download),
//                 label: Text(
//                   _isDownloading 
//                     ? 'Downloading...' 
//                     : isDownloaded 
//                       ? 'Download Again' 
//                       : 'Download PDF',
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isDownloaded ? Colors.grey[600] : null,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoPoint(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 4, top: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '• ',
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.orange[700],
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.orange[900],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




























import 'package:flutter/material.dart';
import 'package:vegiffyy_vendor/helper/pdf_form.dart';

class DownloadFormsScreen extends StatefulWidget {
  final Map<String, dynamic> formData; // 👈 Add this
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DownloadFormsScreen({
    super.key,
    required this.formData, // 👈 Add this
    required this.onNext,
    required this.onBack,
  });

  @override
  State<DownloadFormsScreen> createState() => _DownloadFormsScreenState();
}

class _DownloadFormsScreenState extends State<DownloadFormsScreen> {
  bool _declarationDownloaded = false;
  bool _agreementDownloaded = false;
  bool _isDownloading = false;

  // 👇 Update to use dynamic PDF generation
  Future<void> _downloadDeclaration() async {
    setState(() => _isDownloading = true);

    try {
      // Generate declaration PDF with restaurant data
      await generateDeclarationPDF(
        restaurantName: widget.formData['restaurantName'] ?? '',
        fssaiNo: widget.formData['fssaiNo'] ?? '',
        fullAddress: widget.formData['fullAddress'] ?? '',
        locationName: widget.formData['locationName'] ?? '',
        mobile: widget.formData['mobile'] ?? '',
        disclaimers: widget.formData['disclaimers'] is List 
            ? List<String>.from(widget.formData['disclaimers']) 
            : [],
      );

      setState(() {
        _declarationDownloaded = true;
        _isDownloading = false;
      });

      _showSuccess('Declaration form downloaded successfully');
    } catch (e) {
      setState(() => _isDownloading = false);
      _showError('Failed to download: ${e.toString()}');
    }
  }

  // 👇 Update to use dynamic PDF generation
  Future<void> _downloadAgreement() async {
    setState(() => _isDownloading = true);

    try {
      // Generate agreement PDF with restaurant data
      await generateAgreementPDF(
        restaurantName: widget.formData['restaurantName'] ?? '',
        fssaiNo: widget.formData['fssaiNo'] ?? '',
        fullAddress: widget.formData['fullAddress'] ?? '',
        locationName: widget.formData['locationName'] ?? '',
        commission: widget.formData['commission'] ?? '',
        disclaimers: widget.formData['disclaimers'] is List 
            ? List<String>.from(widget.formData['disclaimers']) 
            : [],
      );

      setState(() {
        _agreementDownloaded = true;
        _isDownloading = false;
      });

      _showSuccess('Vendor agreement downloaded successfully');
    } catch (e) {
      setState(() => _isDownloading = false);
      _showError('Failed to download: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _canProceed() {
    return _declarationDownloaded && _agreementDownloaded;
  }

  void _handleNext() {
    if (_canProceed()) {
      widget.onNext();
    } else {
      _showError('Please download and review both documents before proceeding');
    }
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
                'Legal Documents',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please download and review the following documents carefully',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              // 👇 NEW: Restaurant Info Card
              if (widget.formData['restaurantName'] != null && 
                  widget.formData['restaurantName'].toString().isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.restaurant, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Your Restaurant Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Name', widget.formData['restaurantName']),
                      if (widget.formData['fssaiNo']?.isNotEmpty ?? false)
                        _buildInfoRow('FSSAI No', widget.formData['fssaiNo']),
                      if (widget.formData['fullAddress']?.isNotEmpty ?? false)
                        _buildInfoRow('Address', widget.formData['fullAddress']),
                      if (widget.formData['mobile']?.isNotEmpty ?? false)
                        _buildInfoRow('Mobile', widget.formData['mobile']),
                    ],
                  ),
                ),
              
              // Declaration card - Updated to use dynamic generation
              _buildDocumentCard(
                title: 'Vegiffy Declaration',
                description: 'Official declaration form that outlines your responsibilities as a vendor partner',
                icon: Icons.description,
                iconColor: Colors.blue,
                isDownloaded: _declarationDownloaded,
                onDownload: _downloadDeclaration, // 👈 Updated
              ),
              
              const SizedBox(height: 16),
              
              // Agreement card - Updated to use dynamic generation
              _buildDocumentCard(
                title: 'Vendor Agreement',
                description: 'Terms and conditions of partnership between you and Vegiffy',
                icon: Icons.article,
                iconColor: Colors.purple,
                isDownloaded: _agreementDownloaded,
                onDownload: _downloadAgreement, // 👈 Updated
              ),
              
              const SizedBox(height: 24),
              
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Important Information',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoPoint('Please read all documents carefully before proceeding'),
                    _buildInfoPoint('You will need to print, sign, and upload these documents'),
                    _buildInfoPoint('Keep copies of all signed documents for your records'),
                    _buildInfoPoint('Contact support if you have any questions'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Progress indicator
              if (_declarationDownloaded || _agreementDownloaded)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Download Progress',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '${(_declarationDownloaded ? 1 : 0) + (_agreementDownloaded ? 1 : 0)}/2 completed',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: ((_declarationDownloaded ? 1 : 0) + (_agreementDownloaded ? 1 : 0)) / 2,
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
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
                  onPressed: widget.onBack,
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
                  onPressed: _canProceed() ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Continue to Review',
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

  Widget _buildDocumentCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required bool isDownloaded,
    required VoidCallback onDownload,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDownloaded ? Colors.green[300]! : Colors.grey[300]!,
          width: isDownloaded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDownloaded ? Colors.green[50] : iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDownloaded ? Icons.check_circle : icon,
                    color: isDownloaded ? Colors.green : iconColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isDownloaded)
                        Row(
                          children: [
                            Icon(Icons.check, size: 14, color: Colors.green[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Downloaded',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isDownloading ? null : onDownload,
                icon: _isDownloading 
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(isDownloaded ? Icons.download_done : Icons.download),
                label: Text(
                  _isDownloading 
                    ? 'Downloading...' 
                    : isDownloaded 
                      ? 'Download Again' 
                      : 'Download PDF',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDownloaded ? Colors.grey[600] : null,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.orange[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}