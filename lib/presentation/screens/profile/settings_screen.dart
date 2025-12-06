import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;
  bool _tripUpdates = true;
  bool _promotionalOffers = false;
  bool _locationServices = true;
  bool _biometricAuth = false;
  bool _twoFactorAuth = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'INR (₹)';

  final List<String> _languages = ['English', 'Hindi', 'Marathi', 'Tamil', 'Telugu'];
  final List<String> _currencies = ['INR (₹)', 'USD (\$)', 'EUR (€)', 'GBP (£)'];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionHeader('Appearance'),
            _buildAppearanceSection(themeProvider),
            const SizedBox(height: 24),
            _buildSectionHeader('Notifications'),
            _buildNotificationsSection(),
            const SizedBox(height: 24),
            _buildSectionHeader('Privacy & Security'),
            _buildPrivacySection(),
            const SizedBox(height: 24),
            _buildSectionHeader('Preferences'),
            _buildPreferencesSection(),
            const SizedBox(height: 24),
            _buildSectionHeader('About'),
            _buildAboutSection(),
            const SizedBox(height: 24),
            _buildSectionHeader('Account'),
            _buildAccountSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildAppearanceSection(ThemeProvider themeProvider) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.format_size),
            title: const Text('Text Size'),
            subtitle: const Text('Medium'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showTextSizeDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
            secondary: const Icon(Icons.notifications_active),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive email updates'),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
            secondary: const Icon(Icons.email),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('SMS Notifications'),
            subtitle: const Text('Receive SMS updates'),
            value: _smsNotifications,
            onChanged: (value) {
              setState(() {
                _smsNotifications = value;
              });
            },
            secondary: const Icon(Icons.sms),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Trip Updates'),
            subtitle: const Text('Get notified about trip status'),
            value: _tripUpdates,
            onChanged: (value) {
              setState(() {
                _tripUpdates = value;
              });
            },
            secondary: const Icon(Icons.local_shipping),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Promotional Offers'),
            subtitle: const Text('Receive special offers and discounts'),
            value: _promotionalOffers,
            onChanged: (value) {
              setState(() {
                _promotionalOffers = value;
              });
            },
            secondary: const Icon(Icons.local_offer),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Location Services'),
            subtitle: const Text('Allow location tracking'),
            value: _locationServices,
            onChanged: (value) {
              setState(() {
                _locationServices = value;
              });
            },
            secondary: const Icon(Icons.location_on),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use fingerprint or face ID'),
            value: _biometricAuth,
            onChanged: (value) {
              setState(() {
                _biometricAuth = value;
              });
            },
            secondary: const Icon(Icons.fingerprint),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Extra security for your account'),
            value: _twoFactorAuth,
            onChanged: (value) {
              setState(() {
                _twoFactorAuth = value;
              });
            },
            secondary: const Icon(Icons.security),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showInfoDialog(
                'Privacy Policy',
                'Our privacy policy outlines how we collect, use, and protect your personal information...',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.currency_rupee),
            title: const Text('Currency'),
            subtitle: Text(_selectedCurrency),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showCurrencyDialog();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Default Map View'),
            subtitle: const Text('Standard'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showMapViewDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: const Text(
                'Up to date',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms & Conditions'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showInfoDialog(
                'Terms & Conditions',
                'By using Picky Load, you agree to our terms and conditions...',
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showInfoDialog(
                'Help & Support',
                'Need help? Contact us:\n\nEmail: support@pickyload.com\nPhone: 1800-123-4567\n\nWorking Hours:\nMon-Sat: 9 AM - 6 PM',
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.star_rate),
            title: const Text('Rate Us'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your support!'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.storage, color: Colors.blue),
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up storage space'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showClearCacheDialog();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Permanently delete your account'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              // ignore: deprecated_member_use
              groupValue: _selectedLanguage,
              // ignore: deprecated_member_use
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Language changed to $value')),
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _currencies.map((currency) {
            return RadioListTile<String>(
              title: Text(currency),
              value: currency,
              // ignore: deprecated_member_use
              groupValue: _selectedCurrency,
              // ignore: deprecated_member_use
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Currency changed to $value')),
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showTextSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Text Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Small', 'Medium', 'Large', 'Extra Large'].map((size) {
            return RadioListTile<String>(
              title: Text(size),
              value: size,
              // ignore: deprecated_member_use
              groupValue: 'Medium',
              // ignore: deprecated_member_use
              onChanged: (value) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Text size changed to $value')),
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showMapViewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Map View'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Standard', 'Satellite', 'Terrain', 'Hybrid'].map((view) {
            return RadioListTile<String>(
              title: Text(view),
              value: view,
              // ignore: deprecated_member_use
              groupValue: 'Standard',
              // ignore: deprecated_member_use
              onChanged: (value) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Map view changed to $value')),
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear all cached data? This will free up storage space but may slow down the app temporarily.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              _showFinalDeleteConfirmation();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will permanently delete:'),
            SizedBox(height: 8),
            Text('• Your profile information'),
            Text('• Trip history'),
            Text('• Saved addresses'),
            Text('• All other account data'),
            SizedBox(height: 16),
            Text(
              'Type "DELETE" to confirm',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion cancelled'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }
}
