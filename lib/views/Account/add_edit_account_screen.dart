import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddEditAccountScreen extends StatefulWidget {
  final String vendorId;
  final Map? account;

  const AddEditAccountScreen({
    super.key,
    required this.vendorId,
    this.account,
  });

  @override
  State<AddEditAccountScreen> createState() => _AddEditAccountScreenState();
}

class _AddEditAccountScreenState extends State<AddEditAccountScreen> {
  final String baseUrl = "https://api.vegiffy.in/api/vendor";

  final _formKey = GlobalKey<FormState>();

  final holderCtrl = TextEditingController();
  final accCtrl = TextEditingController();
  final bankCtrl = TextEditingController();
  final ifscCtrl = TextEditingController();
  final branchCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  String accountType = "savings";
  bool isPrimary = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      final a = widget.account!;
      holderCtrl.text = a['accountHolderName'];
      accCtrl.text = a['accountNumber'];
      bankCtrl.text = a['bankName'];
      ifscCtrl.text = a['ifscCode'];
      branchCtrl.text = a['branchName'];
      phoneCtrl.text = a['phoneNumber'] ?? "";
      emailCtrl.text = a['email'] ?? "";
      accountType = a['accountType'];
      isPrimary = a['isPrimary'] ?? false;
    }
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final payload = {
      "vendorId": widget.vendorId,
      "accountHolderName": holderCtrl.text,
      "accountNumber": accCtrl.text,
      "bankName": bankCtrl.text,
      "ifscCode": ifscCtrl.text,
      "branchName": branchCtrl.text,
      "accountType": accountType,
      "phoneNumber": phoneCtrl.text,
      "email": emailCtrl.text,
      "isPrimary": isPrimary,
      "status": "active",
    };

    final res = widget.account == null
        ? await http.post(
            Uri.parse("$baseUrl/createaccounts"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          )
        : await http.put(
            Uri.parse("$baseUrl/updateaccount/${widget.account!['_id']}"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          );

    final body = jsonDecode(res.body);

    if (body['success']) {
      Navigator.pop(context);
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account == null ? "Add Account" : "Edit Account"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(holderCtrl, "Account Holder Name"),
            _field(accCtrl, "Account Number"),
            _field(bankCtrl, "Bank Name"),
            _field(
              ifscCtrl,
              "IFSC Code",
              validator: (v) =>
                  v!.length == 11 ? null : "IFSC must be 11 characters",
            ),
            _field(branchCtrl, "Branch Name"),
            DropdownButtonFormField(
              value: accountType,
              decoration: const InputDecoration(labelText: "Account Type"),
              items: const [
                DropdownMenuItem(value: "savings", child: Text("Savings")),
                DropdownMenuItem(value: "current", child: Text("Current")),
                DropdownMenuItem(value: "salary", child: Text("Salary")),
              ],
              onChanged: (v) => setState(() => accountType = v!),
            ),
            _field(phoneCtrl, "Phone"),
            _field(emailCtrl, "Email"),
            CheckboxListTile(
              value: isPrimary,
              onChanged: (v) => setState(() => isPrimary = v!),
              title: const Text("Set as Primary"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : save,
              child: loading
                  ? const CircularProgressIndicator()
                  : Text(widget.account == null
                      ? "Add Account"
                      : "Update Account"),
            )
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: c,
        validator: validator ?? (v) => v!.isEmpty ? "Required" : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
