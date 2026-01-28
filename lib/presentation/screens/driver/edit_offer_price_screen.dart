import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../cubit/driver/offer_loads_list/offer_loads_list_state.dart';
import '../../cubit/driver/update_offer_price/update_offer_price_bloc.dart';
import '../../cubit/driver/update_offer_price/update_offer_price_event.dart';
import '../../cubit/driver/update_offer_price/update_offer_price_state.dart';

class EditOfferPriceScreen extends StatefulWidget {
  final OfferLoadModel offerLoad;

  const EditOfferPriceScreen({
    super.key,
    required this.offerLoad,
  });

  @override
  State<EditOfferPriceScreen> createState() => _EditOfferPriceScreenState();
}

class _EditOfferPriceScreenState extends State<EditOfferPriceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final driverId = authProvider.currentUser?.id ?? '';
      final price = double.tryParse(_priceController.text) ?? 0;

      // TODO: This screen needs quotationId and bookingId from the API
      // For now, using empty strings - this may need to be updated
      // when the OfferLoadModel includes these fields
      context.read<UpdateOfferPriceBloc>().add(
            UpdateOfferPrice(
              quotationId: '', // Not available in OfferLoadModel yet
              offerId: widget.offerLoad.offerId,
              driverId: driverId,
              bookingId: '', // Not available in OfferLoadModel yet
              price: price,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Offer Price'),
      ),
      body: BlocListener<UpdateOfferPriceBloc, UpdateOfferPriceState>(
        listener: (context, state) {
          if (state is OfferPriceUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back to the list screen
            Navigator.of(context).pop(true);
          } else if (state is UpdateOfferPriceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<UpdateOfferPriceBloc, UpdateOfferPriceState>(
          builder: (context, state) {
            final isLoading = state is UpdateOfferPriceLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Offer Details Card
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Offer Details',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.location_on,
                              label: 'Route',
                              value: '${widget.offerLoad.origin} → ${widget.offerLoad.destination}',
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.calendar_today,
                              label: 'Available From',
                              value: widget.offerLoad.formattedStartTime,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.calendar_today,
                              label: 'Available Until',
                              value: widget.offerLoad.formattedEndTime,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.info_outline,
                              label: 'Status',
                              value: widget.offerLoad.status,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Price Input Section
                    Text(
                      'Update Price',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Price',
                        hintText: 'Enter offer price',
                        prefixIcon: const Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        final price = double.tryParse(value);
                        if (price == null) {
                          return 'Please enter a valid number';
                        }
                        if (price <= 0) {
                          return 'Price must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Update Price',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
