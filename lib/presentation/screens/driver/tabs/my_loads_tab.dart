import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/data_source/api_client.dart';
import '../../../../domain/repository/driver_repository.dart';
import '../../../../services/local/saved_service.dart';
import '../../../cubit/driver/my_loads/my_loads_bloc.dart';
import '../../../cubit/driver/my_loads/my_loads_event.dart';
import '../../../cubit/driver/my_loads/my_loads_state.dart';

class MyLoadsTab extends StatelessWidget {
  const MyLoadsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final apiClient = ApiClient();
        final savedService = SavedService();
        final driverRepository = DriverRepository(apiClient, savedService);
        final bloc = MyLoadsBloc(context, driverRepository);

        // Fetch user details and load data
        _loadMyLoads(bloc, savedService);

        return bloc;
      },
      child: const MyLoadsTabView(),
    );
  }

  Future<void> _loadMyLoads(MyLoadsBloc bloc, SavedService savedService) async {
    final user = await savedService.getUserDetailsSp();
    if (user != null && user.id.isNotEmpty) {
      bloc.add(FetchMyLoads(driverId: user.id));
    }
  }
}

class MyLoadsTabView extends StatelessWidget {
  const MyLoadsTabView({super.key});

  @override
  Widget build(BuildContext context) {
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
            title: const Text('My Loads'),
            actions: [
              BlocBuilder<MyLoadsBloc, MyLoadsState>(
                builder: (context, state) {
                  return IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      final bloc = context.read<MyLoadsBloc>();
                      final savedService = SavedService();
                      final user = await savedService.getUserDetailsSp();
                      if (user != null && user.id.isNotEmpty) {
                        bloc.add(RefreshMyLoads(driverId: user.id));
                      }
                    },
                  );
                },
              ),
            ],
          ),
          BlocBuilder<MyLoadsBloc, MyLoadsState>(
            builder: (context, state) {
              if (state is MyLoadsLoading && state.loads.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is MyLoadsError && state.loads.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          state.error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            final bloc = context.read<MyLoadsBloc>();
                            final savedService = SavedService();
                            final user = await savedService.getUserDetailsSp();
                            if (user != null && user.id.isNotEmpty) {
                              bloc.add(FetchMyLoads(driverId: user.id));
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state.loads.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No loads available',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final load = state.loads[index];
                      return _buildLoadCard(
                        context,
                        load.status,
                        load.pickupAddress,
                        load.dropAddress,
                        load.formattedPrice,
                        _getStatusColor(load.status),
                      );
                    },
                    childCount: state.loads.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'driveroffered':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLoadCard(
    BuildContext context,
    String status,
    String pickupAddress,
    String dropAddress,
    String price,
    Color statusColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
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
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  price,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green.shade700, width: 2),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.grey.shade400,
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.shade700, width: 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Pickup: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              pickupAddress,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Text(
                            'Drop: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              dropAddress,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
