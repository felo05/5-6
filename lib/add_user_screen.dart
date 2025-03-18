import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:khoras_5_6/Cubits/add_user_cubit.dart';

import 'models/user_model.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  AddUserScreenState createState() => AddUserScreenState();
}

class AddUserScreenState extends State<AddUserScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController momPhoneController = TextEditingController();
  final TextEditingController dadPhoneController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  XFile? image;
  final List<String> classRooms = ["5", "6"];
  final List<String> genders = ["بنت", "ولد"];
  final List<String> khadem = [
    "يوسف جرجس",
    "بولا برت",
    "جورج مينا",
    "اباكير سامي",
    "مريم فوزي",
    "ديانا ماجد",
    "ماريا الفونس",
    "فيلوباتير إيهاب",
    "كارين ماجد",
    "يوسف عصام",
    "بيتر القمص بيمن",
    "بيشوي جوزيف"
  ];
  String selectedKhadem = '';
  String selectedGender = '';
  String selectedClass = '';
  bool isShamas = false;
  DateTime dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    image = await picker.pickImage(source: ImageSource.gallery);
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 100,
                          child: image == null
                              ? const Icon(Icons.person, size: 100)
                              : ClipOval(
                                  child: Image.file(
                                    File(image!.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        const Positioned(
                          right: 0,
                          bottom: 0,
                          child: Icon(
                            Icons.edit,
                            size: 36,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                FormBuilderTextField(
                  controller: nameController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  keyboardType: TextInputType.name,
                  name: 'name',
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    setState(() {});
                  },
                  name: 'phone',
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  controller: momPhoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    setState(() {});
                  },
                  name: 'momPhone',
                  decoration: const InputDecoration(labelText: 'Mom Phone'),
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  controller: dadPhoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    setState(() {});
                  },
                  name: 'dadPhone',
                  decoration: const InputDecoration(labelText: 'Dad Phone'),
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  controller: addressController,
                  keyboardType: TextInputType.streetAddress,
                  onChanged: (value) {
                    setState(() {});
                  },
                  name: 'address',
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 20),
                FormBuilderDropdown(
                  name: 'class',
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: classRooms
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedClass = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 20),
                FormBuilderDropdown(
                  name: 'khadem',
                  decoration: const InputDecoration(labelText: 'Khadem'),
                  items: khadem
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedKhadem = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 20),
                FormBuilderDateTimePicker(
                  name: 'Date birth',
                  currentDate: dateTime,
                  format: DateFormat('yyyy-MM-dd'),
                  decoration: const InputDecoration(labelText: 'Date birth'),
                  onChanged: (value) {
                    dateTime = value ?? DateTime.now();
                  },
                ),
                const SizedBox(height: 20),
                FormBuilderDropdown(
                  name: 'gender',
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: genders
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  controller: noteController,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    setState(() {});
                  },
                  name: 'notes',
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: 20),
                selectedGender == "ولد"
                    ? Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Is shamas?",
                              style: TextStyle(fontSize: 20),
                            ),
                            Checkbox(
                                value: isShamas,
                                onChanged: (val) {
                                  setState(() {
                                    isShamas = val!;
                                  });
                                }),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 25),
                BlocProvider(
                  create: (context) => AddUserCubit(),
                  child: BlocConsumer<AddUserCubit, AddUserState>(
                    listener: (context, state) {
                      if (state is AddUserErrorState) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(state.errorMessage),
                        ));
                      }
                      if (state is AddUserSuccessState) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('User Added Successfully'),
                        ));
                        selectedClass = '';
                        nameController.clear();
                      }
                    },
                    builder: (context, state) {
                      if (state is AddUserLoadingState) {
                        return const CircularProgressIndicator();
                      }
                      return ElevatedButton(
                        onPressed: validate()
                            ? () async {
                                context.read<AddUserCubit>().addUser(
                                    user: User(
                                        score: 0,
                                        name: nameController.text,
                                        momPhone: momPhoneController.text,
                                        dadPhone: dadPhoneController.text,
                                        phone: phoneController.text,
                                        address: addressController.text,
                                        notes: noteController.text,
                                        isShamas: isShamas,
                                        dateBirth: dateTime,
                                        id: User.maxId + 1,
                                        level: selectedClass == ''
                                            ? null
                                            : int.parse(selectedClass),
                                        khadem: selectedKhadem == ''
                                            ? null
                                            : selectedKhadem,
                                        gender: selectedGender == ''
                                            ? null
                                            : selectedGender),
                                    image: image == null
                                        ? null
                                        : File(image!.path),
                                    context: context);
                                User.maxId = User.maxId + 1;
                              }
                            : null,
                        child: const Text('Add User'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool validate() => nameController.text.isNotEmpty;
}
