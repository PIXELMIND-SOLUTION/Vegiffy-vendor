// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:vegiffyy_vendor/navigation/vendor_navigation_provider.dart';
// import 'package:vegiffyy_vendor/navigation/vendor_section.dart';

// class AddCategoryScreen extends StatefulWidget {
//   const AddCategoryScreen({super.key});

//   @override
//   State<AddCategoryScreen> createState() => _AddCategoryScreenState();
// }

// class _AddCategoryScreenState extends State<AddCategoryScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _categoryController = TextEditingController();

//   XFile? _categoryImage;
//   final List<SubCategoryForm> _subCategories = [SubCategoryForm()];
//   bool _loading = false;

//   final picker = ImagePicker();

//   Future<XFile?> _pickImage() async {
//     return await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 80,
//     );
//   }

//   void _addSubCategory() {
//     setState(() => _subCategories.add(SubCategoryForm()));
//   }

//   void _removeSubCategory(int index) {
//     setState(() => _subCategories.removeAt(index));
//   }

//   // 🚀 SUBMIT (UNCHANGED)
//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (_categoryImage == null) {
//       Fluttertoast.showToast(msg: "Please select category image");
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       final uri = Uri.parse("https://api.vegiffy.in/api/category");
//       final request = http.MultipartRequest('POST', uri);

//       request.fields['categoryName'] = _categoryController.text.trim();

//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'image',
//           _categoryImage!.path,
//         ),
//       );

//       final subData = _subCategories
//           .map((e) => {"subcategoryName": e.name.trim()})
//           .toList();

//       request.fields['subcategories'] = jsonEncode(subData);

//       for (int i = 0; i < _subCategories.length; i++) {
//         final img = _subCategories[i].image;
//         if (img != null) {
//           request.files.add(
//             await http.MultipartFile.fromPath(
//               'subcategoryImage_$i',
//               img.path,
//             ),
//           );
//         }
//       }

//       final res = await request.send();
//       final body = await res.stream.bytesToString();

//       debugPrint("STATUS: ${res.statusCode}");
//       debugPrint("BODY: $body");

//       if (res.statusCode == 200 || res.statusCode == 201) {
//         Fluttertoast.showToast(
//           msg: "🎉 Category added successfully",
//           backgroundColor: Colors.green,
//           textColor: Colors.white,
//         );

//         if (!mounted) return;
//         context
//             .read<VendorNavigationProvider>()
//             .setSection(VendorSection.allCategories);
//       } else {
//         Fluttertoast.showToast(msg: "Failed to add category");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: e.toString());
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   // 🧱 UI
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: AppBar(
//         title: const Text("Add Category"),
//         elevation: 1,
//       ),
//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               /// ================= CATEGORY CARD =================
//               _SectionCard(
//                 title: "Category Information",
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: _categoryController,
//                       decoration: const InputDecoration(
//                         labelText: "Category Name",
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (v) =>
//                           v == null || v.isEmpty ? "Required" : null,
//                     ),
//                     const SizedBox(height: 16),
//                     _UploadTile(
//                       title: "Upload Category Image",
//                       image: _categoryImage,
//                       onPick: () async {
//                         final img = await _pickImage();
//                         if (img != null) {
//                           setState(() => _categoryImage = img);
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               /// ================= SUBCATEGORY HEADER =================
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Subcategories",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: _addSubCategory,
//                     icon: const Icon(Icons.add),
//                     label: const Text("Add"),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               /// ================= SUBCATEGORY LIST =================
//               ..._subCategories.asMap().entries.map((entry) {
//                 final index = entry.key;
//                 final sub = entry.value;

//                 return _SectionCard(
//                   title: "Subcategory ${index + 1}",
//                   trailing: _subCategories.length > 1
//                       ? IconButton(
//                           icon:
//                               const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () => _removeSubCategory(index),
//                         )
//                       : null,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         decoration: const InputDecoration(
//                           labelText: "Subcategory Name",
//                           border: OutlineInputBorder(),
//                         ),
//                         onChanged: (v) => sub.name = v,
//                         validator: (v) =>
//                             v == null || v.isEmpty ? "Required" : null,
//                       ),
//                       const SizedBox(height: 12),
//                       _UploadTile(
//                         title: "Upload Subcategory Image",
//                         image: sub.image,
//                         onPick: () async {
//                           final img = await _pickImage();
//                           if (img != null) {
//                             setState(() => sub.image = img);
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 );
//               }),

//               const SizedBox(height: 32),

//               /// ================= SUBMIT BUTTON =================
//               SizedBox(
//                 height: 52,
//                 child: ElevatedButton(
//                   onPressed: _loading ? null : _submit,
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   child: _loading
//                       ? const CircularProgressIndicator(
//                           color: Colors.white,
//                         )
//                       : const Text(
//                           "Create Category",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /* ===================== MODELS ===================== */

// class SubCategoryForm {
//   String name;
//   XFile? image;

//   SubCategoryForm({this.name = '', this.image});
// }

// /* ===================== UI COMPONENTS ===================== */

// class _SectionCard extends StatelessWidget {
//   final String title;
//   final Widget child;
//   final Widget? trailing;

//   const _SectionCard({
//     required this.title,
//     required this.child,
//     this.trailing,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 1,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (trailing != null) trailing!,
//               ],
//             ),
//             const SizedBox(height: 16),
//             child,
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _UploadTile extends StatelessWidget {
//   final String title;
//   final XFile? image;
//   final VoidCallback onPick;

//   const _UploadTile({
//     required this.title,
//     required this.image,
//     required this.onPick,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onPick,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         height: 80,
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade400),
//           borderRadius: BorderRadius.circular(14),
//           color: Colors.grey.shade50,
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Row(
//           children: [
//             const Icon(Icons.cloud_upload_outlined),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(fontWeight: FontWeight.w500),
//               ),
//             ),
//             if (image != null)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: Image.file(
//                   File(image!.path),
//                   width: 60,
//                   height: 60,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vegiffyy_vendor/navigation/vendor_navigation_provider.dart';
import 'package:vegiffyy_vendor/navigation/vendor_section.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();

  XFile? _categoryImage;
  final List<SubCategoryForm> _subCategories = [SubCategoryForm()];
  bool _loading = false;

  final picker = ImagePicker();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<XFile?> _pickImage() async {
    return await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
  }

  void _addSubCategory() {
    setState(() => _subCategories.add(SubCategoryForm()));
  }

  void _removeSubCategory(int index) {
    if (_subCategories.length > 1) {
      setState(() => _subCategories.removeAt(index));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categoryImage == null) {
      Fluttertoast.showToast(
        msg: "Please select category image",
        backgroundColor: const Color(0xFFEF4444),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final uri = Uri.parse("https://api.vegiffy.in/api/category");
      final request = http.MultipartRequest('POST', uri);

      request.fields['categoryName'] = _categoryController.text.trim();

      request.files.add(
        await http.MultipartFile.fromPath('image', _categoryImage!.path),
      );

      final subData = _subCategories
          .map((e) => {"subcategoryName": e.name.trim()})
          .toList();

      request.fields['subcategories'] = jsonEncode(subData);

      for (int i = 0; i < _subCategories.length; i++) {
        final img = _subCategories[i].image;
        if (img != null) {
          request.files.add(
            await http.MultipartFile.fromPath('subcategoryImage_$i', img.path),
          );
        }
      }

      final res = await request.send();
      final body = await res.stream.bytesToString();

      debugPrint("STATUS: ${res.statusCode}");
      debugPrint("BODY: $body");

      if (res.statusCode == 200 || res.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "Category created successfully!",
          backgroundColor: const Color(0xFF10B981),
        );

        if (!mounted) return;
        context
            .read<VendorNavigationProvider>()
            .setSection(VendorSection.allCategories);
      } else {
        Fluttertoast.showToast(
          msg: "Failed to add category",
          backgroundColor: const Color(0xFFEF4444),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: const Color(0xFFEF4444),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Category"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Category Name Input
                  TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: "Category Name",
                      hintText: "Enter category name",
                      prefixIcon: const Icon(Icons.category_outlined),
                      helperText: "This will be visible to customers",
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 24),

                  // Category Image Upload
                  Text(
                    "Category Image *",
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _ImagePicker(
                    image: _categoryImage,
                    onTap: () async {
                      final img = await _pickImage();
                      if (img != null) {
                        setState(() => _categoryImage = img);
                      }
                    },
                  ),

                  const SizedBox(height: 32),

                  // Subcategories Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Subcategories",
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            "${_subCategories.length} subcategory${_subCategories.length > 1 ? 's' : ''}",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _addSubCategory,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Add More"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Subcategories List
                  ..._subCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final sub = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _SubcategoryItem(
                        index: index,
                        subcategory: sub,
                        canDelete: _subCategories.length > 1,
                        onDelete: () => _removeSubCategory(index),
                        onNameChanged: (v) => sub.name = v,
                        onImagePick: () async {
                          final img = await _pickImage();
                          if (img != null) {
                            setState(() => sub.image = img);
                          }
                        },
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
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Create Category"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== MODELS ===================== */

class SubCategoryForm {
  String name;
  XFile? image;
  SubCategoryForm({this.name = '', this.image});
}

/* ===================== UI COMPONENTS ===================== */

class _ImagePicker extends StatelessWidget {
  final XFile? image;
  final VoidCallback onTap;

  const _ImagePicker({
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: image != null
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: image != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      File(image!.path),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
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
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Upload Category Image",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tap to select from gallery",
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
      ),
    );
  }
}

class _SubcategoryItem extends StatelessWidget {
  final int index;
  final SubCategoryForm subcategory;
  final bool canDelete;
  final VoidCallback onDelete;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onImagePick;

  const _SubcategoryItem({
    required this.index,
    required this.subcategory,
    required this.canDelete,
    required this.onDelete,
    required this.onNameChanged,
    required this.onImagePick,
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
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "Sub ${index + 1}",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (canDelete)
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

            // Name Input
            TextFormField(
              initialValue: subcategory.name,
              decoration: const InputDecoration(
                labelText: "Subcategory Name",
                hintText: "Enter subcategory name",
                prefixIcon: Icon(Icons.label_outline),
              ),
              onChanged: onNameChanged,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? "Required" : null,
            ),

            const SizedBox(height: 16),

            // Image Upload
            GestureDetector(
              onTap: onImagePick,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: subcategory.image != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.file(
                              File(subcategory.image!.path),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Optional Image",
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
