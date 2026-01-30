import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/repository/trip_repository.dart';
import '../../../../domain/models/booking_history_response.dart';
import '../../../cubit/my_trips/my_trips_bloc.dart';
import '../../../cubit/my_trips/my_trips_event.dart';
import '../../../cubit/my_trips/my_trips_state.dart';

class MyTripsTab extends StatelessWidget {
  const MyTripsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyTripsBloc(context, context.read<TripRepository>()),
      child: const _MyTripsTabContent(),
    );
  }
}

class _MyTripsTabContent extends StatefulWidget {
  const _MyTripsTabContent();

  @override
  State<_MyTripsTabContent> createState() => _MyTripsTabContentState();
}

class _MyTripsTabContentState extends State<_MyTripsTabContent> {
  @override
  void initState() {
    super.initState();
    // Load trips when the widget is initialized
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    print('🔧 MyTripsTab: Loading trips...');
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    print('👤 MyTripsTab: Retrieved userId from SharedPreferences: $userId');

    if (!mounted) {
      print('⚠️ MyTripsTab: Widget not mounted');
      return;
    }

    if (userId.isEmpty) {
      print('⚠️ MyTripsTab: userId is empty - user may not be logged in');
      // Show error state if userId is not found
      context.read<MyTripsBloc>().add(LoadMyTrips(userId: ''));
      return;
    }

    print('✨ MyTripsTab: Dispatching LoadMyTrips event');
    context.read<MyTripsBloc>().add(LoadMyTrips(userId: userId));
  }

  Future<void> _refreshTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (userId.isNotEmpty && mounted) {
      context.read<MyTripsBloc>().add(RefreshMyTrips(userId: userId));
    }
  }

  void _showCancelConfirmationDialog(BuildContext context, BookingHistory trip) {
    // Get the bloc before async operations
    final bloc = context.read<MyTripsBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel this booking?\n\nRoute: ${trip.route}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              // Get userId from SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              final userId = prefs.getString('userId') ?? '';
              if (userId.isNotEmpty) {
                bloc.add(
                  CancelBooking(
                    userId: userId,
                    bookingId: trip.bookingId,
                  ),
                );
              }
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyTripsBloc, MyTripsStates>(
      listener: (context, state) {
        // Handle navigation to trip details
        if (state is OnNavigateToTripDetails) {
          // TODO: Navigate to trip details screen
          // context.push('/trip-details/${state.tripId}');
        }

        // Handle booking canceled successfully
        if (state is OnBookingCanceled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // Handle booking cancel failed
        if (state is OnBookingCancelFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        return SafeArea(
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
                title: const Text('My Trips'),
              ),
              // Content based on state
              if (state is OnMyTripsLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state is OnMyTripsError)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadTrips,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (state is OnMyTripsEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadTrips,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (state is OnMyTripsLoaded)
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0) {
                          // Add pull-to-refresh indicator at the top
                          return RefreshIndicator(
                            onRefresh: () async {
                              _refreshTrips();
                              // Wait for the refresh to complete
                              await Future.delayed(const Duration(milliseconds: 500));
                            },
                            child: _buildTripCard(context, state.trips[0]),
                          );
                        }
                        return _buildTripCard(context, state.trips[index]);
                      },
                      childCount: state.trips.length,
                    ),
                  ),
                )
              else
                const SliverFillRemaining(
                  child: Center(
                    child: Text('No trips available'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTripCard(BuildContext context, BookingHistory trip) {
    // Determine status color
    Color statusColor;
    switch (trip.bookingStatus.toLowerCase()) {
      case 'requested':
        statusColor = Colors.blue;
        break;
      case 'pending':
        statusColor = Colors.amber;
        break;
      case 'accepted':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'in_progress':
      case 'in progress':
        statusColor = Colors.orange;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.read<MyTripsBloc>().add(
            NavigateToTripDetails(tripId: trip.bookingId),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatStatus(trip.bookingStatus),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.scale, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${trip.loadCapacity.toStringAsFixed(0)} kg',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // From Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.trip_origin, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'From',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          trip.pickupAddress,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // To Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'To',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          trip.dropAddress,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trip.vehicleType,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (trip.isInsured) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_user, size: 14, color: Colors.green[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Insured',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(trip.bookingDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'requested':
        return 'Requested';
      case 'accepted':
        return 'Accepted';
      case 'in_progress':
      case 'in progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
