// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_filex/open_filex.dart';

// Future<void> downloadAndOpenPdf({
//   required String assetPath,
//   required String fileName,
// }) async {
//   // Load PDF from assets
//   final byteData = await rootBundle.load(assetPath);

//   // Get app document directory
//   final dir = await getApplicationDocumentsDirectory();
//   final file = File('${dir.path}/$fileName');

//   // Write file
//   await file.writeAsBytes(
//     byteData.buffer.asUint8List(),
//     flush: true,
//   );

//   // Open PDF
//   await OpenFilex.open(file.path);
// }




















import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

// Keep your existing downloadAndOpenPdf function
Future<void> downloadAndOpenPdf({
  required String assetPath,
  required String fileName,
}) async {
  // Load PDF from assets
  final byteData = await rootBundle.load(assetPath);

  // Get app document directory
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$fileName');

  // Write file
  await file.writeAsBytes(
    byteData.buffer.asUint8List(),
    flush: true,
  );

  // Open PDF
  await OpenFilex.open(file.path);
}

// 👇 NEW: Generate Declaration PDF with dynamic data
Future<void> generateDeclarationPDF({
  required String restaurantName,
  required String fssaiNo,
  required String fullAddress,
  required String locationName,
  required String mobile,
  required List<String> disclaimers,
}) async {
  final pdf = pw.Document();
  
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              color: PdfColors.green700,
              padding: const pw.EdgeInsets.all(20),
              width: double.infinity,
              child: pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'DECLARATION LETTER',
                      style: pw.TextStyle(
                        fontSize: 24,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '(Pure Vegetarian Restaurant)',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            pw.SizedBox(height: 30),
            
            // Content
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 30),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Date: ___________________________'),
                  pw.SizedBox(height: 20),
                  pw.Text('To,'),
                  pw.Text('Vegiffy - Pure Vegetarian Food Delivery App'),
                  pw.Text('Jainity Eats India Private Limited'),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Subject: Declaration of Pure Vegetarian Restaurant',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'I, ________________________________________, Proprietor / Authorized Signatory of,',
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('Restaurant Name: $restaurantName'),
                  pw.Text('FSSAI License No: $fssaiNo'),
                  pw.Text('Address: ${fullAddress.isNotEmpty ? fullAddress : locationName}'),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'do hereby solemnly declare and affirm that:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('1. Our restaurant is a 100% Pure Vegetarian establishment.'),
                  pw.Text('2. We do not prepare, store, sell, or serve any non-vegetarian food items.'),
                  pw.Text('3. All ingredients and food preparation processes follow pure vegetarian standards.'),
                  pw.Text('4. We comply with FSSAI regulations and maintain proper hygiene standards.'),
                  pw.Text('5. We understand any violation may lead to immediate delisting from Vegiffy.'),
                  
                  // Additional disclaimers
                  if (disclaimers.isNotEmpty) ...[
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Additional Declarations:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    ...disclaimers.asMap().entries.map((entry) {
                      return pw.Text('${entry.key + 1}. ${entry.value}');
                    }).toList(),
                  ],
                  
                  pw.SizedBox(height: 20),
                  pw.Text('This declaration is made for the purpose of onboarding with Vegiffy platform.'),
                  pw.SizedBox(height: 30),
                  pw.Text('Vendor Signature: _________________________'),
                  pw.Text('Name: _________________________'),
                  pw.Text('Mobile: $mobile'),
                  pw.Text('Date: _________________________'),
                ],
              ),
            ),
            
            pw.Spacer(),
            
            // Footer
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text(
                'Generated by Vegiffy Platform',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
  
  // Save PDF
  final output = await getApplicationDocumentsDirectory();
  final file = File('${output.path}/Vegiffy_Declaration.pdf');
  await file.writeAsBytes(await pdf.save());
  
  // Open PDF
  await OpenFilex.open(file.path);
}

// 👇 NEW: Generate Agreement PDF with dynamic data
Future<void> generateAgreementPDF({
  required String restaurantName,
  required String fssaiNo,
  required String fullAddress,
  required String locationName,
  required String commission,
  required List<String> disclaimers,
}) async {
  final pdf = pw.Document();
  
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) {
        return [
          // Header
          pw.Container(
            color: PdfColors.green700,
            padding: const pw.EdgeInsets.all(20),
            width: double.infinity,
            child: pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'VENDOR AGREEMENT',
                    style: pw.TextStyle(
                      fontSize: 20,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Vegiffy - Pure Vegetarian Food Delivery Platform',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          pw.SizedBox(height: 30),
          
          // Company Details
          pw.Text(
            'JAINITY EATS INDIA PRIVATE LIMITED',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('781 SADAR BAZAR BOLARUM SECUNDERABAD TELANGANA 500010'),
          pw.Text('Email id: vendor@Vegiffy.com'),
          pw.Text('Website: www.Vegiffy.com'),
          pw.Text('Phone no: 9391973675'),
          
          pw.SizedBox(height: 20),
          
          // Restaurant Details
          pw.Text(
            'RESTAURANT PARTNER DETAILS',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Restaurant Name: $restaurantName'),
          pw.Text('FSSAI License No: $fssaiNo'),
          pw.Text('Address: ${fullAddress.isNotEmpty ? fullAddress : locationName}'),
          if (commission.isNotEmpty)
            pw.Text('Commission Rate: $commission%'),
          
          pw.SizedBox(height: 20),
          
          // Additional Disclaimers
          if (disclaimers.isNotEmpty) ...[
            pw.Text(
              'Additional Declarations:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            ...disclaimers.asMap().entries.map((entry) {
              return pw.Text('${entry.key + 1}. ${entry.value}');
            }).toList(),
            pw.SizedBox(height: 20),
          ],
          
          // Agreement Terms (simplified version - you can add full terms here)
          pw.Text(
            'TERMS AND CONDITIONS',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'This Restaurant Partner Agreement is entered into between Jainity Eats India Private Limited ("Vegiffy") and the Restaurant Partner identified above. The Restaurant Partner agrees to comply with all applicable laws, including food safety regulations, tax laws, and data protection laws. The Restaurant Partner confirms that it is a 100% Pure Vegetarian establishment and will maintain this status throughout the partnership.',
            style: const pw.TextStyle(fontSize: 10),
          ),
          
          pw.SizedBox(height: 30),
          
          // Signatures
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'FOR Vegiffy',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text('Name: _________________________'),
                  pw.Text('Signature: ____________________'),
                  pw.Text('Date: _________________________'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'FOR RESTAURANT PARTNER',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text('Name: _________________________'),
                  pw.Text('Signature: ____________________'),
                  pw.Text('Date: _________________________'),
                ],
              ),
            ],
          ),
          
          pw.SizedBox(height: 20),
          
          // Footer
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Generated by Vegiffy Platform',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ),
        ];
      },
    ),
  );
  
  // Save PDF
  final output = await getApplicationDocumentsDirectory();
  final file = File('${output.path}/Vegiffy_Vendor_Agreement.pdf');
  await file.writeAsBytes(await pdf.save());
  
  // Open PDF
  await OpenFilex.open(file.path);
}