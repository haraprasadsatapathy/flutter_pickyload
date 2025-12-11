import 'package:equatable/equatable.dart';

abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object?> get props => [];
}

class ToggleEditModeEvent extends EditProfileEvent {
  final bool isEditing;

  const ToggleEditModeEvent(this.isEditing);

  @override
  List<Object?> get props => [isEditing];
}

class PickImageEvent extends EditProfileEvent {
  const PickImageEvent();
}

class SaveProfileEvent extends EditProfileEvent {
  final String name;
  final String email;
  final String phone;
  final String? vehicleType;
  final String? vehicleNumber;

  const SaveProfileEvent({
    required this.name,
    required this.email,
    required this.phone,
    this.vehicleType,
    this.vehicleNumber,
  });

  @override
  List<Object?> get props => [name, email, phone, vehicleType, vehicleNumber];
}

class CancelEditEvent extends EditProfileEvent {
  const CancelEditEvent();
}

class LoadProfileEvent extends EditProfileEvent {
  const LoadProfileEvent();
}
