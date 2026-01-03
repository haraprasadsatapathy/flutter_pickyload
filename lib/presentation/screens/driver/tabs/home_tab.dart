import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../cubit/driver/home/home_tab_bloc.dart';
import '../../../cubit/driver/home/home_tab_event.dart';
import '../../../cubit/driver/home/home_tab_state.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data when the tab loads
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final driverId = authProvider.currentUser?.id ?? '';

    context.read<HomeTabBloc>().add(FetchTodayStats(driverId: driverId));
    context.read<HomeTabBloc>().add(FetchLoadRequests(driverId: driverId));
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
        // Show snackbar for success or error messages
        if (state is OnlineStatusUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is LoadRequestAccepted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is LoadRequestDeclined) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is QuoteSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is HomeTabError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<HomeTabBloc, HomeTabState>(
        builder: (context, state) {
          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                final driverId = authProvider.currentUser?.id ?? '';
                context.read<HomeTabBloc>().add(RefreshHomeTab(driverId: driverId));
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
                          authProvider.currentUser?.name ?? 'Driver',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 20),
                        _buildAddLoadButton(context),
                        const SizedBox(height: 20),
                        Text(
                          'Available Load Requests',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (state is HomeTabLoading && state.loadRequests.isEmpty)
                          const Center(child: CircularProgressIndicator())
                        else if (state.loadRequests.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('No load requests available'),
                            ),
                          )
                        else
                          ...state.loadRequests.map((loadRequest) =>
                              _buildLoadRequestCard(context, loadRequest)),
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




  Widget _buildLoadRequestCard(
    BuildContext context,
    LoadRequestModel loadRequest,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route header with price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    loadRequest.route,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '₹${loadRequest.price.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Origin
            _buildInfoRow(
              context: context,
              icon: Icons.trip_origin,
              label: 'Origin',
              value: loadRequest.fromLocation,
            ),
            const SizedBox(height: 8),

            // Destination
            _buildInfoRow(
              context: context,
              icon: Icons.flag,
              label: 'Destination',
              value: loadRequest.toLocation,
            ),
            const SizedBox(height: 8),

            // Capacity
            _buildInfoRow(
              context: context,
              icon: Icons.inventory_2,
              label: 'Capacity',
              value: loadRequest.capacity,
            ),
            const SizedBox(height: 8),

            // Available From
            if (loadRequest.startDate != null)
              _buildInfoRow(
                context: context,
                icon: Icons.calendar_today,
                label: 'Available From',
                value: loadRequest.formattedStartTime,
              ),
            if (loadRequest.startDate != null) const SizedBox(height: 8),

            // Available Until
            if (loadRequest.endDate != null)
              _buildInfoRow(
                context: context,
                icon: Icons.calendar_today,
                label: 'Available Until',
                value: loadRequest.formattedEndTime,
              ),
            if (loadRequest.endDate != null) const SizedBox(height: 16),
            if (loadRequest.startDate == null && loadRequest.endDate == null)
              const SizedBox(height: 8),

            // Quote button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showQuoteDialog(context, loadRequest);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Quote'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuoteDialog(BuildContext context, LoadRequestModel loadRequest) {
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Submit Quote'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Route: ${loadRequest.route}',
                  style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estimated Price: ₹${loadRequest.price.toStringAsFixed(0)}',
                  style: Theme.of(dialogContext).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Your Quote Price',
                    hintText: 'Enter quote price',
                    prefixIcon: const Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    final price = double.tryParse(value);
                    if (price == null) {
                      return 'Please enter a valid number';
                    }
                    if (price <= 0) {
                      return 'Price must be greater than 0';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final driverId = authProvider.currentUser?.id ?? '';
                  final quotePrice = double.parse(priceController.text);

                  context.read<HomeTabBloc>().add(
                        SubmitQuote(
                          loadRequestId: loadRequest.loadRequestId,
                          driverId: driverId,
                          quotePrice: quotePrice,
                        ),
                      );

                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Submit Quote'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
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

  Widget _buildAddLoadButton(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push('/add-load');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_box,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 4),
                    Text(
                      'Post your available vehicle for load requests',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
