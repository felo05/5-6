import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:khoras_5_6/services/create_notification_service.dart';
import 'package:khoras_5_6/staff_screen.dart';
import 'add_user_screen.dart';
import 'models/user_model.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddUserScreen()),
                );
              },
              child: const Text('Add User'),
            ),
            ElevatedButton(
              onPressed: () {
                pickAndUploadExcelToFirestore();
              },
              child: const Text('Add Users from Excel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final titleController = TextEditingController();
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text("Push Notification"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FormBuilderTextField(
                          decoration: const InputDecoration(
                              labelText: "Notification title",
                              border: InputBorder.none,
                              floatingLabelBehavior: FloatingLabelBehavior.auto),
                          controller: titleController,
                          name: 'Notification title',
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FormBuilderTextField(
                            decoration: const InputDecoration(
                                labelText: "Notification body",
                                border: InputBorder.none,
                                floatingLabelBehavior: FloatingLabelBehavior.auto),
                          onSubmitted: (val) {
                            CreateNotificationService()
                                .showNotificationWithImage(
                                    0,
                                    titleController.text,
                                    val!,
                                    "payload",null);
                            Navigator.pop(context);
                          },
                          name: 'Notification body',
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: const Text('Push Notification'),
            ),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text("Add l7n"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FormBuilderTextField(
                          onSubmitted: (value) async {
                            StaffScreenState.al7an.add(value!);
                            await FirebaseFirestore.instance
                                .collection('al7an')
                                .doc("al7an")
                                .update({
                              "al7an": FieldValue.arrayUnion([value]),
                            }).whenComplete(() {
                              Navigator.pop(context);
                            });
                          },
                          decoration: const InputDecoration(labelText: "All7n",
                              border: InputBorder.none,
                              floatingLabelBehavior: FloatingLabelBehavior.auto),
                          name: 'al7an',
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: const Text('Add l7n'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickAndUploadExcelToFirestore() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    File file = File(result.files.single.path!);

    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    List<User> userData = [];

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table]!;

      for (var row in sheet.rows) {
        if (row.isEmpty ||
            row[0]?.value == null ||
            row[0]!.value.toString().trim().isEmpty) {
          break;
        }

        bool isRowEmpty = row.every((cell) =>
            cell?.value == null || cell!.value.toString().trim().isEmpty);
        if (isRowEmpty) {
          break;
        }

        User user = User();
        user.id = int.tryParse(row[0]!.value.toString());
        user.khadem = row[1]?.value.toString();
        user.name = row[2]?.value.toString();
        user.phone = row[3]?.value != null
            ? row[3]!.value.toString()[0] == '0'
                ? row[3]!.value.toString()
                : '0${row[3]!.value}'
            : null;
        user.momPhone = row[4]?.value != null
            ? row[4]!.value.toString()[0] == '0'
                ? row[4]!.value.toString()
                : '0${row[4]!.value}'
            : null;
        user.dadPhone = row[5]?.value != null
            ? row[5]!.value.toString()[0] == '0'
                ? row[5]!.value.toString()
                : '0${row[5]!.value}'
            : null;
        user.address = row[6]?.value.toString();
        if (row[7]?.value != null) {
          if (row[7]?.value is DateCellValue) {
            DateCellValue dateCell = row[7]!.value as DateCellValue;
            user.dateBirth =
                DateTime(dateCell.year, dateCell.month, dateCell.day);
          } else if (row[7]?.value is DateTime) {
            user.dateBirth = row[7]?.value as DateTime?;
          } else {
            user.dateBirth = null; // Handle other cases if needed
          }
        } else {
          user.dateBirth = null;
        }
        user.level = row[8]?.value.toString() == null
            ? null
            : int.tryParse(row[8]!.value.toString());
        user.gender = row[9]?.value.toString();
        user.isShamas = row[10]?.value.toString() == "TRUE" ? true : false;
        user.score = 0;

        if (user.name != null) {
          userData.add(user);
        }
      }
    }

    for (var user in userData) {
      print(user);
      await FirebaseFirestore.instance.collection('users').add(user.toJson());
    }
  }
}
