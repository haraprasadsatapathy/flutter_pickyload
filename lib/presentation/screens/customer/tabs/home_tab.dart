import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picky_load/presentation/screens/customer/tabs/quick_action_button.dart';
import 'package:provider/provider.dart';

import '../../../../providers/auth_provider.dart';
import '../../../../providers/theme_provider.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                authProvider.logout();
                context.go('/login');
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
                Text(
                  authProvider.currentUser?.name ?? 'User',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
                tooltip: 'Toggle Theme',
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _showLogoutDialog(context),
                tooltip: 'Logout',
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                Text(
                  'Ongoing Load Requests',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLoadRequestCard(
                  context,
                  'Mumbai to Delhi',
                  '₹12,500',
                  '10 Tons',
                  'Rajesh Kumar',
                  '4.8',
                ),
                _buildLoadRequestCard(
                  context,
                  'Pune to Bangalore',
                  '₹8,500',
                  '5 Tons',
                  'Amit Singh',
                  '4.9',
                ),
                _buildLoadRequestCard(
                  context,
                  'Chennai to Hyderabad',
                  '₹6,500',
                  '3 Tons',
                  'Suresh Patel',
                  '4.7',
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLoadRequestCard(
    BuildContext context,
    String route,
    String price,
    String capacity,
    String driverName,
    String rating,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  route,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  price,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Capacity: $capacity'),
            const SizedBox(height: 4),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    driverName[0],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Driver: $driverName'),
                const SizedBox(width: 12),
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(rating),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Load request declined')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Load request accepted'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.push('/trip-tracking');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}