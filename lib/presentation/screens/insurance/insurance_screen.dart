import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/insurance_model.dart';

class InsuranceScreen extends StatefulWidget {
  final String tripId;

  const InsuranceScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loadValueController = TextEditingController();
  double _distance = 450.0;
  double? _calculatedPremium;
  double? _coverageAmount;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _loadValueController.dispose();
    super.dispose();
  }

  void _calculatePremium() {
    if (_formKey.currentState!.validate()) {
      final loadValue = double.parse(_loadValueController.text);
      setState(() {
        _calculatedPremium = Insurance.calculatePremium(loadValue, _distance);
        _coverageAmount = Insurance.getCoverageAmount(loadValue);
      });
    }
  }

  void _purchaseInsurance() {
    if (_calculatedPremium == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please calculate premium first')),
      );
      return;
    }

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept terms and conditions')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Text(
          'Do you want to purchase insurance for ₹${_calculatedPremium!.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Insurance purchased successfully')),
              );
              context.go('/customer-dashboard');
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load Insurance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: Theme.of(context).colorScheme.primary,
                          size: 40,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Protect Your Load',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Get comprehensive coverage for your goods during transit',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Insurance Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _loadValueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Load Value (₹)',
                    prefixIcon: Icon(Icons.currency_rupee),
                    helperText: 'Enter the total value of your goods',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter load value';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Distance: ${_distance.toStringAsFixed(0)} km',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _distance,
                  min: 50,
                  max: 2000,
                  divisions: 39,
                  label: '${_distance.toStringAsFixed(0)} km',
                  onChanged: (value) {
                    setState(() {
                      _distance = value;
                      _calculatedPremium = null;
                      _coverageAmount = null;
                    });
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _calculatePremium,
                    child: const Text('Calculate Premium'),
                  ),
                ),
                if (_calculatedPremium != null) ...[
                  const SizedBox(height: 30),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildInfoRow('Premium Amount', '₹${_calculatedPremium!.toStringAsFixed(2)}'),
                          const Divider(height: 24),
                          _buildInfoRow('Coverage Amount', '₹${_coverageAmount!.toStringAsFixed(2)}'),
                          const Divider(height: 24),
                          _buildInfoRow('Policy Period', '30 days'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    value: _termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        _termsAccepted = value ?? false;
                      });
                    },
                    title: const Text('I accept the terms and conditions'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _purchaseInsurance,
                      child: const Text('Purchase Insurance'),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                _buildCoverageInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCoverageInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What\'s Covered?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildCoverageItem('Damage during transit'),
            _buildCoverageItem('Theft or loss'),
            _buildCoverageItem('Natural calamities'),
            _buildCoverageItem('Accidents'),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverageItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
