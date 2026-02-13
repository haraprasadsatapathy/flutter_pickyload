import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../domain/models/customer_home_page_response.dart';

class TripDetailsScreen extends StatefulWidget {
  final OngoingTrip trip;

  const TripDetailsScreen({
    super.key,
    required this.trip,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  bool _showPickupOtp = false;
  bool _showDropOtp = false;
  Timer? _pickupOtpTimer;
  Timer? _dropOtpTimer;

  @override
  void dispose() {
    _pickupOtpTimer?.cancel();
    _dropOtpTimer?.cancel();
    super.dispose();
  }

  void _togglePickupOtp() {
    if (_showPickupOtp) {
      // Already showing, hide it
      _pickupOtpTimer?.cancel();
      setState(() {
        _showPickupOtp = false;
      });
    } else {
      // Show OTP and start timer to hide after 5 seconds
      setState(() {
        _showPickupOtp = true;
      });
      _pickupOtpTimer?.cancel();
      _pickupOtpTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showPickupOtp = false;
          });
        }
      });
    }
  }

  void _toggleDropOtp() {
    if (_showDropOtp) {
      // Already showing, hide it
      _dropOtpTimer?.cancel();
      setState(() {
        _showDropOtp = false;
      });
    } else {
      // Show OTP and start timer to hide after 5 seconds
      setState(() {
        _showDropOtp = true;
      });
      _dropOtpTimer?.cancel();
      _dropOtpTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showDropOtp = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final statusColor = widget.trip.statusColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/cancel-booking', extra: widget.trip.tripId),
            icon: const Icon(Icons.cancel_outlined, color: Colors.red),
            label: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.trip_origin,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trip Status',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.trip.displayStatus,
                            style: TextStyle(
                              fontSize: 18,
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

              const SizedBox(height: 16),

              // Pickup & Drop Location
              if (widget.trip.pickupAddress.isNotEmpty || widget.trip.dropAddress.isNotEmpty)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.circle, size: 12, color: Colors.green.shade600),
                            Container(
                              width: 2,
                              height: 30,
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                            ),
                            Icon(Icons.location_on, size: 16, color: Colors.red.shade600),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pickup',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.trip.pickupAddress,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Unload',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.trip.dropAddress,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Vehicle Info Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.local_shipping,
                          size: 28,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehicle Number',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.trip.vehicleNo.toUpperCase(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Driver Details Card
              if (widget.trip.hasDriverDetails)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Driver Details',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 32,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.trip.driverName.isNotEmpty) ...[
                                    Text(
                                      'Driver Name',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.trip.driverName,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                  if (widget.trip.driverName.isNotEmpty && widget.trip.driverNumber.isNotEmpty)
                                    const SizedBox(height: 8),
                                  if (widget.trip.driverNumber.isNotEmpty) ...[
                                    Text(
                                      'Phone Number',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.trip.driverNumber,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (widget.trip.driverNumber.isNotEmpty)
                              IconButton(
                                onPressed: () async {
                                  final Uri phoneUri = Uri(
                                    scheme: 'tel',
                                    path: widget.trip.driverNumber,
                                  );
                                  if (await canLaunchUrl(phoneUri)) {
                                    await launchUrl(phoneUri);
                                  }
                                },
                                icon: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Icon(
                                    Icons.call,
                                    color: Colors.green.shade700,
                                    size: 24,
                                  ),
                                ),
                                tooltip: 'Call Driver',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              if (widget.trip.hasDriverDetails)
                const SizedBox(height: 16),

              // Price & Payment Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPaymentRow(
                        context,
                        icon: Icons.currency_rupee,
                        label: 'Total Price',
                        value: widget.trip.formattedFinalPrice,
                        color: Colors.green.shade700,
                      ),
                      const Divider(height: 24),
                      _buildPaymentRow(
                        context,
                        icon: Icons.payment,
                        label: 'Advance Paid',
                        value: widget.trip.formattedAdvancePaid,
                        color: Colors.blue.shade700,
                      ),
                      const Divider(height: 24),
                      _buildPaymentRow(
                        context,
                        icon: Icons.account_balance_wallet,
                        label: 'Remaining Amount',
                        value: widget.trip.formattedRemainingAmount,
                        color: Colors.orange.shade700,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tags Row - Payment Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.trip.isPaidFull ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.trip.isPaidFull ? Colors.green.shade200 : Colors.orange.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.trip.isPaidFull ? Icons.check_circle : Icons.pending,
                          size: 16,
                          color: widget.trip.isPaidFull ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.trip.isPaidFull ? 'Fully Paid' : 'Partial Payment',
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.trip.isPaidFull ? Colors.green.shade700 : Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Trip Timeline Card
              // Card(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(14),
              //   ),
              //   child: Padding(
              //     padding: const EdgeInsets.all(16.0),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           'Trip Timeline',
              //           style: Theme.of(context).textTheme.titleMedium?.copyWith(
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //         const SizedBox(height: 16),
              //         _buildTimelineRow(
              //           context,
              //           icon: Icons.add_circle_outline,
              //           label: 'Created On',
              //           value: '${dateFormat.format(widget.trip.createdOn)} at ${timeFormat.format(widget.trip.createdOn)}',
              //         ),
              //         const SizedBox(height: 12),
              //         _buildTimelineRow(
              //           context,
              //           icon: Icons.update,
              //           label: 'Last Updated',
              //           value: '${dateFormat.format(widget.trip.modifiedOn)} at ${timeFormat.format(widget.trip.modifiedOn)}',
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              if (widget.trip.pickUpConfirmationOtp.isNotEmpty) ...[
                const SizedBox(height: 16),

                // Pickup Confirmation OTP
                _buildOtpCard(
                  context,
                  title: 'Pickup Confirmation OTP',
                  subtitle: 'Share this OTP with the driver at pickup',
                  otp: widget.trip.pickUpConfirmationOtp,
                  isVisible: _showPickupOtp,
                  onToggle: _togglePickupOtp,
                  gradientColors: [Colors.amber.shade50, Colors.orange.shade50],
                  borderColor: Colors.amber.shade300,
                  iconColor: Colors.orange.shade700,
                  titleColor: Colors.orange.shade800,
                  subtitleColor: Colors.orange.shade700,
                  otpColor: Colors.orange.shade900,
                  otpBorderColor: Colors.amber.shade200,
                ),
              ],

              // Unload Confirmation OTP - Show when OTP is available
              if (widget.trip.dropConfirmationOtp.isNotEmpty) ...[
                const SizedBox(height: 16),

                _buildOtpCard(
                  context,
                  title: 'Unload Confirmation OTP',
                  subtitle: 'Share this OTP with the driver at unload point to end the trip',
                  otp: widget.trip.dropConfirmationOtp,
                  isVisible: _showDropOtp,
                  onToggle: _toggleDropOtp,
                  gradientColors: [Colors.red.shade50, Colors.pink.shade50],
                  borderColor: Colors.red.shade300,
                  iconColor: Colors.red.shade700,
                  titleColor: Colors.red.shade800,
                  subtitleColor: Colors.red.shade700,
                  otpColor: Colors.red.shade900,
                  otpBorderColor: Colors.red.shade200,
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String otp,
    required bool isVisible,
    required VoidCallback onToggle,
    required List<Color> gradientColors,
    required Color borderColor,
    required Color iconColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color otpColor,
    required Color otpBorderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outlined,
                color: iconColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: otpBorderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isVisible ? otp : '******',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: otpColor,
                    letterSpacing: 4,
                  ),
                ),
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility,
                    color: iconColor,
                  ),
                  tooltip: isVisible ? 'Hide OTP' : 'Show OTP',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          if (isVisible) ...[
            const SizedBox(height: 8),
            Text(
              'OTP will be hidden in 5 seconds',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: subtitleColor,
                fontStyle: FontStyle.italic,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
