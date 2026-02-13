import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../cubit/user_profile/edit_profile/edit_profile_bloc.dart';
import '../../../cubit/user_profile/edit_profile/edit_profile_event.dart';
import '../../../cubit/user_profile/edit_profile/edit_profile_state.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load profile when screen is initialized
    context.read<EditProfileBloc>().add(const LoadProfileEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateControllersFromState(EditProfileLoaded state) {
    _nameController.text = state.name;
    _emailController.text = state.email;
    _phoneController.text = state.phone;
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  context.read<EditProfileBloc>().add(
                        const PickImageEvent(ImageSource.camera),
                      );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  context.read<EditProfileBloc>().add(
                        const PickImageEvent(ImageSource.gallery),
                      );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocBuilder<EditProfileBloc, EditProfileState>(
            builder: (context, state) {
              if (state is EditProfileLoaded && !state.isEditing) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context
                        .read<EditProfileBloc>()
                        .add(const ToggleEditModeEvent(true));
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<EditProfileBloc, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileLoaded) {
            _updateControllersFromState(state);
          } else if (state is EditProfileSaved) {
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            // Pop back to profile screen after successful update
            context.pop();
          } else if (state is EditProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.grey.shade600,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EditProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final isEditing = state is EditProfileLoaded && state.isEditing;
          final isSaving = state is EditProfileSaving;
          String? profileImagePath;
          String? profileImageUrl;

          if (state is EditProfileLoaded) {
            profileImagePath = state.profileImagePath;
            profileImageUrl = state.profileImageUrl;
          }

          // Build profile image with fallback to first letter
          Widget buildProfileImage() {
            // If user picked a new local image, use FileImage
            if (profileImagePath != null && profileImagePath.isNotEmpty) {
              return CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: FileImage(File(profileImagePath)),
              );
            }

            // If network image URL exists, use NetworkImage with error handling
            if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
              return CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: ClipOval(
                  child: Image.network(
                    profileImageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Show first letter if network image fails
                      return Container(
                        width: 120,
                        height: 120,
                        color: Theme.of(context).colorScheme.primary,
                        child: Center(
                          child: Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 48,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 120,
                        height: 120,
                        color: Theme.of(context).colorScheme.primary,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }

            // Fallback: Show first letter of name
            return CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user?.name.isNotEmpty == true
                    ? user!.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        buildProfileImage(),
                        if (isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt,
                                    color: Colors.white),
                                onPressed: () {
                                  _showImageSourceDialog(context);
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _nameController,
                      enabled: isEditing && !isSaving,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      enabled: isEditing && !isSaving,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      enabled: isEditing && !isSaving,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    if (isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () {
                                      context
                                          .read<EditProfileBloc>()
                                          .add(const CancelEditEvent());
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black87,
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        context
                                            .read<EditProfileBloc>()
                                            .add(SaveProfileEvent(
                                              name: _nameController.text,
                                              email: _emailController.text,
                                              phone: _phoneController.text,
                                            ));
                                      }
                                    },
                              child: isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
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
