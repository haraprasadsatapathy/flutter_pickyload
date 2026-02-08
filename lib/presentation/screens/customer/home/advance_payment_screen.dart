import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../config/dependency_injection.dart';
import '../../../../domain/models/customer_home_page_response.dart';
import '../../../../domain/models/payment_request_response.dart';
import '../../../../domain/models/verify_payment_request.dart';
import '../../../../domain/repository/customer_repository.dart';
import '../../../../services/local/saved_service.dart';
import '../../../../services/payment/razorpay_service.dart';

class AdvancePaymentScreen extends StatefulWidget {
  final VehicleMatch vehicle;
  final BookingDetail booking;
  final PaymentRequestResponse paymentData;
  final Function()? onPaymentSuccess;

  const AdvancePaymentScreen({
    super.key,
    required this.vehicle,
    required this.booking,
    required this.paymentData,
    this.onPaymentSuccess,
  });

  @override
  State<AdvancePaymentScreen> createState() => _AdvancePaymentScreenState();
}

class _AdvancePaymentScreenState extends State<AdvancePaymentScreen> {
  bool _isProcessing = false;
  late final RazorpayService _razorpayService;
  final CustomerRepository _customerRepository = getIt<CustomerRepository>();
  final SavedService _savedService = getIt<SavedService>();

  double get _quotedPrice => widget.paymentData.totalAmount;
  double get _advanceAmount => widget.paymentData.amountPayable;

  Future<String> _getUserId() async {
    final user = await _savedService.getUserDetailsSp();
    return user?.id ?? '';
  }

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _razorpayService.init();
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _handlePay() {
    setState(() => _isProcessing = true);

    _razorpayService.openCheckout(
      amount: (_advanceAmount * 100).toInt(), // amount in paise
      name: 'Picky Load',
      description: 'Advance payment for Booking #${widget.booking.bookingId}',
      email: widget.paymentData.email,
      contact: widget.paymentData.contact,
      orderId: widget.paymentData.orderId,
      onSuccess: _onPaymentSuccess,
      onFailure: _onPaymentFailure,
      onExternalWallet: _onExternalWallet,
    );
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    final successData = {
      'paymentId': response.paymentId,
      'orderId': response.orderId,
      'signature': response.signature,
      'advanceAmount': _advanceAmount,
      'quotedPrice': widget.vehicle.quotedPrice,
      'bookingId': widget.booking.bookingId,
      'vehicleId': widget.vehicle.vehicleId,
      'offerId': widget.vehicle.offerId,
    };
    debugPrint(jsonEncode(response.data));
    debugPrint('=== RAZORPAY PAYMENT SUCCESS RESPONSE ===');
    debugPrint('$successData');
    debugPrint('==========================================');

    if (!mounted) return;

    // Call verify payment API for success
    final userId = await _getUserId();
    final verifyRequest = VerifyPaymentRequest(
      success: PaymentSuccess(
        razorpayPaymentId: response.paymentId ?? '',
        razorpayOrderId: response.orderId ?? '',
        razorpaySignature: response.signature ?? '',
      ),
      error: null,
      bookingId: widget.booking.bookingId,
      quotationId: widget.paymentData.quotationId,
      userId: userId,
      amount: _advanceAmount,
    );

    debugPrint('=== VERIFY PAYMENT API REQUEST (SUCCESS) ===');
    debugPrint('Request Data: ${jsonEncode(verifyRequest.toJson())}');
    debugPrint('=============================================');

    final verifyResponse = await _customerRepository.verifyPayment(
      request: verifyRequest,
    );

    debugPrint('=== VERIFY PAYMENT API RESPONSE ===');
    debugPrint('Status: ${verifyResponse.status}');
    debugPrint('Message: ${verifyResponse.message}');
    debugPrint('Data: ${verifyResponse.data}');
    debugPrint('===================================');

    if (!mounted) return;
    setState(() => _isProcessing = false);

    widget.onPaymentSuccess?.call();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '\u20B9${_advanceAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your booking has been confirmed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/customer-dashboard');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _onPaymentFailure(PaymentFailureResponse response) async {
    final failureData = {
      'code': response.code,
      'message': response.message,
      'advanceAmount': _advanceAmount,
      'quotedPrice': widget.vehicle.quotedPrice,
      'bookingId': widget.booking.bookingId,
      'vehicleId': widget.vehicle.vehicleId,
      'offerId': widget.vehicle.offerId,
    };
    debugPrint('=== RAZORPAY PAYMENT FAILURE RESPONSE ===');
    debugPrint('$failureData');
    debugPrint('==========================================');

    if (!mounted) return;

    // Parse error details from Razorpay response
    Map<String, dynamic>? errorData;
    if (response.message != null) {
      try {
        errorData = jsonDecode(response.message!) as Map<String, dynamic>;
      } catch (_) {
        // If message is not JSON, use it as description
      }
    }

    // Call verify payment API for failure
    final userId = await _getUserId();
    final verifyRequest = VerifyPaymentRequest(
      success: null,
      error: PaymentError(
        code: errorData?['code']?.toString() ?? response.code?.toString() ?? '',
        description: errorData?['description'] ?? response.message ?? 'Payment failed',
        source: errorData?['source'] ?? 'customer',
        step: errorData?['step'] ?? 'payment_authentication',
        reason: errorData?['reason'] ?? 'payment_failed',
        orderId: errorData?['metadata']?['order_id'] ?? widget.paymentData.orderId,
        paymentId: errorData?['metadata']?['payment_id'] ?? '',
      ),
      bookingId: widget.booking.bookingId,
      quotationId: widget.paymentData.quotationId,
      userId: userId,
      amount: _advanceAmount,
    );

    debugPrint('=== VERIFY PAYMENT API REQUEST (FAILURE) ===');
    debugPrint('Request Data: ${jsonEncode(verifyRequest.toJson())}');
    debugPrint('=============================================');

    final verifyResponse = await _customerRepository.verifyPayment(
      request: verifyRequest,
    );

    debugPrint('=== VERIFY PAYMENT API RESPONSE (FAILURE) ===');
    debugPrint('Status: ${verifyResponse.status}');
    debugPrint('Message: ${verifyResponse.message}');
    debugPrint('Data: ${verifyResponse.data}');
    debugPrint('=============================================');

    if (!mounted) return;
    setState(() => _isProcessing = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Failed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              errorData?['description'] ?? response.message ?? 'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handlePay();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry Payment'),
          ),
        ],
      ),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advance Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Summary Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Payment Summary',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPriceRow('Total Amount', _quotedPrice),
                            _buildPriceRow('Advance Amount', _advanceAmount),
                            const Divider(height: 24),
                            _buildPriceRow(
                              'Amount to Pay Now',
                              _advanceAmount,
                              isBold: true,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Info message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'To confirm your booking, please pay the advance amount. The remaining amount will be collected upon delivery.',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Non-refundable warning
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'The advance payment is non-refundable. By proceeding, you agree that the advance amount will not be refunded in case of cancellation.',
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Trip Details Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trip Details',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTripDetailRow(
                              Icons.local_shipping,
                              'Vehicle',
                              '${widget.vehicle.vehicleModel} (${widget.vehicle.vehicleNo})',
                            ),
                            _buildTripDetailRow(
                              Icons.location_on,
                              'Pickup',
                              widget.booking.pickupAddress,
                            ),
                            _buildTripDetailRow(
                              Icons.flag,
                              'Drop',
                              widget.booking.dropAddress,
                            ),
                            _buildTripDetailRow(
                              Icons.straighten,
                              'Distance',
                              widget.booking.formattedDistance,
                            ),
                            _buildTripDetailRow(
                              Icons.inventory_2,
                              'Load',
                              '${widget.booking.loadName} (${widget.booking.loadCapacityLabel})',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pay Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handlePay,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Pay \u20B9${_advanceAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            '\u20B9${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
