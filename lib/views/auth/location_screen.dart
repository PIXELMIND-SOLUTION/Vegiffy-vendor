// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// class LocationScreen extends StatefulWidget {
//   final Map<String, dynamic> formData;
//   final VoidCallback onNext;
//   final VoidCallback onBack;

//   const LocationScreen({
//     super.key,
//     required this.formData,
//     required this.onNext,
//     required this.onBack,
//   });

//   @override
//   State<LocationScreen> createState() => _LocationScreenState();
// }

// class _LocationScreenState extends State<LocationScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _latController = TextEditingController();
//   final _lngController = TextEditingController();
  
//   bool _isFetching = false;
//   bool _locationFetched = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadExistingData();
//   }

//   void _loadExistingData() {
//     _latController.text = widget.formData['lat'] ?? '';
//     _lngController.text = widget.formData['lng'] ?? '';
//     if (_latController.text.isNotEmpty && _lngController.text.isNotEmpty) {
//       _locationFetched = true;
//     }
//   }

//   @override
//   void dispose() {
//     _latController.dispose();
//     _lngController.dispose();
//     super.dispose();
//   }

//   String? _validateCoordinate(String? value, String type) {
//     if (value == null || value.isEmpty) {
//       return '$type is required';
//     }
    
//     final coordinate = double.tryParse(value);
//     if (coordinate == null) {
//       return 'Enter a valid $type';
//     }
    
//     if (type == 'Latitude' && (coordinate < -90 || coordinate > 90)) {
//       return 'Latitude must be between -90 and 90';
//     }
    
//     if (type == 'Longitude' && (coordinate < -180 || coordinate > 180)) {
//       return 'Longitude must be between -180 and 180';
//     }
    
//     return null;
//   }

//   Future<void> _getCurrentLocation() async {
//     setState(() => _isFetching = true);

//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
      
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           _showError('Location permission denied. Please enable location access.');
//           setState(() => _isFetching = false);
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         _showError('Location permissions are permanently denied. Please enable them from settings.');
//         setState(() => _isFetching = false);
//         return;
//       }

//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       setState(() {
//         _latController.text = position.latitude.toStringAsFixed(6);
//         _lngController.text = position.longitude.toStringAsFixed(6);
//         _locationFetched = true;
//         _isFetching = false;
//       });

//       _showSuccess('Location fetched successfully!');
//     } catch (e) {
//       _showError('Failed to get location: ${e.toString()}');
//       setState(() => _isFetching = false);
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
//       ),
//     );
//   }

//   void _handleNext() {
//     if (_formKey.currentState!.validate()) {
//       widget.formData['lat'] = _latController.text;
//       widget.formData['lng'] = _lngController.text;
//       widget.onNext();
//     } else {
//       _showError('Please provide valid coordinates');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.all(20),
//               children: [
//                 const Text(
//                   'Restaurant Location',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'We need your exact location to serve customers better',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 32),
                
//                 // Location fetch card
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Theme.of(context).primaryColor.withOpacity(0.1),
//                         Theme.of(context).primaryColor.withOpacity(0.05),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: Theme.of(context).primaryColor.withOpacity(0.2),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Icon(
//                         _locationFetched ? Icons.location_on : Icons.location_searching,
//                         size: 64,
//                         color: _locationFetched 
//                           ? Colors.green 
//                           : Theme.of(context).primaryColor,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         _locationFetched 
//                           ? 'Location Captured!' 
//                           : 'Tap to Get Current Location',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey[800],
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         _locationFetched 
//                           ? 'You can manually adjust if needed' 
//                           : 'Make sure your GPS is enabled',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[600],
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: _isFetching ? null : _getCurrentLocation,
//                           icon: _isFetching 
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                 ),
//                               )
//                             : const Icon(Icons.my_location),
//                           label: Text(
//                             _isFetching 
//                               ? 'Fetching Location...' 
//                               : _locationFetched 
//                                 ? 'Refresh Location' 
//                                 : 'Get Current Location',
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 const SizedBox(height: 32),
                
//                 const Row(
//                   children: [
//                     Expanded(child: Divider()),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       child: Text(
//                         'OR ENTER MANUALLY',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     Expanded(child: Divider()),
//                   ],
//                 ),
                
//                 const SizedBox(height: 32),
                
//                 TextFormField(
//                   controller: _latController,
//                   keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                   validator: (v) => _validateCoordinate(v, 'Latitude'),
//                   decoration: InputDecoration(
//                     labelText: 'Latitude',
//                     hintText: 'e.g., 12.9716',
//                     prefixIcon: const Icon(Icons.place),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey[300]!),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                         color: Theme.of(context).primaryColor,
//                         width: 2,
//                       ),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                 ),
                
//                 const SizedBox(height: 16),
                
//                 TextFormField(
//                   controller: _lngController,
//                   keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                   validator: (v) => _validateCoordinate(v, 'Longitude'),
//                   decoration: InputDecoration(
//                     labelText: 'Longitude',
//                     hintText: 'e.g., 77.5946',
//                     prefixIcon: const Icon(Icons.place),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey[300]!),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                         color: Theme.of(context).primaryColor,
//                         width: 2,
//                       ),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                 ),
                
//                 const SizedBox(height: 24),
                
//                 // Info card
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.blue[200]!),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.info_outline, color: Colors.blue[700]),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           'Your location helps customers find you and enables accurate delivery tracking',
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.blue[900],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // Bottom buttons
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: widget.onBack,
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       side: BorderSide(color: Colors.grey[300]!),
//                     ),
//                     child: const Text(
//                       'Back',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   flex: 2,
//                   child: ElevatedButton(
//                     onPressed: _handleNext,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 2,
//                     ),
//                     child: const Text(
//                       'Continue to Documents',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
























// location_screen.dart - Add Full Address field

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationScreen extends StatefulWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LocationScreen({
    super.key,
    required this.formData,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullAddressController = TextEditingController(); // 👈 NEW
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  
  bool _isFetching = false;
  bool _locationFetched = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    _fullAddressController.text = widget.formData['fullAddress'] ?? ''; // 👈 NEW
    _latController.text = widget.formData['lat'] ?? '';
    _lngController.text = widget.formData['lng'] ?? '';
    if (_latController.text.isNotEmpty && _lngController.text.isNotEmpty) {
      _locationFetched = true;
    }
  }

  @override
  void dispose() {
    _fullAddressController.dispose(); // 👈 NEW
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  String? _validateCoordinate(String? value, String type) {
    if (value == null || value.isEmpty) {
      return '$type is required';
    }
    
    final coordinate = double.tryParse(value);
    if (coordinate == null) {
      return 'Enter a valid $type';
    }
    
    if (type == 'Latitude' && (coordinate < -90 || coordinate > 90)) {
      return 'Latitude must be between -90 and 90';
    }
    
    if (type == 'Longitude' && (coordinate < -180 || coordinate > 180)) {
      return 'Longitude must be between -180 and 180';
    }
    
    return null;
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetching = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied. Please enable location access.');
          setState(() => _isFetching = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Location permissions are permanently denied. Please enable them from settings.');
        setState(() => _isFetching = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latController.text = position.latitude.toStringAsFixed(6);
        _lngController.text = position.longitude.toStringAsFixed(6);
        _locationFetched = true;
        _isFetching = false;
      });

      _showSuccess('Location fetched successfully!');
    } catch (e) {
      _showError('Failed to get location: ${e.toString()}');
      setState(() => _isFetching = false);
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

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      // Save full address and coordinates
      widget.formData['fullAddress'] = _fullAddressController.text; // 👈 NEW
      widget.formData['lat'] = _latController.text;
      widget.formData['lng'] = _lngController.text;
      widget.onNext();
    } else {
      _showError('Please provide valid address and coordinates');
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
                  'Restaurant Location',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We need your exact location to serve customers better',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                
                // 👇 NEW: Full Address field (editable)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: TextFormField(
                    controller: _fullAddressController,
                    maxLines: 3,
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
                      helperText: 'You can edit the address if needed',
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
                ),
                
                // Location fetch card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _locationFetched ? Icons.location_on : Icons.location_searching,
                        size: 64,
                        color: _locationFetched 
                          ? Colors.green 
                          : Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _locationFetched 
                          ? 'Location Captured!' 
                          : 'Tap to Get Current Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _locationFetched 
                          ? 'You can manually adjust if needed' 
                          : 'Make sure your GPS is enabled',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isFetching ? null : _getCurrentLocation,
                          icon: _isFetching 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.my_location),
                          label: Text(
                            _isFetching 
                              ? 'Fetching Location...' 
                              : _locationFetched 
                                ? 'Refresh Location' 
                                : 'Get Current Location',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR ENTER MANUALLY',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                TextFormField(
                  controller: _latController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => _validateCoordinate(v, 'Latitude'),
                  decoration: InputDecoration(
                    labelText: 'Latitude *',
                    hintText: 'e.g., 12.9716',
                    prefixIcon: const Icon(Icons.place),
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
                
                TextFormField(
                  controller: _lngController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => _validateCoordinate(v, 'Longitude'),
                  decoration: InputDecoration(
                    labelText: 'Longitude *',
                    hintText: 'e.g., 77.5946',
                    prefixIcon: const Icon(Icons.place),
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
                
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your location helps customers find you and enables accurate delivery tracking',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[900],
                          ),
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
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Continue to Documents',
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
      ),
    );
  }
}