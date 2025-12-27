import 'package:flutter_bloc/flutter_bloc.dart';
import 'rating_event.dart';
import 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  RatingBloc() : super(RatingInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Update star rating
    on<UpdateRating>((event, emit) {
      // ============================================
      // BUSINESS LOGIC: Update Star Rating
      // ============================================

      // Validate rating range (0.0 to 5.0)
      final validatedRating = event.rating.clamp(0.0, 5.0);

      // Emit updated state with new rating
      emit(state.copyWith(
        rating: validatedRating,
        errorMessage: null,
      ));
    });

    // Update comment text
    on<UpdateComment>((event, emit) {
      // ============================================
      // BUSINESS LOGIC: Update Comment
      // ============================================

      // Emit updated state with new comment
      emit(state.copyWith(
        comment: event.comment,
        errorMessage: null,
      ));
    });

    // Submit rating and comment
    on<SubmitRating>((event, emit) async {
      // ============================================
      // BUSINESS LOGIC: Submit Rating and Comment
      // ============================================

      try {
        // Validation: Check if rating is greater than 0
        if (state.rating == 0.0) {
          emit(RatingError(
            errorMessage: 'Please select a rating',
            rating: state.rating,
            comment: state.comment,
          ));
          return;
        }

        // Optional validation: If comment is provided, check minimum length
        if (state.comment.trim().isNotEmpty && state.comment.trim().length < 10) {
          emit(RatingError(
            errorMessage: 'Comment must be at least 10 characters if provided',
            rating: state.rating,
            comment: state.comment,
          ));
          return;
        }

        // Show loading state
        emit(state.copyWith(
          isSubmitting: true,
          errorMessage: null,
        ));

        // Simulate API call delay
        await Future.delayed(const Duration(seconds: 2));

        // ============================================
        // TODO: Add your API call here
        // Example:
        // final response = await ratingRepository.submitRating(
        //   rating: state.rating,
        //   comment: state.comment,
        // );
        // ============================================

        // Emit success state
        emit(RatingSubmitted(
          successMessage: 'Thank you for your feedback!',
          rating: state.rating,
          comment: state.comment,
        ));
      } catch (e) {
        // Emit error state
        emit(RatingError(
          errorMessage: 'Failed to submit rating: ${e.toString()}',
          rating: state.rating,
          comment: state.comment,
        ));
      }
    });
  }
}
