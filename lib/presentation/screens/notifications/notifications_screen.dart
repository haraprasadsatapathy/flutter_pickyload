import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildNotificationCard(
              context,
              'Trip Completed',
              'Your trip from Mumbai to Delhi has been completed successfully. Please rate your driver.',
              DateTime.now().subtract(const Duration(hours: 2)),
              Icons.check_circle,
              Colors.green,
              isRead: false,
            ),
            _buildNotificationCard(
              context,
              'Payment Received',
              'Payment of ₹15,000 has been successfully processed for your recent trip.',
              DateTime.now().subtract(const Duration(hours: 5)),
              Icons.payment,
              Colors.blue,
              isRead: false,
            ),
            _buildNotificationCard(
              context,
              'Driver Assigned',
              'Rajesh Kumar has been assigned for your upcoming trip. Vehicle: MH 12 AB 1234',
              DateTime.now().subtract(const Duration(hours: 8)),
              Icons.person_pin,
              Colors.orange,
              isRead: true,
            ),
            _buildNotificationCard(
              context,
              'Special Offer',
              'Get 20% discount on insurance for your next trip. Use code: SAFE20',
              DateTime.now().subtract(const Duration(days: 1)),
              Icons.local_offer,
              Colors.purple,
              isRead: true,
            ),
            _buildNotificationCard(
              context,
              'Document Verified',
              'Your driving license has been successfully verified.',
              DateTime.now().subtract(const Duration(days: 2)),
              Icons.verified,
              Colors.green,
              isRead: true,
            ),
            _buildNotificationCard(
              context,
              'Trip Request',
              'New load request from Pune to Bangalore. Tap to view details.',
              DateTime.now().subtract(const Duration(days: 2)),
              Icons.local_shipping,
              Colors.blue,
              isRead: true,
            ),
            _buildNotificationCard(
              context,
              'Welcome to Picky Load',
              'Thank you for joining Picky Load. Complete your profile to start booking trips.',
              DateTime.now().subtract(const Duration(days: 5)),
              Icons.celebration,
              Colors.orange,
              isRead: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context,
      String title,
      String message,
      DateTime timestamp,
      IconData icon,
      Color color, {
        bool isRead = false,
      }) {
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM dd');
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    String timeText;
    if (difference.inHours < 24) {
      timeText = timeFormat.format(timestamp);
    } else {
      timeText = dateFormat.format(timestamp);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isRead ? null : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              timeText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opened: $title')),
          );
        },
      ),
    );
  }
}
