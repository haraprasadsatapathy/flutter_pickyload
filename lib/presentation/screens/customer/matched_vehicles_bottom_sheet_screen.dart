import 'package:flutter/material.dart';
import '../../../domain/models/customer_home_page_response.dart';

class VehicleDetailsBottomSheet extends StatefulWidget {
  final VehicleMatch vehicle;
  final BookingDetail booking;
  final Function(double price)? onRequestQuote;
  final Function()? onAccept;
  final Function()? onReject;

  const VehicleDetailsBottomSheet({
    super.key,
    required this.vehicle,
    required this.booking,
    this.onRequestQuote,
    this.onAccept,
    this.onReject,
  });

  @override
  State<VehicleDetailsBottomSheet> createState() => _VehicleDetailsBottomSheetState();
}

class _VehicleDetailsBottomSheetState extends State<VehicleDetailsBottomSheet> {
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    if (widget.vehicle.isAccepted) return Colors.green.shade700;
    if (widget.vehicle.isRejected) return Colors.red.shade700;
    if (widget.vehicle.isWithdrawn) return Colors.grey.shade700;
    if (widget.vehicle.isExpired) return Colors.grey.shade600;
    if (widget.vehicle.isUpdated) return Colors.blue.shade700;
    if (widget.vehicle.isPending) return Colors.orange.shade700;
    if (widget.vehicle.isRequestQuote) return Colors.purple.shade700;
    return Colors.orange.shade700;
  }

  Color _getStatusBgColor() {
    if (widget.vehicle.isAccepted) return Colors.green.shade50;
    if (widget.vehicle.isRejected) return Colors.red.shade50;
    if (widget.vehicle.isWithdrawn) return Colors.grey.shade100;
    if (widget.vehicle.isExpired) return Colors.grey.shade100;
    if (widget.vehicle.isUpdated) return Colors.blue.shade50;
    if (widget.vehicle.isPending) return Colors.orange.shade50;
    if (widget.vehicle.isRequestQuote) return Colors.purple.shade50;
    return Colors.orange.shade50;
  }

  IconData _getStatusIcon() {
    if (widget.vehicle.isAccepted) return Icons.check_circle;
    if (widget.vehicle.isRejected) return Icons.cancel;
    if (widget.vehicle.isWithdrawn) return Icons.remove_circle;
    if (widget.vehicle.isExpired) return Icons.timer_off;
    if (widget.vehicle.isUpdated) return Icons.update;
    if (widget.vehicle.isPending) return Icons.pending;
    if (widget.vehicle.isRequestQuote) return Icons.request_quote;
    return Icons.pending;
  }

  void _showRequestQuoteDialog() {
    _priceController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Your Price'),
        content: TextField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Price',
            prefixText: '\u20B9 ',
            hintText: 'Enter your quoted price',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(_priceController.text);
              if (price != null && price > 0) {
                Navigator.pop(context);
                widget.onRequestQuote?.call(price);
                Navigator.pop(this.context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid price')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusBgColor = _getStatusBgColor();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Vehicle Icon and Name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.local_shipping,
                      color: Theme.of(context).colorScheme.primary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vehicle.vehicleModel,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vehicle No: ${widget.vehicle.vehicleNo}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(),
                      color: statusColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            widget.vehicle.displayStatus,
                            style: TextStyle(
                              fontSize: 16,
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Price Card - Show only when status is Pending or Updated
              if (widget.vehicle.isPending || widget.vehicle.isUpdated) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.currency_rupee,
                        color: Colors.green.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.vehicle.isUpdated ? 'Updated Price' : 'Quoted Price',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade600,
                              ),
                            ),
                            Text(
                              '\u20B9${widget.vehicle.quotedPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Vehicle Details
              Text(
                'Vehicle Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildDetailRow(context, 'Vehicle ID', widget.vehicle.vehicleId),
              _buildDetailRow(context, 'Wheels', '${widget.vehicle.vehicleWheels} Wheels'),
              _buildDetailRow(context, 'Load Type', widget.vehicle.loadType),
              if (widget.vehicle.isAccepted && widget.vehicle.quotedPrice > 0)
                _buildDetailRow(context, 'Final Price', '\u20B9${widget.vehicle.quotedPrice.toStringAsFixed(2)}'),

              const SizedBox(height: 24),

              // Request Quote Button - Show only when status is RequestQuote
              if (widget.vehicle.canRequestQuote) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showRequestQuoteDialog,
                    icon: const Icon(Icons.request_quote),
                    label: const Text('Request Quote'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.purple.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],

              // Accept/Reject Buttons - Show when status is Pending or Updated
              if (widget.vehicle.canAcceptOrReject) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          widget.onReject?.call();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.red.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Reject',
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onAccept?.call();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],

              // Status message for terminal states
              if (widget.vehicle.isWithdrawn) ...[
                _buildStatusMessage(
                  context,
                  Icons.info_outline,
                  'This quote has been withdrawn by the driver.',
                  Colors.grey,
                ),
              ],
              if (widget.vehicle.isExpired) ...[
                _buildStatusMessage(
                  context,
                  Icons.timer_off,
                  'This quote has expired.',
                  Colors.grey,
                ),
              ],
              if (widget.vehicle.isRejected) ...[
                _buildStatusMessage(
                  context,
                  Icons.cancel_outlined,
                  'You have rejected this quote.',
                  Colors.red,
                ),
              ],
              if (widget.vehicle.isAccepted) ...[
                _buildStatusMessage(
                  context,
                  Icons.check_circle_outline,
                  'You have accepted this quote.',
                  Colors.green,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(BuildContext context, IconData icon, String message, MaterialColor color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
