import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../cubit/user_profile/edit_profile/edit_profile_bloc.dart';
import '../../cubit/user_profile/edit_profile/edit_profile_event.dart';
import '../../cubit/user_profile/edit_profile/edit_profile_state.dart';
import '../../cubit/auth/rating/rating_bloc.dart';
import '../../cubit/auth/rating/rating_event.dart';
import '../../cubit/auth/rating/rating_state.dart';

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

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider(
          create: (context) => RatingBloc(),
          child: BlocConsumer<RatingBloc, RatingState>(
            listener: (context, state) {
              if (state is RatingSubmitted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(state.successMessage),
                    backgroundColor: Colors.green,
                  ),
                );
                Future.delayed(const Duration(seconds: 1), () {
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                });
              } else if (state is RatingError) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? 'An error occurred'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return AlertDialog(
                title: const Text('Rate Your Experience'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How was your experience?',
                        style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your feedback helps us improve',
                        style: Theme.of(dialogContext).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starValue = index + 1.0;
                            final isFullStar = state.rating >= starValue;
                            final isHalfStar = state.rating >= starValue - 0.5 && state.rating < starValue;

                            return GestureDetector(
                              onTap: () {
                                context.read<RatingBloc>().add(UpdateRating(starValue));
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  isFullStar
                                      ? Icons.star
                                      : isHalfStar
                                          ? Icons.star_half
                                          : Icons.star_border,
                                  size: 40,
                                  color: isFullStar || isHalfStar
                                      ? Colors.amber
                                      : Colors.grey.shade400,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (state.rating > 0)
                        Center(
                          child: Text(
                            _getRatingText(state.rating),
                            style: Theme.of(dialogContext).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(dialogContext).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        'Comment (Optional)',
                        style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        maxLines: 3,
                        onChanged: (value) {
                          context.read<RatingBloc>().add(UpdateComment(value));
                        },
                        decoration: InputDecoration(
                          hintText: 'Share your experience...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
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
                    onPressed: state.isSubmitting
                        ? null
                        : () {
                            context.read<RatingBloc>().add(SubmitRating());
                          },
                    child: state.isSubmitting
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Submit'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _getRatingText(double rating) {
    if (rating <= 1) return 'Poor';
    if (rating <= 2) return 'Below Average';
    if (rating <= 3) return 'Average';
    if (rating <= 4) return 'Good';
    return 'Excellent';
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is EditProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
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
                    if (!isEditing) ...[
                      const SizedBox(height: 20),
                      Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () => _showRatingDialog(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rate Your Experience',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Share your feedback with us',
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
                      ),
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
