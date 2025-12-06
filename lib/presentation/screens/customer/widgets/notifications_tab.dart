import 'package:flutter/material.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            title: Text('Notifications'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildNotificationCard(context, 'Trip Completed', 'Your trip from Mumbai to Delhi has been completed successfully', Icons.check_circle, Colors.green),
                _buildNotificationCard(context, 'Payment Received', 'Payment of ₹15,000 has been processed', Icons.payment, Colors.blue),
                _buildNotificationCard(context, 'New Offer', 'Special discount on insurance for your next trip', Icons.local_offer, Colors.orange),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, String title, String message, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(message),
        isThreeLine: true,
      ),
    );
  }
}
