// import 'package:flutter/material.dart';

// class BasicDetailsScreen extends StatefulWidget {
//   final Map<String, dynamic> formData;
//   final VoidCallback onNext;

//   const BasicDetailsScreen({
//     super.key,
//     required this.formData,
//     required this.onNext,
//   });

//   @override
//   State<BasicDetailsScreen> createState() => _BasicDetailsScreenState();
// }

// class _BasicDetailsScreenState extends State<BasicDetailsScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _restaurantNameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _locationNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _mobileController = TextEditingController();
//   final _gstNumberController = TextEditingController();
//   final _referralCodeController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _commissionController = TextEditingController();
//   final _discountController = TextEditingController();

//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadExistingData();
//   }

//   void _loadExistingData() {
//     _restaurantNameController.text = widget.formData['restaurantName'] ?? '';
//     _descriptionController.text = widget.formData['description'] ?? '';
//     _locationNameController.text = widget.formData['locationName'] ?? '';
//     _emailController.text = widget.formData['email'] ?? '';
//     _mobileController.text = widget.formData['mobile'] ?? '';
//     _gstNumberController.text = widget.formData['gstNumber'] ?? '';
//     _referralCodeController.text = widget.formData['referralCode'] ?? '';
//     _passwordController.text = widget.formData['password'] ?? '';
//     _confirmPasswordController.text = widget.formData['confirmPassword'] ?? '';
//     _commissionController.text = widget.formData['commission'] ?? '';
//     _discountController.text = widget.formData['discount'] ?? '';
//   }

//   @override
//   void dispose() {
//     _restaurantNameController.dispose();
//     _descriptionController.dispose();
//     _locationNameController.dispose();
//     _emailController.dispose();
//     _mobileController.dispose();
//     _gstNumberController.dispose();
//     _referralCodeController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _commissionController.dispose();
//     _discountController.dispose();
//     super.dispose();
//   }

//   String? _validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Email is required';
//     }
//     final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//     if (!emailRegex.hasMatch(value)) {
//       return 'Enter a valid email address';
//     }
//     return null;
//   }

//   String? _validateMobile(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Mobile number is required';
//     }
//     if (value.length != 10) {
//       return 'Mobile number must be 10 digits';
//     }
//     if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//       return 'Enter a valid mobile number';
//     }
//     return null;
//   }

//   String? _validateGST(String? value) {
//     if (value == null || value.isEmpty) {
//       return null; // GST is optional
//     }
//     // if (value.length != 15) {
//     //   return 'GST number must be 15 characters';
//     // }
//     final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
//     // if (!gstRegex.hasMatch(value)) {
//     //   return 'Enter a valid GST number';
//     // }
//     return null;
//   }

//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }
//     if (value.length < 8) {
//       return 'Password must be at least 8 characters';
//     }
//     return null;
//   }

//   String? _validateConfirmPassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Confirm password is required';
//     }
//     if (value != _passwordController.text) {
//       return 'Passwords do not match';
//     }
//     return null;
//   }

//   void _handleNext() {
//     if (_formKey.currentState!.validate()) {
//       widget.formData['restaurantName'] = _restaurantNameController.text;
//       widget.formData['description'] = _descriptionController.text;
//       widget.formData['locationName'] = _locationNameController.text;
//       widget.formData['email'] = _emailController.text;
//       widget.formData['mobile'] = _mobileController.text;
//       widget.formData['gstNumber'] = _gstNumberController.text;
//       widget.formData['referralCode'] = _referralCodeController.text;
//       widget.formData['password'] = _passwordController.text;
//       widget.formData['confirmPassword'] = _confirmPasswordController.text;
//       widget.formData['commission'] = _commissionController.text;
//       widget.formData['discount'] = _discountController.text;

//       widget.onNext();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill all required fields correctly'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           const Text(
//             'Basic Information',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Let\'s start with your restaurant details',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 32),
          
//           _buildTextField(
//             controller: _restaurantNameController,
//             label: 'Restaurant Name',
//             icon: Icons.restaurant,
//             validator: (v) => v?.isEmpty ?? true ? 'Restaurant name is required' : null,
//           ),
          
//           const SizedBox(height: 16),
          
//           _buildTextField(
//             controller: _descriptionController,
//             label: 'Description',
//             icon: Icons.description,
//             maxLines: 3,
//             validator: (v) => v?.isEmpty ?? true ? 'Description is required' : null,
//           ),
          
//           const SizedBox(height: 16),
          
//           _buildTextField(
//             controller: _locationNameController,
//             label: 'Location Name',
//             icon: Icons.location_on,
//             validator: (v) => v?.isEmpty ?? true ? 'Location name is required' : null,
//           ),
          
//           const SizedBox(height: 24),
//           const Divider(),
//           const SizedBox(height: 16),
          
//           const Text(
//             'Contact Information',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
          
//           _buildTextField(
//             controller: _emailController,
//             label: 'Email Address',
//             icon: Icons.email,
//             keyboardType: TextInputType.emailAddress,
//             validator: _validateEmail,
//           ),
          
//           const SizedBox(height: 16),
          
//           _buildTextField(
//             controller: _mobileController,
//             label: 'Mobile Number',
//             icon: Icons.phone,
//             keyboardType: TextInputType.phone,
//             maxLength: 10,
//             validator: _validateMobile,
//           ),
          
//           const SizedBox(height: 16),
          
//           _buildTextField(
//             controller: _gstNumberController,
//             label: 'GST Number (Optional)',
//             icon: Icons.business,
//             validator: _validateGST,
//           ),
          
//           const SizedBox(height: 16),
          
//           _buildTextField(
//             controller: _referralCodeController,
//             label: 'Referral Code (Optional)',
//             icon: Icons.card_giftcard,
//           ),
          
//           const SizedBox(height: 24),
//           const Divider(),
//           const SizedBox(height: 16),
          
//           const Text(
//             'Account Security',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
          
//           _buildTextField(
//             controller: _passwordController,
//             label: 'Password',
//             icon: Icons.lock,
//             obscureText: _obscurePassword,
//             validator: _validatePassword,
//             suffixIcon: IconButton(
//               icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
//               onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//             ),
//           ),
          
//           const SizedBox(height: 16),
          
//           _buildTextField(
//             controller: _confirmPasswordController,
//             label: 'Confirm Password',
//             icon: Icons.lock_outline,
//             obscureText: _obscureConfirmPassword,
//             validator: _validateConfirmPassword,
//             suffixIcon: IconButton(
//               icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
//               onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
//             ),
//           ),
          
//           const SizedBox(height: 24),
//           const Divider(),
//           const SizedBox(height: 16),
          
//           const Text(
//             'Business Settings',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
          
//           Row(
//             children: [
//               Expanded(
//                 child: _buildTextField(
//                   controller: _commissionController,
//                   label: 'Commission %',
//                   icon: Icons.percent,
//                   keyboardType: TextInputType.number,
//                   validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _buildTextField(
//                   controller: _discountController,
//                   label: 'Discount %',
//                   icon: Icons.local_offer,
//                   keyboardType: TextInputType.number,
//                   validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
//                 ),
//               ),
//             ],
//           ),
          
//           const SizedBox(height: 40),
          
//           ElevatedButton(
//             onPressed: _handleNext,
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 2,
//             ),
//             child: const Text(
//               'Continue to Location',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
          
//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType? keyboardType,
//     bool obscureText = false,
//     int maxLines = 1,
//     int? maxLength,
//     String? Function(String?)? validator,
//     Widget? suffixIcon,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       obscureText: obscureText,
//       maxLines: maxLines,
//       maxLength: maxLength,
//       validator: validator,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon),
//         suffixIcon: suffixIcon,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red),
//         ),
//         filled: true,
//         fillColor: Colors.white,
//         counterText: '',
//       ),
//     );
//   }
// }
























import 'package:flutter/material.dart';

class BasicDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onNext;

  const BasicDetailsScreen({
    super.key,
    required this.formData,
    required this.onNext,
  });

  @override
  State<BasicDetailsScreen> createState() => _BasicDetailsScreenState();
}

class _BasicDetailsScreenState extends State<BasicDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _restaurantController = TextEditingController();
  final _locationController = TextEditingController();
  final _fullAddressController = TextEditingController(); // 👈 NEW
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _gstController = TextEditingController();
  final _fssaiNoController = TextEditingController(); // 👈 NEW
  final _referralController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _commissionController = TextEditingController();
  final _discountController = TextEditingController();
  final _descriptionController = TextEditingController(); // 👈 NEW
  
  // Disclaimers
  final List<String> _disclaimers = [];
  final _currentDisclaimerController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    _restaurantController.text = widget.formData['restaurantName'] ?? '';
    _locationController.text = widget.formData['locationName'] ?? '';
    _fullAddressController.text = widget.formData['fullAddress'] ?? ''; // 👈 NEW
    _emailController.text = widget.formData['email'] ?? '';
    _mobileController.text = widget.formData['mobile'] ?? '';
    _gstController.text = widget.formData['gstNumber'] ?? '';
    _fssaiNoController.text = widget.formData['fssaiNo'] ?? ''; // 👈 NEW
    _referralController.text = widget.formData['referralCode'] ?? '';
    _passwordController.text = widget.formData['password'] ?? '';
    _confirmController.text = widget.formData['confirmPassword'] ?? '';
    _commissionController.text = widget.formData['commission'] ?? '';
    _discountController.text = widget.formData['discount'] ?? '';
    _descriptionController.text = widget.formData['description'] ?? ''; // 👈 NEW
    
    // Load disclaimers if they exist
    if (widget.formData['disclaimers'] != null) {
      _disclaimers.addAll(List<String>.from(widget.formData['disclaimers']));
    }
  }

  @override
  void dispose() {
    _restaurantController.dispose();
    _locationController.dispose();
    _fullAddressController.dispose(); // 👈 NEW
    _emailController.dispose();
    _mobileController.dispose();
    _gstController.dispose();
    _fssaiNoController.dispose(); // 👈 NEW
    _referralController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _commissionController.dispose();
    _discountController.dispose();
    _descriptionController.dispose(); // 👈 NEW
    _currentDisclaimerController.dispose();
    super.dispose();
  }

  void _addDisclaimer() {
    if (_currentDisclaimerController.text.trim().isEmpty) {
      _showError('Please enter a disclaimer');
      return;
    }
    
    setState(() {
      _disclaimers.add(_currentDisclaimerController.text.trim());
      _currentDisclaimerController.clear();
    });
    
    _showSuccess('Disclaimer added successfully');
  }

  void _removeDisclaimer(int index) {
    setState(() {
      _disclaimers.removeAt(index);
    });
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) return 'Mobile number is required';
    if (value.length != 10) return 'Enter a valid 10-digit mobile number';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Enter numbers only';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? _validateCommission(String? value) {
    if (value == null || value.isEmpty) return 'Commission is required';
    final numValue = double.tryParse(value);
    if (numValue == null) return 'Enter a valid number';
    if (numValue < 0 || numValue > 50) return 'Commission must be between 0 and 50%';
    return null;
  }

  String? _validateDiscount(String? value) {
    if (value == null || value.isEmpty) return 'Discount is required';
    final numValue = double.tryParse(value);
    if (numValue == null) return 'Enter a valid number';
    if (numValue < 0 || numValue > 100) return 'Discount must be between 0 and 100%';
    return null;
  }

  String? _validateFssai(String? value) {
    if (value == null || value.isEmpty) return 'FSSAI License Number is required';
    return null;
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      // Save all form data
      widget.formData['restaurantName'] = _restaurantController.text;
      widget.formData['locationName'] = _locationController.text;
      widget.formData['fullAddress'] = _fullAddressController.text; // 👈 NEW
      widget.formData['email'] = _emailController.text;
      widget.formData['mobile'] = _mobileController.text;
      widget.formData['gstNumber'] = _gstController.text;
      widget.formData['fssaiNo'] = _fssaiNoController.text; // 👈 NEW
      widget.formData['referralCode'] = _referralController.text;
      widget.formData['password'] = _passwordController.text;
      widget.formData['confirmPassword'] = _confirmController.text;
      widget.formData['commission'] = _commissionController.text;
      widget.formData['discount'] = _discountController.text;
      widget.formData['description'] = _descriptionController.text; // 👈 NEW
      widget.formData['disclaimers'] = _disclaimers; // 👈 NEW
      
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Basic Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell us about your restaurant',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Restaurant Name
                TextFormField(
                  controller: _restaurantController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Restaurant name is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Restaurant Name *',
                    hintText: 'Enter your restaurant name',
                    prefixIcon: Icon(Icons.restaurant, color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Location Name
                TextFormField(
                  controller: _locationController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Location name is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Location Name (Area/Landmark) *',
                    hintText: 'e.g., Bolarum, Secunderabad',
                    prefixIcon: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 👇 NEW FIELD: Full Address
                TextFormField(
                  controller: _fullAddressController,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Full address is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Full Address *',
                    hintText: 'Enter complete address with street, building, landmark, city, pincode',
                    prefixIcon: Icon(Icons.location_city, color: Theme.of(context).primaryColor),
                    helperText: 'Please provide complete address for delivery and verification',
                    helperStyle: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Email *',
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(Icons.email, color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Mobile
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: _validateMobile,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number *',
                    hintText: '10-digit mobile number',
                    prefixIcon: Icon(Icons.phone, color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 👇 NEW FIELD: FSSAI License Number
                TextFormField(
                  controller: _fssaiNoController,
                  validator: _validateFssai,
                  decoration: InputDecoration(
                    labelText: 'FSSAI License Number *',
                    hintText: 'Enter FSSAI license number',
                    prefixIcon: Icon(Icons.shield, color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // GST Number (Optional)
                TextFormField(
                  controller: _gstController,
                  decoration: InputDecoration(
                    labelText: 'GST Number (Optional)',
                    hintText: 'Enter GST number',
                    prefixIcon: Icon(Icons.business, color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    hintText: 'Minimum 6 characters',
                    prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Confirm Password
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password *',
                    prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Commission %
                TextFormField(
                  controller: _commissionController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateCommission,
                  decoration: InputDecoration(
                    labelText: 'Commission % *',
                    hintText: '0-50%',
                    prefixIcon: Icon(Icons.percent, color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Discount %
                TextFormField(
                  controller: _discountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateDiscount,
                  decoration: InputDecoration(
                    labelText: 'Discount % *',
                    hintText: '0-100%',
                    prefixIcon: Icon(Icons.discount, color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 👇 NEW FIELD: Description (Optional)
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Restaurant Description (Optional)',
                    hintText: 'Brief description about your restaurant...',
                    prefixIcon: Icon(Icons.description, color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Referral Code (Optional)
                TextFormField(
                  controller: _referralController,
                  decoration: InputDecoration(
                    labelText: 'Referral Code (Optional)',
                    hintText: 'Enter referral code',
                    prefixIcon: Icon(Icons.star, color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 👇 NEW SECTION: Disclaimers
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
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
                          Icon(Icons.warning_amber, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Additional Disclaimers',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add disclaimers about your restaurant (e.g., "Pure Jain Food", "No onion garlic", etc.)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Add disclaimer input
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _currentDisclaimerController,
                              decoration: InputDecoration(
                                hintText: 'Enter disclaimer...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.orange[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.orange[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.orange, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              onFieldSubmitted: (_) => _addDisclaimer(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _addDisclaimer,
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // List of added disclaimers
                      if (_disclaimers.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Added Disclaimers:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        ..._disclaimers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final disclaimer = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[800],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    disclaimer,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _removeDisclaimer(index),
                                  tooltip: 'Remove',
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      
                      if (_disclaimers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No disclaimers added yet',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // Bottom button
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
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Continue to Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}