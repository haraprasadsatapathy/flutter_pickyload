import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/data_source/api_client.dart';
import '../../../../domain/models/customer_trip_history_response.dart';
import '../../../../domain/repository/customer_repository.dart';
import '../../../../domain/repository/trip_repository.dart';
import '../../../../domain/models/booking_history_response.dart';
import '../../../../services/local/saved_service.dart';
import '../../../cubit/my_trips/my_trips_bloc.dart';
import '../../../cubit/my_trips/my_trips_event.dart';
import '../../../cubit/my_trips/my_trips_state.dart';
import '../../../cubit/customer/customer_trip_history/customer_trip_history_bloc.dart';
import '../../../cubit/customer/customer_trip_history/customer_trip_history_event.dart';
import '../../../cubit/customer/customer_trip_history/customer_trip_history_state.dart';

class MyTripsTab extends StatelessWidget {
  const MyTripsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final savedService = SavedService();
    final customerRepository = CustomerRepository(apiClient, savedService);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MyTripsBloc(context, context.read<TripRepository>()),
        ),
        BlocProvider(
          create: (context) {
            final bloc = CustomerTripHistoryBloc(context, customerRepository);
            _loadTripHistory(bloc);
            return bloc;
          },
        ),
      ],
      child: const _MyTripsTabContent(),
    );
  }

  static Future<void> _loadTripHistory(CustomerTripHistoryBloc bloc) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    if (userId.isNotEmpty) {
      bloc.add(FetchCustomerTripHistory(userId: userId));
    }
  }
}

class _MyTripsTabContent extends StatefulWidget {
  const _MyTripsTabContent();

  @override
  State<_MyTripsTabContent> createState() => _MyTripsTabContentState();
}

class _MyTripsTabContentState extends State<_MyTripsTabContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
    // Load bookings when the widget is initialized
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (!mounted) return;

    if (userId.isEmpty) {
      context.read<MyTripsBloc>().add(LoadMyTrips(userId: ''));
      return;
    }

    context.read<MyTripsBloc>().add(LoadMyTrips(userId: userId));
  }

  Future<void> _loadTripHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (!mounted || userId.isEmpty) return;

    context.read<CustomerTripHistoryBloc>().add(FetchCustomerTripHistory(userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return BlocListener<MyTripsBloc, MyTripsStates>(
      listener: (context, state) {
        if (state is OnBookingCanceled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        if (state is OnBookingCancelFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.grey.shade600,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // App Bar Row
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 40,
                          height: 40,
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
                      const Expanded(
                        child: Text(
                          'My Activity',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Professional Segmented Tab Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // My Bookings Tab
                        Expanded(
                          child: _buildSegmentedTab(
                            index: 0,
                            icon: Icons.bookmark_rounded,
                            label: 'My Bookings',
                            isSelected: _currentIndex == 0,
                            primaryColor: primaryColor,
                            countBuilder: () {
                              return BlocBuilder<MyTripsBloc, MyTripsStates>(
                                builder: (context, state) {
                                  if (state is OnMyTripsLoaded && state.trips.isNotEmpty) {
                                    return _buildCountBadge(state.trips.length, _currentIndex == 0, primaryColor);
                                  }
                                  return const SizedBox.shrink();
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 4),

                        // My Trips Tab
                        Expanded(
                          child: _buildSegmentedTab(
                            index: 1,
                            icon: Icons.route_rounded,
                            label: 'My Trips',
                            isSelected: _currentIndex == 1,
                            primaryColor: primaryColor,
                            countBuilder: () {
                              return BlocBuilder<CustomerTripHistoryBloc, CustomerTripHistoryState>(
                                builder: (context, state) {
                                  if (state.trips.isNotEmpty) {
                                    return _buildCountBadge(state.trips.length, _currentIndex == 1, primaryColor);
                                  }
                                  return const SizedBox.shrink();
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  MyBookingsContent(),
                  MyTripsContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedTab({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color primaryColor,
    required Widget Function() countBuilder,
  }) {
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? primaryColor : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? primaryColor : Colors.grey.shade600,
                ),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 6),
            countBuilder(),
          ],
        ),
      ),
    );
  }

  Widget _buildCountBadge(int count, bool isSelected, Color primaryColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================
// MY BOOKINGS TAB CONTENT
// ============================================

class MyBookingsContent extends StatelessWidget {
  const MyBookingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyTripsBloc, MyTripsStates>(
      builder: (context, state) {
        if (state is OnMyTripsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is OnMyTripsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final userId = prefs.getString('userId') ?? '';
                    if (userId.isNotEmpty && context.mounted) {
                      context.read<MyTripsBloc>().add(LoadMyTrips(userId: userId));
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is OnMyTripsEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bookmark_outline_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Bookings Yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your bookings will appear here.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          );
        }

        if (state is OnMyTripsLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: state.trips.length,
            itemBuilder: (context, index) {
              final trip = state.trips[index];
              return _buildBookingCard(context, trip);
            },
          );
        }

        return const Center(
          child: Text('No bookings available'),
        );
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingHistory trip) {
    final statusColor = _getStatusColor(trip.bookingStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Status bar at top
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
                    Icon(
                      _getStatusIcon(trip.bookingStatus),
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatStatus(trip.bookingStatus),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.scale, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.loadCapacity.toStringAsFixed(0)} kg',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Card body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Route visualization
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route line indicator
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.green.shade500,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 36,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.green.shade400,
                                  Colors.red.shade400,
                                ],
                              ),
                            ),
                          ),
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.red.shade500,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Addresses
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PICKUP',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            trip.pickupAddress,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'UNLOAD',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            trip.dropAddress,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                const SizedBox(height: 12),

                // Vehicle and Insurance info
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              trip.vehicleType,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Date info
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(trip.bookingDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'requested':
        return Colors.blue;
      case 'pending':
        return Colors.amber;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in_progress':
      case 'in progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'requested':
        return Icons.send_rounded;
      case 'pending':
        return Icons.hourglass_empty;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'in_progress':
      case 'in progress':
        return Icons.local_shipping;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'requested':
        return 'Requested';
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
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
}

// ============================================
// MY TRIPS TAB CONTENT
// ============================================

class MyTripsContent extends StatelessWidget {
  const MyTripsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerTripHistoryBloc, CustomerTripHistoryState>(
      builder: (context, state) {
        if (state is CustomerTripHistoryLoading && state.trips.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is CustomerTripHistoryError && state.trips.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    state.error,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final userId = prefs.getString('userId') ?? '';
                    if (userId.isNotEmpty && context.mounted) {
                      context.read<CustomerTripHistoryBloc>().add(
                            FetchCustomerTripHistory(userId: userId),
                          );
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.trips.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.route_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Trips Yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your completed trips will appear here.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: state.trips.length,
          itemBuilder: (context, index) {
            final trip = state.trips[index];
            return _buildTripCard(context, trip);
          },
        );
      },
    );
  }

  Widget _buildTripCard(BuildContext context, CustomerTripHistoryModel trip) {
    final statusColor = _getStatusColor(trip.status);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Status bar at top
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
                    Icon(
                      _getStatusIcon(trip.status),
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      trip.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trip.formattedFinalPrice,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Vehicle info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        context,
                        Icons.local_shipping_outlined,
                        'Vehicle',
                        trip.vehicleNo,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoChip(
                        context,
                        Icons.person_outline,
                        'Driver',
                        trip.clientName,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Route visualization
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route line indicator
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.green.shade500,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 36,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.green.shade400,
                                  Colors.red.shade400,
                                ],
                              ),
                            ),
                          ),
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.red.shade500,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Addresses
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PICKUP',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            trip.pickupAddress,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'UNLOAD',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            trip.dropAddress,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                const SizedBox(height: 12),

                // Payment info
                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentInfo(
                        context,
                        Icons.payments_outlined,
                        'Advance Paid',
                        trip.formattedAdvanceAmount,
                        Colors.green,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                    ),
                    Expanded(
                      child: _buildPaymentInfo(
                        context,
                        Icons.account_balance_wallet_outlined,
                        'Remaining',
                        trip.formattedRemainingAmount,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
                ),
                const SizedBox(height: 12),

                // Trip dates
                Row(
                  children: [
                    Expanded(
                      child: _buildTripDateInfo(
                        context,
                        Icons.calendar_today_outlined,
                        'Booking Date',
                        dateFormat.format(trip.bookingDate),
                      ),
                    ),
                  ],
                ),
                if (trip.tripStartDate != null || trip.tripEndDate != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (trip.tripStartDate != null)
                        Expanded(
                          child: _buildTripDateInfo(
                            context,
                            Icons.play_circle_outline,
                            'Started',
                            dateFormat.format(trip.tripStartDate!),
                          ),
                        ),
                      if (trip.tripStartDate != null && trip.tripEndDate != null)
                        Container(
                          width: 1,
                          height: 32,
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                        ),
                      if (trip.tripEndDate != null)
                        Expanded(
                          child: _buildTripDateInfo(
                            context,
                            Icons.stop_circle_outlined,
                            'Ended',
                            dateFormat.format(trip.tripEndDate!),
                          ),
                        ),
                    ],
                  ),
                ],

                // Rate Driver Button - Only for completed trips with no rating yet
                if (trip.status.toLowerCase() == 'completed' && trip.feedbackRating == 0) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showRatingDialog(context, trip),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.star_rounded, size: 20),
                      label: const Text(
                        'Rate Driver',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],

                // Show rating if already rated
                if (trip.feedbackRating > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Your Rating: ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.amber.shade800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < trip.feedbackRating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 22,
                              color: index < trip.feedbackRating
                                  ? Colors.amber.shade600
                                  : Colors.amber.shade300,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${trip.feedbackRating}/5)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, CustomerTripHistoryModel trip) {
    int selectedRating = 0;
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        size: 48,
                        color: Colors.amber.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Rate Your Driver',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Driver name
                    Text(
                      trip.clientName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Vehicle info
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        trip.vehicleNo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Star Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedScale(
                              scale: selectedRating > index ? 1.2 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              child: Icon(
                                selectedRating > index
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 40,
                                color: selectedRating > index
                                    ? Colors.amber.shade500
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),

                    // Rating label
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _getRatingLabel(selectedRating),
                        key: ValueKey(selectedRating),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selectedRating > 0
                              ? Colors.amber.shade700
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Feedback text field
                    TextField(
                      controller: feedbackController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Share your experience (optional)',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.amber.shade400, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: selectedRating > 0
                                ? () {
                                    Navigator.pop(dialogContext);
                                    _submitRating(
                                      context,
                                      trip,
                                      selectedRating,
                                      feedbackController.text,
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade600,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade200,
                              disabledForegroundColor: Colors.grey.shade400,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Tap to rate';
    }
  }

  Future<void> _submitRating(
    BuildContext context,
    CustomerTripHistoryModel trip,
    int rating,
    String feedback,
  ) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get userId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      if (userId.isEmpty) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('User not found. Please login again.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }

      // Create repository and call API
      final apiClient = ApiClient();
      final savedService = SavedService();
      final customerRepository = CustomerRepository(apiClient, savedService);

      final response = await customerRepository.submitTripRating(
        tripId: trip.tripId,
        reviewById: userId,
        rating: rating,
        comment: feedback,
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      // Check for success - API returns data on success
      final isSuccess = response.data != null ||
          (response.message?.toLowerCase().contains('success') ?? false);

      if (isSuccess) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text('Thank you for rating ${trip.clientName}!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );

        // Refresh the trip history
        if (context.mounted) {
          context.read<CustomerTripHistoryBloc>().add(
                FetchCustomerTripHistory(userId: userId),
              );
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(response.message ?? 'Failed to submit rating')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Expanded(child: Text('An error occurred. Please try again.')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
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

  Widget _buildPaymentInfo(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
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

  Widget _buildTripDateInfo(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'inprogress':
      case 'in_progress':
      case 'ongoing':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'inprogress':
      case 'in_progress':
      case 'ongoing':
        return Icons.local_shipping;
      case 'cancelled':
        return Icons.cancel;
      case 'pending':
        return Icons.hourglass_empty;
      default:
        return Icons.help_outline;
    }
  }
}
