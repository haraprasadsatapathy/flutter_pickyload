import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@pickyload.com',
      query: 'subject=Customer Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch email';
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+91-1800-123-4567',
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch phone';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Company Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
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
              const SizedBox(height: 24),
              // Company Name
              Text(
                'Picky Load',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Trusted Load Transport Partner',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 40),
              // Contact Information Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Us',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Email Section
                      _buildContactItem(
                        context,
                        icon: Icons.email_outlined,
                        title: 'Email Support',
                        subtitle: 'support@pickyload.com',
                        onPressed: () async {
                          try {
                            await _launchEmail();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not launch email: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                      const Divider(height: 32),
                      // Phone Section
                      _buildContactItem(
                        context,
                        icon: Icons.phone_outlined,
                        title: 'Customer Care',
                        subtitle: '+91-1800-123-4567',
                        onPressed: () async {
                          try {
                            await _launchPhone();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not make call: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Additional Information Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Working Hours',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'Monday - Friday',
                        '9:00 AM - 6:00 PM',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        'Saturday',
                        '10:00 AM - 4:00 PM',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        'Sunday',
                        'Closed',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
