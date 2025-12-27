import 'package:picky_load3/presentation/cubit/base/base_event_state.dart';

// Base event class for Rating feature
class RatingEvent extends BaseEventState {}

// Update star rating
class UpdateRating extends RatingEvent {
  final double rating;

  UpdateRating(this.rating);

  @override
  List<Object?> get props => [rating];
}

// Update comment text
class UpdateComment extends RatingEvent {
  final String comment;

  UpdateComment(this.comment);

  @override
  List<Object?> get props => [comment];
}

// Submit rating and comment
class SubmitRating extends RatingEvent {
  SubmitRating();

  @override
  List<Object?> get props => [];
}