
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vegiffyy_vendor/helper/vendor_storage_helper.dart';
import 'package:vegiffyy_vendor/models/Category/category_model.dart';
import 'package:vegiffyy_vendor/navigation/vendor_section.dart';
import 'package:vegiffyy_vendor/providers/Category/category_provider.dart';
import 'package:vegiffyy_vendor/services/Product/product_service.dart';
import 'package:vegiffyy_vendor/views/Product/product_list_screen.dart';
import 'package:vegiffyy_vendor/views/dashboard/vendor_main_screen.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
     String? vendorId;
  final List<_ProductForm> products = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().load();
    });
                      _loadVendor();

  }

            void _loadVendor() {
  final vendor = VendorPreferences.getVendor();

  if (vendor == null) {
    // Safety fallback (auto logout / redirect)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session expired. Please login again")),
      );
      Navigator.pop(context);
    });
    return;
  }

  vendorId = vendor.id;




}

  void _addProduct() {
    setState(() => products.add(_ProductForm()));
  }

  void _removeProduct(int index) {
    setState(() => products.removeAt(index));
  }

  Future<void> _pickImage(int index) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    final file = File(picked.path);
    final fileSize = await file.length();
    
    if (fileSize > 5 * 1024 * 1024) {
      _showSnackBar("Image must be less than 5MB", isError: true);
      return;
    }

    setState(() => products[index].image = file);
  }

  Future<void> _submit() async {
    if (products.isEmpty) {
      _showSnackBar("Add at least one product", isError: true);
      return;
    }

    final invalidProducts = products.where((p) => !p.isValid).toList();
    if (invalidProducts.isNotEmpty) {
      _showSnackBar("Please fill all required fields", isError: true);
      return;
    }

    setState(() => loading = true);

    try {
      final productData = products.map((p) => p.toJson()).toList();
      final images = products.map((p) => p.image!).toList();

      await ProductService.createProduct(
        vendorId: vendorId.toString(),
        recommended: productData,
        images: images,
      );

      if (!mounted) return;
      
      _showSnackBar("Products created successfully!", isSuccess: true);
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (_) => const VendorMainScreen(
      initialSection: VendorSection.allProducts,
    ),
  ),
  (route) => false,
);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}", isError: true);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? const Color(0xFF10B981)
            : isError
                ? const Color(0xFFEF4444)
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Products"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Vendor Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.store_outlined,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Vendor ID",
                                style: theme.textTheme.labelSmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vendorId.toString(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Add Product Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Products",
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          "${products.length} product${products.length != 1 ? 's' : ''} added",
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _addProduct,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Add Product"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Empty State
                if (products.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Products Yet",
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tap 'Add Product' to get started",
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                // Product Cards
                ...products.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ProductCard(
                      index: entry.key,
                      product: entry.value,
                      categories: categoryProvider.categories,
                      onDelete: () => _removeProduct(entry.key),
                      onImagePick: () => _pickImage(entry.key),
                      onUpdate: () => setState(() {}),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Submit Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Create ${products.length} Product${products.length != 1 ? 's' : ''}",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
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

/* ===================== PRODUCT CARD ===================== */

class _ProductCard extends StatelessWidget {
  final int index;
  final _ProductForm product;
  final List<CategoryModel> categories;
  final VoidCallback onDelete;
  final VoidCallback onImagePick;
  final VoidCallback onUpdate;

  const _ProductCard({
    required this.index,
    required this.product,
    required this.categories,
    required this.onDelete,
    required this.onImagePick,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "#${index + 1}",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Product ${index + 1}",
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Product Name
            TextField(
              decoration: const InputDecoration(
                labelText: "Product Name *",
                hintText: "Enter product name",
                prefixIcon: Icon(Icons.restaurant_menu_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (v) {
                product.name = v;
                onUpdate();
              },
            ),

            const SizedBox(height: 12),

            // Price Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Price (₹) *",
                      hintText: "0.00",
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                    onChanged: (v) {
                      product.price = v;
                      onUpdate();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Discount (%)",
                      hintText: "0",
                      prefixIcon: Icon(Icons.local_offer_outlined),
                    ),
                    onChanged: (v) {
                      product.discount = v;
                      onUpdate();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Half & Full Plate Price
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Half Plate",
                      hintText: "Optional",
                      prefixIcon: Icon(Icons.restaurant_outlined),
                    ),
                    onChanged: (v) {
                      product.half = v;
                      onUpdate();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Full Plate",
                      hintText: "Optional",
                      prefixIcon: Icon(Icons.restaurant),
                    ),
                    onChanged: (v) {
                      product.full = v;
                      onUpdate();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: product.category.isEmpty ? null : product.category,
              decoration: const InputDecoration(
                labelText: "Category *",
                prefixIcon: Icon(Icons.category_outlined),
              ),
              hint: const Text("Select category"),
              items: categories
                  .map((cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      ))
                  .toList(),
              onChanged: (v) {
                product.category = v ?? "";
                onUpdate();
              },
            ),

            const SizedBox(height: 12),

            // Preparation Time
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Preparation Time (mins)",
                hintText: "Optional",
                prefixIcon: Icon(Icons.access_time_outlined),
              ),
              onChanged: (v) {
                product.prep = v;
                onUpdate();
              },
            ),

            const SizedBox(height: 12),

            // Description
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                hintText: "Optional product description",
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              onChanged: (v) {
                product.content = v;
                onUpdate();
              },
            ),

            const SizedBox(height: 16),

            // Image Upload
            Text(
              "Product Image *",
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            
            GestureDetector(
              onTap: onImagePick,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: product.image != null
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: product.image != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              product.image!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Upload Product Image",
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Max size: 5MB • JPG, PNG",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== PRODUCT FORM MODEL ===================== */

class _ProductForm {
  String name = "";
  String price = "";
  String half = "";
  String full = "";
  String discount = "0";
  String category = "";
  String prep = "";
  String content = "";
  File? image;

  bool get isValid =>
      name.trim().isNotEmpty &&
      price.trim().isNotEmpty &&
      discount.trim().isNotEmpty &&
      category.isNotEmpty &&
      image != null;

  Map<String, dynamic> toJson() => {
        "name": name.trim(),
        "price": double.tryParse(price) ?? 0.0,
        "halfPlatePrice": double.tryParse(half) ?? 0.0,
        "fullPlatePrice": double.tryParse(full) ?? 0.0,
        "discount": double.tryParse(discount) ?? 0.0,
        "category": category,
        "preparationTime": prep.trim(),
        "content": content.trim(),
      };
}