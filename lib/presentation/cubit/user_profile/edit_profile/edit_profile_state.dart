import 'package:equatable/equatable.dart';

abstract class EditProfileState extends Equatable {
  final bool isEditing;

  const EditProfileState({this.isEditing = false});

  @override
  List<Object?> get props => [isEditing];
}

class EditProfileInitial extends EditProfileState {
  const EditProfileInitial() : super(isEditing: false);
}

class EditProfileLoading extends EditProfileState {
  const EditProfileLoading({super.isEditing});
}

class EditProfileLoaded extends EditProfileState {
  final String name;
  final String email;
  final String phone;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? profileImagePath;

  const EditProfileLoaded({
    required this.name,
    required this.email,
    required this.phone,
    this.vehicleType,
    this.vehicleNumber,
    this.profileImagePath,
    super.isEditing,
  });

  EditProfileLoaded copyWith({
    String? name,
    String? email,
    String? phone,
    String? vehicleType,
    String? vehicleNumber,
    String? profileImagePath,
    bool? isEditing,
  }) {
    return EditProfileLoaded(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        vehicleType,
        vehicleNumber,
        profileImagePath,
        isEditing,
      ];
}

class EditProfileEditing extends EditProfileState {
  const EditProfileEditing() : super(isEditing: true);
}

class EditProfileSaving extends EditProfileState {
  const EditProfileSaving() : super(isEditing: true);
}

class EditProfileSaved extends EditProfileState {
  final String message;

  const EditProfileSaved(this.message) : super(isEditing: false);

  @override
  List<Object?> get props => [message, isEditing];
}

class EditProfileImagePicked extends EditProfileState {
  final String imagePath;

  const EditProfileImagePicked(this.imagePath, {super.isEditing});

  @override
  List<Object?> get props => [imagePath, isEditing];
}

class EditProfileError extends EditProfileState {
  final String message;

  const EditProfileError(this.message, {super.isEditing});

  @override
  List<Object?> get props => [message, isEditing];
}
