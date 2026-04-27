import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum ResetStep { email, otp, password }

class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  ResetStep step = ResetStep.email;

  final emailCtrl = TextEditingController();
  final otpCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool loading = false;
  bool showPassword = false;
  bool showConfirm = false;

  String message = '';
  int countdown = 900;
  Timer? timer;

  final passwordRegex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&]).{6,}$');

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (step == ResetStep.otp && countdown > 0) {
        setState(() => countdown--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ================= SEND OTP =================
  Future<void> sendOtp() async {
    setState(() {
      loading = true;
      message = '';
    });

    final res = await http.post(
      Uri.parse('https://api.vegiffy.in/api/vendor/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': emailCtrl.text.trim().toLowerCase()}),
    );

    final data = jsonDecode(res.body);

    setState(() => loading = false);

    if (data['success'] == true) {
      setState(() {
        step = ResetStep.otp;
        countdown = 900;
        message = 'OTP sent to your email';
      });
    } else {
      setState(() => message = data['message'] ?? 'Failed to send OTP');
    }
  }

  // ================= VERIFY OTP =================
  void verifyOtp() {
    if (otpCtrl.text.length != 4) {
      setState(() => message = 'Enter valid 4-digit OTP');
      return;
    }

    setState(() {
      step = ResetStep.password;
      message = '';
    });
  }

  // ================= RESET PASSWORD =================
  Future<void> resetPassword() async {
    final password = passCtrl.text;

    if (!passwordRegex.hasMatch(password)) {
      setState(() =>
          message = 'Password must contain letter, number & special character');
      return;
    }

    if (password != confirmCtrl.text) {
      setState(() => message = 'Passwords do not match');
      return;
    }

    setState(() => loading = true);

    final res = await http.post(
      Uri.parse('https://api.vegiffy.in/api/vendor/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailCtrl.text.trim().toLowerCase(),
        'otp': otpCtrl.text,
        'newPassword': password,
        'confirmPassword': confirmCtrl.text,
      }),
    );

    final data = jsonDecode(res.body);
    setState(() => loading = false);

    if (data['success'] == true && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successful')),
      );
    } else {
      setState(() => message = data['message'] ?? 'Reset failed');
    }
  }

  String format(int s) => '${(s ~/ 60)}:${(s % 60).toString().padLeft(2, '0')}';

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reset Password', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),

            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  message,
                  style: TextStyle(color: Colors.red),
                ),
              ),

            // ========= EMAIL STEP =========
            if (step == ResetStep.email) ...[
              TextField(
                controller: emailCtrl,
                decoration:
                    const InputDecoration(labelText: 'Registered Email'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: loading ? null : sendOtp,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Send OTP'),
              ),
            ],

            // ========= OTP STEP =========
            if (step == ResetStep.otp) ...[
              TextField(
                controller: otpCtrl,
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter OTP'),
              ),
              Text('Expires in ${format(countdown)}'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: verifyOtp,
                child: const Text('Verify OTP'),
              ),
            ],

            // ========= PASSWORD STEP =========
            if (step == ResetStep.password) ...[
              TextField(
                controller: passCtrl,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () =>
                        setState(() => showPassword = !showPassword),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmCtrl,
                obscureText: !showConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                        showConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => showConfirm = !showConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '• Min 6 chars\n• Letter + Number + Special char',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: loading ? null : resetPassword,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Reset Password'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
