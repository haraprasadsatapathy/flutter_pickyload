import 'package:picky_load/presentation/cubit/base/base_event_state.dart';

// Base state class for Rating feature
class RatingState extends BaseEventState {
  final double rating;
  final String comment;
  final bool isSubmitting;
  final String? errorMessage;

  RatingState({
    this.rating = 0.0,
    this.comment = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [rating, comment, isSubmitting, errorMessage];

  // CopyWith method for state updates
  RatingState copyWith({
    double? rating,
    String? comment,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return RatingState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Initial state
class RatingInitial extends RatingState {
  RatingInitial() : super();
}

// Rating submitted successfully
class RatingSubmitted extends RatingState {
  final String successMessage;

  RatingSubmitted({
    required this.successMessage,
    required super.rating,
    required super.comment,
  }) : super(isSubmitting: false);

  @override
  List<Object?> get props => [successMessage, rating, comment, isSubmitting];
}

// Rating submission error
class RatingError extends RatingState {
  RatingError({
    required super.errorMessage,
    required super.rating,
    required super.comment,
  }) : super(isSubmitting: false);

  @override
  List<Object?> get props => [errorMessage, rating, comment, isSubmitting];
}