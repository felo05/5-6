import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:khoras_5_6/staff_screen.dart';
import '../models/user_model.dart';

part 'get_staff_state.dart';

class GetStaffCubit extends Cubit<GetStaffState> {
  GetStaffCubit() : super(GetStaffInitial());
  void emitSuccess(){
    emit(GetStaffSuccessState(StaffScreenState.tempList));
  }
  void getRoomData() async {
    emit(GetStaffLoadingState());
    try {
      QuerySnapshot querySnapshot;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
        querySnapshot = await firestore.collection('users').get();


      List<User> users = querySnapshot.docs.map((doc) {
        return User.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      emit(GetStaffSuccessState(
        users,
      ));
    } catch (e) {
      print(e);
      emit(GetStaffErrorState(e.toString()));
    }
  }
}
