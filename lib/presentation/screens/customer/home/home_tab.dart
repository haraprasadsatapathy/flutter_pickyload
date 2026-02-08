import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:picky_load/presentation/cubit/customer/home/customer_home_tab_bloc.dart';
import 'package:picky_load/presentation/cubit/customer/home/customer_home_tab_event.dart';
import 'package:picky_load/presentation/cubit/customer/home/customer_home_tab_state.dart';
import 'package:provider/provider.dart';

import '../../../../providers/theme_provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<CustomerHomeTabBloc>().add(RefreshHomePage());
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
                context.read<CustomerHomeTabBloc>().add(LogoutUser());
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return BlocConsumer<CustomerHomeTabBloc, CustomerHomeTabState>(
      listener: (context, state) {
        if (state is CustomerHomeTabLoggedOut) {
          context.go('/login');
        } else if (state is CustomerHomeTabError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        final userName = state.user?.name ?? 'User';
        final isLoading = state.isLoading;

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<CustomerHomeTabBloc>().add(RefreshHomePage());
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
                        'Welcome',
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
                if (isLoading && state.bookingDetails.isEmpty && state.ongoingTrips.isEmpty)
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
                        // Ongoing Trips Section
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Ongoing Trips',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (state.ongoingTrips.isNotEmpty)
                              Text(
                                '${state.ongoingTrips.length}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (state.ongoingTrips.isEmpty)
                          _buildNoOngoingTripsState(context)
                        else
                          ...state.ongoingTrips.map((trip) => _buildTripCard(context, trip)),
                        const SizedBox(height: 24),

                        // Booking Details Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Bookings',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (state.bookingDetails.isNotEmpty)
                              Text(
                                '${state.bookingDetails.length}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (state.bookingDetails.isEmpty && !isLoading)
                          _buildEmptyState(context)
                        else
                          ...state.bookingDetails.map((booking) => _buildBookingCard(context, booking)),

                        const SizedBox(height: 80), // Space for FAB
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoOngoingTripsState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'No Ongoing Trips',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your active trips will appear here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
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
            'No Bookings Yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to request a load',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingDetail booking) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final hasMatchedVehicles = booking.vehicleMatch.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: hasMatchedVehicles
            ? () async {
                await context.push('/matched-vehicles', extra: booking);
                if (mounted) {
                  context.read<CustomerHomeTabBloc>().add(RefreshHomePage());
                }
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header with load name and capacity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.loadName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
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
                      size: 12,
                      color: Colors.green.shade600,
                    ),
                    Container(
                      width: 2,
                      height: 24,
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
                        booking.pickupAddress,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        booking.dropAddress,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Distance and booking time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!hasMatchedVehicles)
                  Row(
                    children: [
                      Icon(
                        Icons.straighten,
                        size: 16,
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
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dateFormat.format(booking.bookingOn)} at ${timeFormat.format(booking.bookingOn)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Highlighted distance and vehicle matched count
            if (hasMatchedVehicles) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                      Colors.green.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    // Distance highlight
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.route,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Distance',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                ),
                              ),
                              Text(
                                booking.formattedDistance,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    // Vehicle matched count highlight
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.local_shipping,
                              size: 18,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vehicles Matched',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                ),
                              ),
                              Text(
                                '${booking.vehicleMatch.length}',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Vehicle match details
            if (booking.vehicleMatch.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...booking.vehicleMatch.map((vehicle) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    // Vehicle number and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_shipping, size: 16, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              vehicle.vehicleNo.toUpperCase(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: vehicle.isAccepted
                                ? Colors.green.shade50
                                : vehicle.isRejected
                                    ? Colors.red.shade50
                                    : vehicle.isUpdated
                                        ? Colors.blue.shade50
                                        : vehicle.isPending
                                            ? Colors.amber.shade50
                                            : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: vehicle.isAccepted
                                  ? Colors.green.shade300
                                  : vehicle.isRejected
                                      ? Colors.red.shade300
                                      : vehicle.isUpdated
                                          ? Colors.blue.shade300
                                          : vehicle.isPending
                                              ? Colors.amber.shade300
                                              : Colors.orange.shade300,
                            ),
                          ),
                          child: Text(
                            vehicle.displayStatus,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: vehicle.isAccepted
                                  ? Colors.green.shade700
                                  : vehicle.isRejected
                                      ? Colors.red.shade700
                                      : vehicle.isUpdated
                                          ? Colors.blue.shade700
                                          : vehicle.isPending
                                              ? Colors.amber.shade700
                                              : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Price, wheels, load type
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.currency_rupee, size: 14, color: Colors.green.shade700),
                              const SizedBox(width: 4),
                              Text(
                                vehicle.quotedPrice.toStringAsFixed(0),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.tire_repair, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${vehicle.vehicleWheels} wheels',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.inventory_2, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  vehicle.loadType,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
            ],
            // Chevron indicator for navigation
            if (hasMatchedVehicles) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, OngoingTrip trip) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final statusColor = trip.statusColor;

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
          await context.push('/trip-tracking', extra: trip);
          if (mounted) {
            context.read<CustomerHomeTabBloc>().add(RefreshHomePage());
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
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              trip.vehicleNo.toUpperCase(),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${dateFormat.format(trip.createdOn)} at ${timeFormat.format(trip.createdOn)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
                  ),
                  const SizedBox(height: 14),

                  // Price and payment info
                  Row(
                    children: [
                      Expanded(
                        child: _buildTripInfoItem(
                          context,
                          Icons.currency_rupee,
                          'Total Price',
                          trip.formattedFinalPrice,
                          Colors.green.shade700,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                      ),
                      Expanded(
                        child: _buildTripInfoItem(
                          context,
                          Icons.payment,
                          'Advance Paid',
                          trip.formattedAdvancePaid,
                          Colors.blue.shade700,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                      ),
                      Expanded(
                        child: _buildTripInfoItem(
                          context,
                          Icons.account_balance_wallet,
                          'Remaining',
                          trip.formattedRemainingAmount,
                          Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Insurance and payment status
                  Row(
                    children: [
                      if (trip.insuranceOpted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield, size: 14, color: Colors.green.shade700),
                              const SizedBox(width: 4),
                              Text(
                                'Insured',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: trip.isPaidFull ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: trip.isPaidFull ? Colors.green.shade200 : Colors.orange.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              trip.isPaidFull ? Icons.check_circle : Icons.pending,
                              size: 14,
                              color: trip.isPaidFull ? Colors.green.shade700 : Colors.orange.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              trip.isPaidFull ? 'Fully Paid' : 'Partial Payment',
                              style: TextStyle(
                                fontSize: 11,
                                color: trip.isPaidFull ? Colors.green.shade700 : Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
