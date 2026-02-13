import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/dependency_injection.dart';
import '../../../../domain/models/customer_home_page_response.dart';
import '../../../../domain/models/payment_request_response.dart';
import '../../../../domain/repository/customer_repository.dart';
import '../../../../services/local/saved_service.dart';
import 'advance_payment_screen.dart';
import 'matched_vehicles_bottom_sheet_screen.dart';

class MatchedVehiclesScreen extends StatefulWidget {
  final BookingDetail booking;

  const MatchedVehiclesScreen({super.key, required this.booking});

  @override
  State<MatchedVehiclesScreen> createState() => _MatchedVehiclesScreenState();
}

class _MatchedVehiclesScreenState extends State<MatchedVehiclesScreen> {
  final CustomerRepository _customerRepository = getIt<CustomerRepository>();
  final SavedService _savedService = getIt<SavedService>();

  Future<String> _getUserId() async {
    final user = await _savedService.getUserDetailsSp();
    return user?.id ?? '';
  }

  Future<bool> _onRequestQuote(VehicleMatch vehicle) async {
    final userId = await _getUserId();
    if (userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found. Please login again.')),
        );
      }
      return false;
    }

    final response = await _customerRepository.requestQuote(
      userId: userId,
      bookingId: widget.booking.bookingId,
      offerId: vehicle.offerId,
    );

    if (!mounted) return false;

    if (response.status == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quote requested successfully. Waiting for driver response.')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Failed to request quote')),
      );
      return false;
    }
  }

  Future<PaymentRequestResponse?> _onAcceptOffer(VehicleMatch vehicle) async {
    final response = await _customerRepository.requestPayment(
      bookingId: widget.booking.bookingId,
      offerId: vehicle.offerId,
    );

    if (!mounted) return null;

    // Check if data is available (API returns data on success, status field may be absent)
    if (response.data != null) {
      return response.data;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Failed to request payment')),
        );
      }
      return null;
    }
  }

  Future<void> _onRejectBooking(VehicleMatch vehicle) async {
    final userId = await _getUserId();
    if (userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found. Please login again.')),
        );
      }
      return;
    }

    final response = await _customerRepository.cancelBooking(
      userId: userId,
      bookingId: widget.booking.bookingId,
    );

    if (!mounted) return;

    if (response.status == true) {
      setState(() {
        vehicle.status = 'Rejected';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Failed to cancel booking')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final booking = widget.booking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matched Vehicles'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Booking Details Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        booking.loadName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        booking.loadCapacityLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Route information
                Row(
                  children: [
                    Column(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: Colors.green.shade600,
                        ),
                        Container(
                          width: 2,
                          height: 20,
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.red.shade600,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.pickupAddress,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            booking.dropAddress,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dateFormat.format(booking.bookingOn)} at ${timeFormat.format(booking.bookingOn)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.straighten,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking.formattedDistance,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Matched Vehicles List Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Vehicles',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${booking.vehicleMatch.length} found',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Vehicles List
          Expanded(
            child: booking.vehicleMatch.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: booking.vehicleMatch.length,
                    itemBuilder: (context, index) {
                      return _buildVehicleCard(context, booking.vehicleMatch[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Vehicles Matched',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No vehicles have been matched for this booking yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, VehicleMatch vehicle) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    if (vehicle.isAccepted) {
      statusColor = Colors.green.shade700;
      statusBgColor = Colors.green.shade50;
      statusIcon = Icons.check_circle;
    } else if (vehicle.isRejected) {
      statusColor = Colors.red.shade700;
      statusBgColor = Colors.red.shade50;
      statusIcon = Icons.cancel;
    } else if (vehicle.isPending) {
      statusColor = Colors.amber.shade700;
      statusBgColor = Colors.amber.shade50;
      statusIcon = Icons.pending;
    } else if (vehicle.isUpdated) {
      statusColor = Colors.orange.shade700;
      statusBgColor = Colors.orange.shade50;
      statusIcon = Icons.update;
    } else if (vehicle.isRequestQuote) {
      statusColor = Colors.purple.shade700;
      statusBgColor = Colors.purple.shade50;
      statusIcon = Icons.request_quote;
    } else {
      statusColor = Colors.orange.shade700;
      statusBgColor = Colors.orange.shade50;
      statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showVehicleDetailsBottomSheet(context, vehicle);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_shipping,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.vehicleNo.toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (vehicle.isUpdated && vehicle.quotedPrice > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.currency_rupee,
                                size: 14,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                vehicle.quotedPrice.toStringAsFixed(0),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.displayStatus,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(
                    context,
                    Icons.settings,
                    '${vehicle.vehicleWheels} Wheels',
                  ),
                  _buildInfoChip(
                    context,
                    Icons.category_outlined,
                    vehicle.loadType,
                  ),
                ],
              ),
              // Show pending message for Pending status
              if (vehicle.isPending) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Waiting for driver response',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isHighlighted
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isHighlighted
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showVehicleDetailsBottomSheet(BuildContext context, VehicleMatch vehicle) async {
    final shouldNavigateHome = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => VehicleDetailsBottomSheet(
        vehicle: vehicle,
        booking: widget.booking,
        onRequestQuote: () => _onRequestQuote(vehicle),
        onAccept: () => _onAcceptOffer(vehicle),
        onReject: () => _onRejectBooking(vehicle),
      ),
    );

    // Navigate back to home screen after successful quote request
    // The home screen will refresh automatically via its existing RefreshHomePage logic
    if (shouldNavigateHome == true && mounted) {
      context.pop();
    }
  }
}
