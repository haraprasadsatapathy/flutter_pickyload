import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/repository/driver_repository.dart';
import '../../../domain/repository/user_repository.dart';
import '../../cubit/auth/role_selection/role_selection_bloc.dart';
import '../../cubit/auth/role_selection/role_selection_event.dart';
import '../../cubit/auth/role_selection/role_selection_state.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverRepository = Provider.of<DriverRepository>(context, listen: false);
    final userRepository = Provider.of<UserRepository>(context, listen: false);

    return BlocProvider(
      create: (context) => RoleSelectionBloc(
        context: context,
        driverRepository: driverRepository,
        userRepository: userRepository,
      ),
      child: BlocConsumer<RoleSelectionBloc, RoleSelectionState>(
        listener: (context, state) {
          if (state is CustomerRoleSelected) {
            developer.log('Customer role selected, navigating to dashboard...');
            context.go('/customer-dashboard');
          } else if (state is DriverRoleSelectedWithDocuments) {
            developer.log('Driver role selected with ${state.documentCount} documents, navigating to driver dashboard...');
            context.go('/driver-dashboard');
          } else if (state is DriverRoleSelectedWithoutDocuments) {
            developer.log('Driver role selected without documents, navigating to document upload...');
            context.go('/document-upload');
          } else if (state is RoleSelectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is RoleSelectionLoading;

          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Choose Your Role',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Select how you want to use Picky Load',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 60),
                    _RoleCard(
                      title: 'Customer',
                      description: 'I need to transport goods',
                      icon: Icons.local_shipping_outlined,
                      isLoading: isLoading,
                      onTap: () {
                        context.read<RoleSelectionBloc>().add(SelectCustomerRole());
                      },
                    ),
                    const SizedBox(height: 20),
                    _RoleCard(
                      title: 'Driver',
                      description: 'I want to offer load carrying services',
                      icon: Icons.person_pin_outlined,
                      isLoading: isLoading,
                      onTap: () {
                        context.read<RoleSelectionBloc>().add(SelectDriverRole());
                      },
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Opacity(
          opacity: isLoading ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
