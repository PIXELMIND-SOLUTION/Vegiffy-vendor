import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VendorNotificationsScreen extends StatefulWidget {
  final String vendorId;

  const VendorNotificationsScreen({
    super.key,
    required this.vendorId,
  });

  @override
  State<VendorNotificationsScreen> createState() =>
      _VendorNotificationsScreenState();
}

class _VendorNotificationsScreenState
    extends State<VendorNotificationsScreen> {
  bool _loading = true;
  bool _deleteLoading = false;
  List notifications = [];
  
  // Selection mode variables
  bool _isSelectionMode = false;
  Set<int> _selectedIndexes = {}; // Store selected indexes
  Set<String> _selectedIds = {}; // Store selected notification IDs

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.vegiffyy.com/api/vendor/notification/${widget.vendorId}',
        ),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          notifications = data['data'] ?? [];
        });
      }
    } catch (_) {
      // silent
    } finally {
      setState(() => _loading = false);
    }
  }

  // Handle single notification delete
  Future<void> _deleteSingleNotification(String notificationId) async {
    setState(() {
      _deleteLoading = true;
    });

    try {
      final res = await http.delete(
        Uri.parse('https://api.vegiffyy.com/api/vendor/deletenotification/${widget.vendorId}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'notificationIds': [notificationId] // Pass single ID in array
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          // Remove from local list
          setState(() {
            notifications.removeWhere((n) => n['_id'] == notificationId);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _showErrorSnackBar('Failed to delete notification');
        }
      } else {
        _showErrorSnackBar('Failed to delete notification');
      }
    } catch (e) {
      _showErrorSnackBar('Error deleting notification');
    } finally {
      setState(() {
        _deleteLoading = false;
      });
    }
  }

  // Handle multiple notifications delete
  Future<void> _deleteMultipleNotifications() async {
    if (_selectedIds.isEmpty) {
      _exitSelectionMode();
      return;
    }

    setState(() {
      _deleteLoading = true;
    });

    try {
      final res = await http.delete(
        Uri.parse('https://api.vegiffyy.com/api/vendor/deletenotification/${widget.vendorId}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'notificationIds': _selectedIds.toList(), // Pass all selected IDs
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          // Remove selected notifications from local list
          setState(() {
            notifications.removeWhere((n) => _selectedIds.contains(n['_id']));
            _selectedIds.clear();
            _selectedIndexes.clear();
            _isSelectionMode = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_selectedIds.length} notification(s) deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _showErrorSnackBar('Failed to delete notifications');
        }
      } else {
        _showErrorSnackBar('Failed to delete notifications');
      }
    } catch (e) {
      _showErrorSnackBar('Error deleting notifications');
    } finally {
      setState(() {
        _deleteLoading = false;
      });
    }
  }

  // Show confirmation dialog for single delete
  Future<void> _confirmSingleDelete(String notificationId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
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
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteSingleNotification(notificationId);
    }
  }

  // Show confirmation dialog for multiple delete
  Future<void> _confirmMultipleDelete() async {
    if (_selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Delete ${_selectedIds.length} Notification(s)?'),
        content: Text('Are you sure you want to delete ${_selectedIds.length} selected notification(s)?'),
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
            child: const Text('DELETE ALL'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteMultipleNotifications();
    }
  }

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Handle tap on notification
  void _onNotificationTap(int index, String notificationId) {
    if (_isSelectionMode) {
      _toggleSelection(index, notificationId);
    } else {
      // Navigate to notification details or handle tap
      _showNotificationDetails(index);
    }
  }

  // Handle long press to enter selection mode
  void _onNotificationLongPress(int index, String notificationId) {
    if (!_isSelectionMode) {
      _enterSelectionMode(index, notificationId);
    }
  }

  // Enter selection mode
  void _enterSelectionMode(int index, String notificationId) {
    setState(() {
      _isSelectionMode = true;
      _selectedIndexes.add(index);
      _selectedIds.add(notificationId);
    });
  }

  // Exit selection mode
  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIndexes.clear();
      _selectedIds.clear();
    });
  }

  // Toggle selection
  void _toggleSelection(int index, String notificationId) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
        _selectedIds.remove(notificationId);
      } else {
        _selectedIndexes.add(index);
        _selectedIds.add(notificationId);
      }

      // Exit selection mode if no items selected
      if (_selectedIndexes.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  // Select all notifications
  void _selectAll() {
    setState(() {
      if (_selectedIndexes.length == notifications.length) {
        // If all are selected, deselect all
        _selectedIndexes.clear();
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        // Select all
        _selectedIndexes.clear();
        _selectedIds.clear();
        for (int i = 0; i < notifications.length; i++) {
          _selectedIndexes.add(i);
          _selectedIds.add(notifications[i]['_id']);
        }
        _isSelectionMode = true;
      }
    });
  }

  // Show notification details (optional)
  void _showNotificationDetails(int index) {
    final notification = notifications[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(notification['title'] ?? 'Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message'] ?? ''),
            const SizedBox(height: 8),
            Text(
              'Received: ${notification['createdAt'] ?? ''}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedIndexes.length} selected')
            : const Text('Notifications'),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              )
            : null,
        actions: [
          if (_isSelectionMode) ...[
            // Select all button
            IconButton(
              icon: Icon(
                _selectedIndexes.length == notifications.length
                    ? Icons.deselect
                    : Icons.select_all,
              ),
              onPressed: _selectAll,
              tooltip: _selectedIndexes.length == notifications.length
                  ? 'Deselect all'
                  : 'Select all',
            ),
            // Delete selected button
            IconButton(
              icon: _deleteLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.delete),
              onPressed: _deleteLoading || _selectedIds.isEmpty
                  ? null
                  : _confirmMultipleDelete,
              tooltip: 'Delete selected',
            ),
          ] else if (notifications.isNotEmpty) ...[
            // Enter selection mode button
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () {
                setState(() {
                  _isSelectionMode = true;
                });
              },
              tooltip: 'Select notifications',
            ),
          ],
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_rounded,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    final isSelected = _selectedIndexes.contains(index);
                    final notificationId = n['_id'] ?? '';

                    return GestureDetector(
                      onTap: () => _onNotificationTap(index, notificationId),
                      onLongPress: () => _onNotificationLongPress(index, notificationId),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          color: isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.05)
                              : null,
                          child: ListTile(
                            leading: _isSelectionMode
                                ? Checkbox(
                                    value: isSelected,
                                    onChanged: (_) => _toggleSelection(index, notificationId),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    activeColor: Theme.of(context).primaryColor,
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    ),
                                    child: Icon(
                                      Icons.notifications,
                                      size: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                            title: Text(
                              n['title'] ?? 'Notification',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                n['message'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatDate(n['createdAt']),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (!_isSelectionMode) ...[
                                  const SizedBox(width: 8),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, size: 20),
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _confirmSingleDelete(notificationId);
                                      } else if (value == 'details') {
                                        _showNotificationDetails(index);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'details',
                                        child: Row(
                                          children: [
                                            Icon(Icons.info_outline, size: 18),
                                            SizedBox(width: 8),
                                            Text('Details'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // Helper method to format date
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateStr;
    }
  }
}