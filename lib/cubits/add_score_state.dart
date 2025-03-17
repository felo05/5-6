part of 'add_score_cubit.dart';

@immutable
sealed class AddScoreState {}

final class AddScoreInitial extends AddScoreState {}

final class AddScoreErrorState extends AddScoreState {
  final String error;

  AddScoreErrorState(this.error);
}

final class AddScoreSuccessState extends AddScoreState {}

final class AddScoreLoadingState extends AddScoreState {}
