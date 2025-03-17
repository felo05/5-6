part of 'get_staff_cubit.dart';

@immutable
sealed class GetStaffState {}

final class GetStaffInitial extends GetStaffState {}

final class GetStaffLoadingState extends GetStaffState {}

final class GetStaffErrorState extends GetStaffState {
  final String error;

  GetStaffErrorState(this.error);
}

final class GetStaffSuccessState extends GetStaffState {
  final List<User> staffList;


  GetStaffSuccessState(this.staffList);
}
