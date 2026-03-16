
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:vegiffyy_vendor/views/auth/basic_details_screen.dart';
// import 'package:vegiffyy_vendor/views/auth/download_forms_screen.dart';
// import 'package:vegiffyy_vendor/views/auth/location_screen.dart';
// import 'package:vegiffyy_vendor/views/auth/review_submit_screen.dart';
// import 'package:vegiffyy_vendor/views/auth/upload_documents_screen.dart';


// class VendorRegisterFlow extends StatefulWidget {
//   const VendorRegisterFlow({super.key});

//   @override
//   State<VendorRegisterFlow> createState() => _VendorRegisterFlowState();
// }

// class _VendorRegisterFlowState extends State<VendorRegisterFlow> {
//   int _currentStep = 0;
  
//   final Map<String, dynamic> formData = {
//     "restaurantName": "",
//     "description": "",
//     "locationName": "",
//     "email": "",
//     "mobile": "",
//     "gstNumber": "",
//     "referralCode": "",
//     "password": "",
//     "confirmPassword": "",
//     "lat": "",
//     "lng": "",
//     "commission": "",
//     "discount": "",
//   };

//   final Map<String, File?> files = {
//     "image": null,
//     "gstCertificate": null,
//     "fssaiLicense": null,
//     "panCard": null,
//     "aadharCardFront": null,
//     "aadharCardBack": null,
//   };

//   final List<String> _stepTitles = [
//     'Basic Details',
//     'Location',
//     'Documents',
//     'Forms',
//     'Review'
//   ];

//   void _nextStep() {
//     if (_currentStep < 4) {
//       setState(() => _currentStep++);
//     }
//   }

//   void _previousStep() {
//     if (_currentStep > 0) {
//       setState(() => _currentStep--);
//     }
//   }

//   Future<bool> _onWillPop() async {
//     if (_currentStep > 0) {
//       final shouldPop = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: const Text('Discard Registration?'),
//           content: const Text(
//             'Are you sure you want to go back? All your progress will be lost.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('CANCEL'),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context, true),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('DISCARD'),
//             ),
//           ],
//         ),
//       );
//       return shouldPop ?? false;
//     }
    
//     // First step - show exit confirmation
//     final shouldExit = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Exit Registration?'),
//         content: const Text('Are you sure you want to exit?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('CANCEL'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('EXIT'),
//           ),
//         ],
//       ),
//     );
//     return shouldExit ?? false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.grey[50],
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: Colors.white,
//           automaticallyImplyLeading: false,
//           systemOverlayStyle: SystemUiOverlayStyle.dark,
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Register Restaurant',
//                 style: TextStyle(
//                   color: Colors.grey[900],
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Step ${_currentStep + 1} of 5 - ${_stepTitles[_currentStep]}',
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 12,
//                   fontWeight: FontWeight.normal,
//                 ),
//               ),
//             ],
//           ),
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(6),
//             child: LinearProgressIndicator(
//               value: (_currentStep + 1) / 5,
//               backgroundColor: Colors.grey[200],
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 Theme.of(context).primaryColor,
//               ),
//             ),
//           ),
//         ),
//         body: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 350),
//           transitionBuilder: (child, animation) {
//             return FadeTransition(
//               opacity: animation,
//               child: SlideTransition(
//                 position: Tween<Offset>(
//                   begin: const Offset(0.05, 0),
//                   end: Offset.zero,
//                 ).animate(animation),
//                 child: child,
//               ),
//             );
//           },
//           child: _buildCurrentStep(),
//         ),
//       ),
//     );
//   }

//   Widget _buildCurrentStep() {
//     switch (_currentStep) {
//       case 0:
//         return BasicDetailsScreen(
//           key: const ValueKey(0),
//           formData: formData,
//           onNext: _nextStep,
//         );
//       case 1:
//         return LocationScreen(
//           key: const ValueKey(1),
//           formData: formData,
//           onNext: _nextStep,
//           onBack: _previousStep,
//         );
//       case 2:
//         return UploadDocumentsScreen(
//           key: const ValueKey(2),
//           files: files,
//           onNext: _nextStep,
//           onBack: _previousStep,
//         );
//       case 3:
//         return DownloadFormsScreen(
//           key: const ValueKey(3),
//           onNext: _nextStep,
//           onBack: _previousStep,
//         );
//       case 4:
//         return ReviewSubmitScreen(
//           key: const ValueKey(4),
//           formData: formData,
//           files: files,
//           onBack: _previousStep,
//         );
//       default:
//         return const SizedBox();
//     }
//   }
// }





























import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vegiffyy_vendor/views/auth/basic_details_screen.dart';
import 'package:vegiffyy_vendor/views/auth/download_forms_screen.dart';
import 'package:vegiffyy_vendor/views/auth/location_screen.dart';
import 'package:vegiffyy_vendor/views/auth/review_submit_screen.dart';
import 'package:vegiffyy_vendor/views/auth/upload_documents_screen.dart';


class VendorRegisterFlow extends StatefulWidget {
  const VendorRegisterFlow({super.key});

  @override
  State<VendorRegisterFlow> createState() => _VendorRegisterFlowState();
}

class _VendorRegisterFlowState extends State<VendorRegisterFlow> {
  int _currentStep = 0;
  
  final Map<String, dynamic> formData = {
    "restaurantName": "",
    "description": "",
    "locationName": "",
    "fullAddress": "", // 👈 NEW FIELD ADDED
    "email": "",
    "mobile": "",
    "gstNumber": "",
    "fssaiNo": "", // 👈 NEW FIELD ADDED
    "referralCode": "",
    "password": "",
    "confirmPassword": "",
    "lat": "",
    "lng": "",
    "commission": "",
    "discount": "",
    "disclaimers": [], // 👈 NEW FIELD ADDED (array for disclaimers)
  };

  final Map<String, File?> files = {
    "image": null,
    "gstCertificate": null,
    "fssaiLicense": null,
    "panCard": null,
    "aadharCardFront": null,
    "aadharCardBack": null,
  };

  final List<String> _stepTitles = [
    'Basic Details',
    'Location',
    'Documents',
    'Forms',
    'Review'
  ];

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentStep > 0) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Discard Registration?'),
          content: const Text(
            'Are you sure you want to go back? All your progress will be lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('DISCARD'),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    
    // First step - show exit confirmation
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit Registration?'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('EXIT'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Register Restaurant',
                style: TextStyle(
                  color: Colors.grey[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Step ${_currentStep + 1} of 5 - ${_stepTitles[_currentStep]}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 5,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return BasicDetailsScreen(
          key: const ValueKey(0),
          formData: formData,
          onNext: _nextStep,
        );
      case 1:
        return LocationScreen(
          key: const ValueKey(1),
          formData: formData,
          onNext: _nextStep,
          onBack: _previousStep,
        );
      case 2:
        return UploadDocumentsScreen(
          key: const ValueKey(2),
          files: files,
          onNext: _nextStep,
          onBack: _previousStep,
        );
      case 3:
        return DownloadFormsScreen( 
          key: const ValueKey(3),
          formData: formData, // 👈 IMPORTANT: Pass formData here
          onNext: _nextStep,
          onBack: _previousStep,
        );
      case 4:
        return ReviewSubmitScreen(
          key: const ValueKey(4),
          formData: formData,
          files: files,
          onBack: _previousStep,
        );
      default:
        return const SizedBox();
    }
  }
}