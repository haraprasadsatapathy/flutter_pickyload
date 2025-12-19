import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picky_load3/presentation/cubit/user_profile/profile/profile_bloc.dart';
import 'package:picky_load3/presentation/cubit/user_profile/profile/profile_event.dart';
import 'package:picky_load3/presentation/cubit/user_profile/profile/profile_state.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../domain/repository/user_repository.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

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
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                authProvider.logout();
                context.go('/login');
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.currentUser?.id;

    return BlocProvider(
      create: (context) {
        final bloc = ProfileBloc(context, context.read<UserRepository>());
        // Fetch profile data on initialization
        if (userId != null) {
          bloc.add(FetchProfile(userId: userId));
        }
        return bloc;
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Image
                  _buildProfileImage(context, state, authProvider),
                  const SizedBox(height: 16),
                  // Profile Info
                  _buildProfileInfo(context, state, authProvider),
                  const SizedBox(height: 30),
                  // Profile Options
                  _buildProfileOption(
                    context,
                    Icons.person_outlined,
                    'Edit Profile',
                    () => context.push('/user-profile'),
                  ),
                  _buildProfileOption(
                    context,
                    Icons.directions_car_outlined,
                    'Vehicle Details',
                    () => context.push('/show-vehicles'),
                  ),
                  _buildProfileOption(
                    context,
                    Icons.description_outlined,
                    'Upload Documents',
                    () => context.push('/document-upload'),
                  ),
                  _buildProfileOption(
                    context,
                    Icons.folder_outlined,
                    'Show Documents',
                    () => context.push('/show-documents'),
                  ),
                  _buildProfileOption(
                    context,
                    Icons.add_box_outlined,
                    'Add Vehicle',
                    () => context.push('/add-vehicle'),
                  ),

                  const SizedBox(height: 20),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
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

  Widget _buildProfileImage(
    BuildContext context,
    ProfileState state,
    AuthProvider authProvider,
  ) {
    if (state is ProfileLoading) {
      return const CircleAvatar(radius: 50, child: CircularProgressIndicator());
    }

    if (state is ProfileFetchSuccess &&
        state.profileData.uProfileImageUrl != null) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(state.profileData.uProfileImageUrl!),
      );
    }

    // Default avatar with first letter
    final name = state is ProfileFetchSuccess
        ? state.profileData.userName
        : authProvider.currentUser?.name ?? 'User';

    return CircleAvatar(
      radius: 50,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(fontSize: 36, color: Colors.white),
      ),
    );
  }

  Widget _buildProfileInfo(
    BuildContext context,
    ProfileState state,
    AuthProvider authProvider,
  ) {
    if (state is ProfileLoading) {
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 8),
          Text('Loading profile...'),
        ],
      );
    }

    if (state is ProfileFetchError) {
      return Column(
        children: [
          Text(
            state.message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final userId = authProvider.currentUser?.id;
              if (userId != null) {
                context.read<ProfileBloc>().add(FetchProfile(userId: userId));
              }
            },
            child: const Text('Retry'),
          ),
        ],
      );
    }

    // Display profile data
    final name = state is ProfileFetchSuccess
        ? state.profileData.userName
        : authProvider.currentUser?.name ?? 'User';

    final email = state is ProfileFetchSuccess
        ? state.profileData.userEmail
        : authProvider.currentUser?.email ?? '';

    final phone = state is ProfileFetchSuccess
        ? state.profileData.userPhone
        : authProvider.currentUser?.phone ?? '';

    return Column(
      children: [
        Text(
          name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          email,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        if (phone.isNotEmpty)
          Text(
            phone,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
      ],
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
