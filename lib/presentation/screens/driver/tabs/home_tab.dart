import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../config/dependency_injection.dart';
import '../../../../domain/models/subscription_payment_response.dart';
import '../../../../domain/repository/driver_repository.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../services/payment/razorpay_service.dart';
import '../../../cubit/driver/home/home_tab_bloc.dart';
import '../../../cubit/driver/home/home_tab_event.dart';
import '../../../cubit/driver/home/home_tab_state.dart';
import '../../../cubit/driver/subscription/subscription_bloc.dart';
import '../../../cubit/driver/subscription/subscription_event.dart';
import '../../../cubit/driver/subscription/subscription_state.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with WidgetsBindingObserver {
  late final RazorpayService _razorpayService;
  SubscriptionPaymentData? _currentPaymentData;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _razorpayService = RazorpayService();
    _razorpayService.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _razorpayService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HomeTabBloc>().add(FetchHomePage());
    }
  }

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

    return BlocListener<HomeTabBloc, HomeTabState>(
      listener: (context, state) {
        if (state is HomeTabError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.grey.shade600,
            ),
          );
        }
      },
      child: BlocBuilder<HomeTabBloc, HomeTabState>(
        builder: (context, state) {
          final userName = authProvider.currentUser?.name ?? 'Driver';
          final isLoading = state is HomeTabLoading;

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<HomeTabBloc>().add(RefreshHomePage());
              },
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
                          'Welcome Driver',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        Text(
                          userName,
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
                  if (isLoading && state.tripDetails.isEmpty && state.confirmedTrips.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          if (state.tripDetails.isEmpty && state.confirmedTrips.isEmpty) ...[
                            _buildMyDocumentsSection(context, state),
                            const SizedBox(height: 24),
                            _buildEmptyState(context, state),
                          ] else ...[
                            // Confirmed Trips Section
                            if (state.confirmedTrips.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildSectionHeader(
                                context,
                                title: 'Confirmed Trips',
                                count: state.confirmedTrips.length,
                                icon: Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 12),
                              ...state.confirmedTrips.map((trip) => _buildConfirmedTripCard(context, trip)),
                              const SizedBox(height: 24),
                            ],

                            // My Offered Trips Section
                            if (state.tripDetails.isNotEmpty) ...[
                              _buildSectionHeader(
                                context,
                                title: 'My Offered Trips',
                                count: state.tripDetails.length,
                                icon: Icons.local_offer_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 12),
                              ...state.tripDetails.map((trip) => _buildTripCard(context, trip)),
                              const SizedBox(height: 24),
                            ],

                            // Add Load Offer Card when hasActiveSubscription is true and loadStatus is Yes
                            if (state.hasActiveSubscription && state.isAvailableForLoad.toLowerCase() == 'yes') ...[
                              _buildAddLoadOfferCard(context),
                            ],

                            // Show subscription payment card when hasActiveSubscription is false
                            if (!state.hasActiveSubscription) ...[
                              _buildSubscriptionPaymentCard(context),
                            ],
                          ],
                          const SizedBox(height: 80),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmedTripCard(BuildContext context, ConfirmedTrip trip) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final statusColor = _getStatusColor(trip.tripStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: () async {
          await context.push('/confirmed-trip-detail', extra: trip);
          if (mounted) {
            context.read<HomeTabBloc>().add(FetchHomePage());
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            // Status header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        trip.displayStatus,
                        style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 20, color: statusColor),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route information with vertical line
                  Row(
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: Colors.green.shade600,
                          ),
                          Container(
                            width: 2,
                            height: 32,
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          Icon(
                            Icons.location_on,
                            size: 16,
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
                              trip.pickupAddress,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              trip.dropAddress,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
                  ),
                  const SizedBox(height: 16),

                  // Vehicle and Schedule info
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          context,
                          icon: Icons.local_shipping,
                          label: 'Vehicle',
                          value: trip.vehicleNo.toUpperCase(),
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoChip(
                          context,
                          icon: Icons.schedule,
                          label: 'Start Date',
                          value: trip.tripStartDate != null
                              ? dateFormat.format(trip.tripStartDate!)
                              : 'Not set',
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Payment info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildPaymentItem(
                            context,
                            label: 'Advance',
                            value: 'Rs. ${trip.advanceAmount.toStringAsFixed(0)}',
                            color: Colors.green.shade700,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        Expanded(
                          child: _buildPaymentItem(
                            context,
                            label: 'Due',
                            value: 'Rs. ${trip.amountDue.abs().toStringAsFixed(0)}',
                            color: trip.amountDue > 0 ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        Expanded(
                          child: _buildPaymentItem(
                            context,
                            label: 'Total',
                            value: 'Rs. ${trip.finalAmount.toStringAsFixed(0)}',
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TripDetail tripDetail) {
    final bool isDriverOffered = tripDetail.tripStatus.toLowerCase() == 'driveroffered';
    final bool hasUserOffers = tripDetail.userOffers.isNotEmpty;
    final bool canNavigate = isDriverOffered && hasUserOffers;
    final statusColor = _getOfferStatusColor(tripDetail.tripStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: canNavigate
            ? () async {
                await context.push('/user-offers-list', extra: tripDetail);
                if (mounted) {
                  context.read<HomeTabBloc>().add(FetchHomePage());
                }
              }
            : null,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            // Status header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getOfferDisplayStatus(tripDetail.tripStatus),
                        style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (hasUserOffers)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people, size: 14, color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            '${tripDetail.userOffers.length} Offer${tripDetail.userOffers.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route information with vertical line
                  Row(
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: Colors.green.shade600,
                          ),
                          Container(
                            width: 2,
                            height: 32,
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          Icon(
                            Icons.location_on,
                            size: 16,
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
                              tripDetail.pickupAddress,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              tripDetail.dropAddress,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
                  ),
                  const SizedBox(height: 12),

                  // Vehicle info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.local_shipping,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vehicle',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              tripDetail.vehicleNo.toUpperCase(),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // View offers button
                  if (canNavigate) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.visibility, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'View ${tripDetail.userOffers.length} Customer Requested Quote${tripDetail.userOffers.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'inprogress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getOfferStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'driveroffered':
        return Colors.blue;
      case 'pending':
        return Colors.amber;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getOfferDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'driveroffered':
        return 'Offered';
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Widget _buildMyDocumentsSection(BuildContext context, HomeTabState state) {
    final theme = Theme.of(context);

    if (state.isDocumentsLoading) {
      return const SizedBox.shrink();
    }

    final hasRC = state.documents.any(
      (doc) => doc.documentType == 'RegistrationCertificate',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'My Documents',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (state.documents.isNotEmpty)
              TextButton.icon(
                onPressed: () async {
                  await context.push('/document-upload');
                  if (mounted) {
                    context.read<HomeTabBloc>().add(FetchHomePage());
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (!hasRC)
          _buildRCWarningCard(context),

        if (state.documents.isNotEmpty) ...[
          if (!hasRC) const SizedBox(height: 12),
          ...state.documents.map((doc) => _buildDocumentCardCompact(context, doc)),
        ],

        if (state.documents.isEmpty && !state.isDocumentsLoading)
          _buildNoDocumentsCard(context),
      ],
    );
  }

  Widget _buildRCWarningCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.orange.shade900.withValues(alpha: 0.3)
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.orange.shade700.withValues(alpha: 0.5)
              : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Action Required',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Please add your Registration Certificate (RC) to proceed with offering loads.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.orange.shade100 : Colors.orange.shade900,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await context.push('/document-upload');
                if (mounted) {
                  context.read<HomeTabBloc>().add(FetchHomePage());
                }
              },
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text('Add RC'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCardCompact(BuildContext context, DocumentInfo doc) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData iconData;
    Color iconBgColor;
    switch (doc.documentType) {
      case 'DrivingLicense':
        iconData = Icons.badge;
        iconBgColor = Colors.blue;
        break;
      case 'RegistrationCertificate':
        iconData = Icons.directions_car;
        iconBgColor = Colors.green;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconBgColor = colorScheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              iconData,
              color: iconBgColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.documentTypeName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  doc.documentNumber,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          if (doc.isExpired)
            _buildStatusBadge('Expired', Colors.red)
          else if (doc.isExpiringSoon)
            _buildStatusBadge('Expiring', Colors.orange)
          else
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.green,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNoDocumentsCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.red.shade900.withValues(alpha: 0.3)
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.red.shade700.withValues(alpha: 0.5)
              : Colors.red.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_off_outlined,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No Documents Found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please upload your Driving License (DL) and Registration Certificate (RC) to start offering loads.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.red.shade200 : Colors.red.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await context.push('/document-upload');
              if (mounted) {
                context.read<HomeTabBloc>().add(FetchHomePage());
              }
            },
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Upload Documents'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, HomeTabState state) {
    final showAddLoadOffer = state.hasActiveSubscription && state.isAvailableForLoad.toLowerCase() == 'yes';
    final showSubscriptionPayment = !state.hasActiveSubscription;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Trips Available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            showSubscriptionPayment
                ? 'Subscribe to start offering loads and find customers.'
                : 'You haven\'t offered any trips yet.\nStart by adding a load offer to find customers.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (showSubscriptionPayment)
            _buildSubscriptionPaymentCard(context)
          else if (showAddLoadOffer)
            _buildAddLoadOfferCard(context),
        ],
      ),
    );
  }

  Widget _buildAddLoadOfferCard(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () async {
          await context.push('/add-load');
          if (mounted) {
            context.read<HomeTabBloc>().add(FetchHomePage());
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_road,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Load Offer',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Post your route and find customers',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionPaymentCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 3,
      shadowColor: Colors.orange.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    Colors.orange.shade900.withValues(alpha: 0.3),
                    Colors.orange.shade800.withValues(alpha: 0.2),
                  ]
                : [
                    Colors.orange.shade50,
                    Colors.orange.shade100.withValues(alpha: 0.5),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade600,
                          Colors.orange.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subscription Required',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Activate your subscription to start offering loads',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Colors.orange.shade200
                                : Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleSubscribeNow(context),
                  icon: const Icon(Icons.payment, size: 20),
                  label: const Text(
                    'Subscribe Now',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                    shadowColor: Colors.orange.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubscribeNow(BuildContext context) {
    // Show loading dialog and call API
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider(
        create: (context) => SubscriptionBloc(getIt<DriverRepository>())
          ..add(RequestSubscriptionPayment()),
        child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
          listener: (context, state) {
            if (state is SubscriptionPaymentReady) {
              // Close loading dialog
              Navigator.pop(dialogContext);

              // Store payment data and open Razorpay directly
              _currentPaymentData = state.paymentData;
              _openRazorpayCheckout(state.paymentData!);
            } else if (state is SubscriptionError) {
              // Close loading dialog
              Navigator.pop(dialogContext);

              // Show error
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Preparing subscription...'),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openRazorpayCheckout(SubscriptionPaymentData paymentData) {
    setState(() => _isProcessingPayment = true);

    _razorpayService.openCheckout(
      amount: (paymentData.amountPayable * 100).toInt(), // amount in paise
      name: 'Picky Load',
      description: 'Driver Subscription Payment',
      email: paymentData.email,
      contact: paymentData.contact,
      orderId: paymentData.orderId,
      onSuccess: _onPaymentSuccess,
      onFailure: _onPaymentFailure,
      onExternalWallet: _onExternalWallet,
    );
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    final paymentData = _currentPaymentData;
    if (paymentData == null) return;

    debugPrint('=== RAZORPAY SUBSCRIPTION PAYMENT SUCCESS ===');
    debugPrint('PaymentId: ${response.paymentId}');
    debugPrint('OrderId: ${response.orderId}');
    debugPrint('==============================================');

    if (!mounted) return;

    setState(() => _isProcessingPayment = false);

    // Verify payment using repository
    _verifyPayment(
      paymentData: paymentData,
      success: true,
      razorpayPaymentId: response.paymentId ?? '',
      razorpayOrderId: response.orderId ?? '',
      razorpaySignature: response.signature ?? '',
    );
  }

  void _onPaymentFailure(PaymentFailureResponse response) {
    final paymentData = _currentPaymentData;
    if (paymentData == null) return;

    debugPrint('=== RAZORPAY SUBSCRIPTION PAYMENT FAILURE ===');
    debugPrint('Code: ${response.code}');
    debugPrint('Message: ${response.message}');
    debugPrint('==============================================');

    if (!mounted) return;

    setState(() => _isProcessingPayment = false);

    // Parse error details from Razorpay response
    Map<String, dynamic>? errorData;
    if (response.message != null) {
      try {
        errorData = jsonDecode(response.message!) as Map<String, dynamic>;
      } catch (_) {
        // If message is not JSON, use it as description
      }
    }

    // Extract error metadata if available
    final errorMeta = errorData?['error'] as Map<String, dynamic>?;

    // Verify payment (failure case)
    _verifyPayment(
      paymentData: paymentData,
      success: false,
      errorCode: errorMeta?['code']?.toString() ?? response.code?.toString() ?? '',
      errorDescription: errorMeta?['description']?.toString() ?? errorData?['description']?.toString() ?? response.message ?? 'Payment failed',
      errorSource: errorMeta?['source']?.toString() ?? '',
      errorStep: errorMeta?['step']?.toString() ?? '',
      errorReason: errorMeta?['reason']?.toString() ?? '',
      errorOrderId: errorMeta?['metadata']?['order_id']?.toString() ?? '',
      errorPaymentId: errorMeta?['metadata']?['payment_id']?.toString() ?? '',
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    setState(() => _isProcessingPayment = false);
  }

  void _verifyPayment({
    required SubscriptionPaymentData paymentData,
    required bool success,
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
    String? errorCode,
    String? errorDescription,
    String? errorSource,
    String? errorStep,
    String? errorReason,
    String? errorOrderId,
    String? errorPaymentId,
  }) async {
    // Show verifying dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Verifying payment...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final driverRepository = getIt<DriverRepository>();
      final user = await driverRepository.getUserDetailsSp();

      if (user == null || user.id.isEmpty) {
        if (mounted) Navigator.pop(context); // Close verifying dialog
        _showPaymentFailureDialog('Driver ID not found. Please login again.');
        return;
      }

      final response = await driverRepository.verifySubscriptionPayment(
        userId: user.id,
        subscriptionId: paymentData.subscriptionId,
        amount: paymentData.amountPayable,
        isSuccess: success,
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
        errorCode: errorCode,
        errorDescription: errorDescription,
        errorSource: errorSource,
        errorStep: errorStep,
        errorReason: errorReason,
        errorOrderId: errorOrderId,
        errorPaymentId: errorPaymentId,
      );

      if (mounted) Navigator.pop(context); // Close verifying dialog

      if (response.status == true) {
        _showPaymentSuccessDialog(paymentData.amountPayable);
      } else {
        _showPaymentFailureDialog(response.message ?? 'Payment verification failed');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close verifying dialog
      _showPaymentFailureDialog('Failed to verify payment: ${e.toString()}');
    }
  }

  void _showPaymentSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
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
              'Subscription Activated!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '\u20B9${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your subscription has been activated successfully. You can now start offering loads.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              // Refresh home page
              if (mounted) {
                context.read<HomeTabBloc>().add(FetchHomePage());
              }
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showPaymentFailureDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
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
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Retry by calling subscribe again
              _handleSubscribeNow(context);
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
}
