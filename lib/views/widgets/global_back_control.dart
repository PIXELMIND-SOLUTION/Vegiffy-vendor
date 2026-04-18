// lib/widgets/global_back_control.dart
import 'package:flutter/material.dart';

class GlobalBackControl extends StatefulWidget {
  final Widget child;
  final VoidCallback? onBackPressed;
  final bool preventBackOnLoading;
  final List<String> blockedRoutes;

  const GlobalBackControl({
    super.key,
    required this.child,
    this.onBackPressed,
    this.preventBackOnLoading = false,
    this.blockedRoutes = const [],
  });

  @override
  State<GlobalBackControl> createState() => _GlobalBackControlState();
}

class _GlobalBackControlState extends State<GlobalBackControl> {
  bool _isProcessingBack = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Prevent multiple rapid back presses
        if (_isProcessingBack) return;

        // Check if current route is blocked
        final currentRoute = ModalRoute.of(context)?.settings.name;
        if (currentRoute != null &&
            widget.blockedRoutes.contains(currentRoute)) {
          // Show message that back is blocked on this screen
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cannot go back from this screen'),
                duration: Duration(seconds: 1),
              ),
            );
          }
          return;
        }

        _isProcessingBack = true;

        try {
          // Custom back handling
          if (widget.onBackPressed != null) {
            widget.onBackPressed!();
          } else {
            // Default behavior: show confirmation dialog
            final shouldPop = await _showExitConfirmation(context);
            if (shouldPop && mounted) {
              Navigator.of(context).pop();
            }
          }
        } finally {
          _isProcessingBack = false;
        }
      },
      child: widget.child,
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exit App?'),
        content: const Text('Do you want to exit the app?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
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
    ).then((value) => value ?? false);
  }
}

// Extension for easy access
extension GlobalBackControlExtension on BuildContext {
  void forceBackNavigation() {
    Navigator.of(this).pop();
  }

  bool canPop() {
    return Navigator.of(this).canPop();
  }
}
