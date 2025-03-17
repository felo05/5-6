part of 'add_user_cubit.dart';

@immutable
sealed class AddUserState {}

final class AddUserInitial extends AddUserState {}

final class AddUserSuccessState extends AddUserState {}

final class AddUserErrorState extends AddUserState {
  final String errorMessage;
  AddUserErrorState(this.errorMessage);
}

final class AddUserLoadingState extends AddUserState {}