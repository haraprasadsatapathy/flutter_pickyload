import 'package:flutter/material.dart';
import '../../../../domain/models/customer_home_page_response.dart';
import '../../../../domain/models/payment_request_response.dart';
import 'advance_payment_screen.dart';

class VehicleDetailsBottomSheet extends StatefulWidget {
  final VehicleMatch vehicle;
  final BookingDetail booking;
  final Function(double price)? onRequestQuote;
  final Future<PaymentRequestResponse?> Function()? onAccept;
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
  bool _isLoading = false;

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
    if (widget.vehicle.isPending) return Colors.amber.shade700;
    if (widget.vehicle.isRequestQuote) return Colors.purple.shade700;
    return Colors.amber.shade700;
  }

  Color _getStatusBgColor() {
    if (widget.vehicle.isAccepted) return Colors.green.shade50;
    if (widget.vehicle.isRejected) return Colors.red.shade50;
    if (widget.vehicle.isWithdrawn) return Colors.grey.shade100;
    if (widget.vehicle.isExpired) return Colors.grey.shade100;
    if (widget.vehicle.isUpdated) return Colors.blue.shade50;
    if (widget.vehicle.isPending) return Colors.amber.shade50;
    if (widget.vehicle.isRequestQuote) return Colors.purple.shade50;
    return Colors.amber.shade50;
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

  Future<void> _handleRequestQuote() async {
    setState(() => _isLoading = true);
    try {
      widget.onRequestQuote?.call(0);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleAccept() async {
    setState(() => _isLoading = true);
    try {
      final paymentData = await widget.onAccept?.call();
      if (!mounted) return;

      if (paymentData != null) {
        // API succeeded — close bottom sheet and navigate to advance payment screen
        final navigator = Navigator.of(context);
        navigator.pop();
        navigator.push(
          MaterialPageRoute(
            builder: (_) => AdvancePaymentScreen(
              vehicle: widget.vehicle,
              booking: widget.booking,
              paymentData: paymentData,
            ),
          ),
        );
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleReject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      widget.onReject?.call();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
      }
    }
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
        return Stack(
          children: [
            SingleChildScrollView(
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

                  // Pending status message
                  if (widget.vehicle.isPending) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Waiting for driver response',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Price Card - Show when status is Updated
                  if (widget.vehicle.isUpdated) ...[
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
                                  'Updated Price',
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
                        onPressed: _isLoading ? null : _handleRequestQuote,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.request_quote),
                        label: Text(_isLoading ? 'Requesting...' : 'Request Quote'),
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

                  // Accept/Reject Buttons - Show when status is Updated (driver responded with price)
                  if (widget.vehicle.isUpdated) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _handleReject,
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
                            onPressed: _isLoading ? null : _handleAccept,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Accept'),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Status messages for terminal states
                  if (widget.vehicle.isPending) ...[
                    _buildStatusMessage(
                      context,
                      Icons.hourglass_top,
                      'Quote requested. Waiting for driver to respond with a price.',
                      Colors.orange,
                    ),
                  ],
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
                      'You have accepted this quote. Booking confirmed!',
                      Colors.green,
                    ),
                  ],
                ],
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black12,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
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
