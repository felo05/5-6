import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../staff_screen.dart';

part 'add_score_state.dart';

class AddScoreCubit extends Cubit<AddScoreState> {
  AddScoreCubit() : super(AddScoreInitial());

  void addScore(Set<User> selectedList, List<User> staffList, int score,
      String reason,String? l7n, String? date) async {
    emit(AddScoreLoadingState());

    try {
      final String entry =reason=="tsme3"?l7n!:"$date $reason";
      for (var user in selectedList) {
        user.score = (user.score ?? 0) + score;
        user.attended.add(entry);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uuid)
            .update({
          "score": user.score,
        });

        if(reason=="2das"){
          user.count2das=user.count2das!+1;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uuid)
              .update({
            "count2das": user.count2das,
          });
        }
        else if(reason=="khoras"){
         user.countKhoras=user.countKhoras!+1;
         await FirebaseFirestore.instance
             .collection('users')
             .doc(user.uuid)
             .update({
           "countKhoras": user.countKhoras,
         });
        }
        else if(reason=="3shea"){
          user.count3shea=user.count3shea!+1;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uuid)
              .update({
            "count3shea": user.count3shea,
          });
        }
        else if(reason=="tsb7a") {
          user.countTsb7a=user.countTsb7a!+1;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uuid)
              .update({
            "countTsb7a": user.countTsb7a,
          });
        }


        final index = staffList.indexWhere((e) => e.name == user.name);
        if (index != -1) {
          staffList[index] = user;
        }
      }

      if (reason != "Bonus" && date != null) {
        final reasonDoc = FirebaseFirestore.instance
            .collection("attendance")
            .doc("reason");

        DocumentSnapshot reasonSnapshot = await reasonDoc.get();
        Map<String, dynamic> reasonData =
            reasonSnapshot.data() as Map<String, dynamic>? ?? {};

        Set<String> arr = (reasonData["arr"] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toSet() ??
            {};



        if (!arr.contains(entry)) {
          StaffScreenState.tempHeaders.add(entry);
          await reasonDoc.update({
            "arr": FieldValue.arrayUnion([entry]),
          });
        }

        for (var user in selectedList) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uuid)
              .update({
            "attended": FieldValue.arrayUnion([entry]),
          });
        }
      }

      emit(AddScoreSuccessState());
    } catch (e) {
      emit(AddScoreErrorState(e.toString()));
    }
  }
}
