// import 'package:flutter/material.dart';
// import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
// import 'package:vegiffyy_vendor/models/Product/product_model.dart';
// import 'package:vegiffyy_vendor/views/Product/product_view_screen.dart';
// import '../../services/Product/product_service.dart';

// class ProductListScreen extends StatefulWidget {
//   const ProductListScreen({super.key});

//   @override
//   State<ProductListScreen> createState() => _ProductListScreenState();
// }

// class _ProductListScreenState extends State<ProductListScreen> {
//   List<ProductModel> products = [];
//   bool loading = true;
//        String? vendorId;

//   @override
//   void initState() {
//     super.initState();
//                           _loadVendor();

//   }

//               void _loadVendor() {
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

//     load();

// }

//   Future<void> load() async {
//     final vendor = vendorId.toString();
//     final res = await ProductService.getProducts(vendor);

//     setState(() {
//       products = (res['recommendedProducts'] as List)
//           .map((e) => ProductModel.fromJson(e))
//           .toList();
//       loading = false;
//     });
//   }

//   void toggleStatus(ProductModel p) async {
//     final old = p.recommendedItem['status'];
//     final next = old == "active" ? "inactive" : "active";

//     setState(() => p.recommendedItem['status'] = next);

//     try {
//       await ProductService.updateProduct(
//         productId: p.productId,
//         recommendedId: p.recommendedItem['_id'],
//         recommendedData: {...p.recommendedItem, "status": next},
//       );
//     } catch (_) {
//       setState(() => p.recommendedItem['status'] = old);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     /// EMPTY STATE
//     if (products.isEmpty) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.inventory_2_outlined,
//                   size: 80, color: Colors.grey.shade400),
//               const SizedBox(height: 16),
//               Text(
//                 "No Products Found",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "You haven't added any products yet.\nStart by creating your first product.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: products.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 12),
//       itemBuilder: (_, i) {
//         final p = products[i];
//         final status = p.recommendedItem['status'];
//         final image = p.recommendedItem['image'];

//         return InkWell(
//           borderRadius: BorderRadius.circular(16),
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => ProductViewScreen(product: p),
//             ),
//           ),
//           child: Card(
//             elevation: 3,
//             shadowColor: Colors.black12,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 children: [
//                   /// PRODUCT IMAGE
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: image != null && image.toString().isNotEmpty
//                         ? Image.network(
//                             image,
//                             width: 70,
//                             height: 70,
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) => _imageFallback(),
//                           )
//                         : _imageFallback(),
//                   ),

//                   const SizedBox(width: 12),

//                   /// PRODUCT INFO
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           p.recommendedItem['name'] ?? "Unnamed Product",
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           "₹${p.recommendedItem['price']}",
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.green,
//                           ),
//                         ),
//                         const SizedBox(height: 6),

//                         /// STATUS TEXT
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 10, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: status == "active"
//                                 ? Colors.green.shade50
//                                 : Colors.red.shade50,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             status == "active" ? "Active" : "Inactive",
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: status == "active"
//                                   ? Colors.green
//                                   : Colors.red,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   /// STATUS SWITCH
//                   Column(
//                     children: [
//                       Switch(
//                         value: status == "active",
//                         onChanged: (_) => toggleStatus(p),
//                         activeColor: Colors.green,
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         status == "active" ? "Enabled" : "Disabled",
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _imageFallback() {
//     return Container(
//       width: 70,
//       height: 70,
//       color: Colors.grey.shade200,
//       child: Icon(
//         Icons.fastfood_outlined,
//         size: 32,
//         color: Colors.grey.shade500,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
import 'package:vegiffyy_vendor/models/Product/product_model.dart';
import 'package:vegiffyy_vendor/navigation/vendor_navigation_provider.dart';
import 'package:vegiffyy_vendor/navigation/vendor_section.dart';
import 'package:vegiffyy_vendor/providers/auth_provider.dart';
import 'package:vegiffyy_vendor/views/Product/product_view_screen.dart';
import '../../services/Product/product_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  bool loading = true;
  String? vendorId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadVendor();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterProducts();
    });
  }

  void _filterProducts() {
    if (_searchQuery.isEmpty) {
      filteredProducts = List.from(products);
    } else {
      filteredProducts = products.where((product) {
        final name =
            (product.recommendedItem['name'] ?? '').toString().toLowerCase();
        final price =
            (product.recommendedItem['price'] ?? '').toString().toLowerCase();
        final query = _searchQuery.trim().toLowerCase();
        return name.contains(query) || price.contains(query);
      }).toList();
    }
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
    load();
  }

  Future<void> load() async {
    final vendor = vendorId.toString();
    final res = await ProductService.getProducts(vendor);

    setState(() {
      products = (res['recommendedProducts'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
      filteredProducts = List.from(products);
      loading = false;
    });
  }

  void toggleStatus(ProductModel p) async {
    final old = p.recommendedItem['status'];
    final next = old == "active" ? "inactive" : "active";

    setState(() => p.recommendedItem['status'] = next);

    try {
      await ProductService.updateProduct(
        productId: p.productId,
        recommendedId: p.recommendedItem['_id'],
        recommendedData: {...p.recommendedItem, "status": next},
      );
    } catch (_) {
      setState(() => p.recommendedItem['status'] = old);
    }
  }

  Future<bool> _showExitConfirmationDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<VendorNavigationProvider>();
    final vendor = context.watch<AuthProvider>().vendor;
    return WillPopScope(
      onWillPop: () async {
        // If we're not on dashboard, go to dashboard instead of closing app
        if (nav.current != VendorSection.dashboard) {
          context
              .read<VendorNavigationProvider>()
              .setSection(VendorSection.dashboard);
          return false; // Don't pop, we handled it
        }
        // If already on dashboard, show exit confirmation
        return _showExitConfirmationDialog();
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Column(
          children: [
            // Header Section with Search
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Product Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "My Products",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (!loading)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${filteredProducts.length} items",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Search products...",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade600,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey.shade600,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (products.isEmpty) {
      return _buildEmptyState();
    }

    if (filteredProducts.isEmpty) {
      return _buildNoResults();
    }

    return RefreshIndicator(
      onRefresh: load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredProducts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildProductCard(filteredProducts[i]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Products Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You haven't added any products yet.\nStart by creating your first product.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              "No Results Found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your search terms",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel p) {
    final status = p.recommendedItem['status'];
    final image = p.recommendedItem['image'];
    final isActive = status == "active";

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductViewScreen(product: p),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: image != null && image.toString().isNotEmpty
                      ? Image.network(
                          image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imageFallback(),
                        )
                      : _imageFallback(),
                ),
              ),

              const SizedBox(width: 14),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.recommendedItem['name'] ?? "Unnamed Product",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "₹${p.recommendedItem['price']}",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isActive
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isActive ? "Active" : "Inactive",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Status Switch
              Column(
                children: [
                  Transform.scale(
                    scale: 0.9,
                    child: Switch(
                      value: isActive,
                      onChanged: (_) => toggleStatus(p),
                      activeColor: Colors.green,
                      activeTrackColor: Colors.green.shade200,
                    ),
                  ),
                  Text(
                    isActive ? "On" : "Off",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.fastfood_outlined,
        size: 36,
        color: Colors.grey.shade400,
      ),
    );
  }
}
