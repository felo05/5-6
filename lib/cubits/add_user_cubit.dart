import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khoras_5_6/Cubits/get_staff_cubit.dart';
import 'package:khoras_5_6/staff_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../models/user_model.dart';

part 'add_user_state.dart';

class AddUserCubit extends Cubit<AddUserState> {
  AddUserCubit() : super(AddUserInitial());

  void addUser(
      {required User user, File? image, required BuildContext context}) async {
    emit(AddUserLoadingState());
    try {
      if (image != null) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage
            .from('images')
            .upload(fileName, image);
        user.image = Supabase.instance.client.storage
            .from('images')
            .getPublicUrl(fileName);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .add(user.toJson())
          .then((onValue) {
        emit(AddUserSuccessState());
        StaffScreenState.tempList.add(user);
        context.read<GetStaffCubit>().emitSuccess();
      }).catchError((onError) {
        emit(AddUserErrorState(onError.toString()));
      });
    } catch (e) {
      emit(AddUserErrorState(e.toString()));
    }
  }
}
