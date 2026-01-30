import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../cubit/driver/offer_loads_list/offer_loads_list_bloc.dart';
import '../../cubit/driver/offer_loads_list/offer_loads_list_event.dart';
import '../../cubit/driver/offer_loads_list/offer_loads_list_state.dart';

class OfferLoadsListScreen extends StatefulWidget {
  const OfferLoadsListScreen({super.key});

  @override
  State<OfferLoadsListScreen> createState() => _OfferLoadsListScreenState();
}

class _OfferLoadsListScreenState extends State<OfferLoadsListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch offered loads when screen loads
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final driverId = authProvider.currentUser?.id ?? '';
    context.read<OfferLoadsListBloc>().add(FetchOfferLoads(driverId: driverId));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final driverId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Offered Loads'),
      ),
      body: BlocListener<OfferLoadsListBloc, OfferLoadsListState>(
        listener: (context, state) {
          if (state is OfferLoadsListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<OfferLoadsListBloc, OfferLoadsListState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<OfferLoadsListBloc>()
                    .add(RefreshOfferLoads(driverId: driverId));
              },
              child: _buildBody(state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(OfferLoadsListState state) {
    if (state is OfferLoadsListLoading && state.offerLoads.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.offerLoads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Offered Loads',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t offered any loads yet.',
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
      itemCount: state.offerLoads.length,
      itemBuilder: (context, index) {
        final offerLoad = state.offerLoads[index];
        return _buildOfferLoadCard(offerLoad);
      },
    );
  }

  Widget _buildOfferLoadCard(OfferLoadModel offerLoad) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.location_on,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              offerLoad.origin,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              offerLoad.destination,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(offerLoad.status),
              ],
            ),
            const SizedBox(height: 16),

            // Origin
            _buildInfoRow(
              icon: Icons.trip_origin,
              label: 'Origin',
              value: offerLoad.origin,
            ),
            const SizedBox(height: 8),

            // Destination
            _buildInfoRow(
              icon: Icons.flag,
              label: 'Destination',
              value: offerLoad.destination,
            ),
            const SizedBox(height: 8),

            // Available Time Start
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Available From',
              value: offerLoad.formattedStartTime,
            ),
            const SizedBox(height: 8),

            // Available Time End
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Available Until',
              value: offerLoad.formattedEndTime,
            )
          ],
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
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'driveroffered':
        chipColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        break;
      case 'pending':
        chipColor = Colors.amber.shade100;
        textColor = Colors.amber.shade900;
        break;
      case 'accepted':
        chipColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        break;
      case 'rejected':
        chipColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        break;
      default:
        chipColor = Colors.grey.shade100;
        textColor = Colors.grey.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
