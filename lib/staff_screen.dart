import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:khoras_5_6/qr_scanner.dart';
import 'package:khoras_5_6/widgets/custom_network_image.dart';
import 'package:khoras_5_6/widgets/p_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'Cubits/add_score_cubit.dart';
import 'Cubits/get_staff_cubit.dart';
import 'add_screen.dart';
import 'constants.dart';
import 'models/user_model.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  StaffScreenState createState() => StaffScreenState();
}

class StaffScreenState extends State<StaffScreen> {
  Timer? _debounceTimer;
  List<Map<String, String>> radioButtons = [
    {"title": "All", "value": "all"},
    {"title": "Khoras", "value": "khoras"},
    {"title": "2das", "value": "2das"},
    {"title": "3shea", "value": "3shea"},
    {"title": "Tsb7a", "value": "tsb7a"},
    {"title": "Tsme3", "value": "tsme3"},
  ];
  String selectedValue = "all";
  List<User> staffList = [];
  static List<User> tempList = [];
  Set<User> selectedList = {};
  String searchKeyword = '';
  int score = 1;
  static List<dynamic> tempHeaders = [];
  List<dynamic> headers = [];
  bool sortByScore = true, isAttendance = false;
  static List<dynamic> al7an = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    context.read<GetStaffCubit>().getRoomData();
    final dates = await FirebaseFirestore.instance
        .collection("attendance")
        .doc("reason")
        .get();
    headers = (dates.data() as Map<String, dynamic>)["arr"];
    tempHeaders = headers;
    al7an = (await FirebaseFirestore.instance
        .collection("al7an")
        .doc("al7an")
        .get())
        .data()?["al7an"];
    print(al7an);
  }

  void _updateSearch(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      setState(() => staffList = tempList
          .where((e) => e.name!.toLowerCase().contains(value.toLowerCase()))
          .toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildFab(context),
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
              child: isAttendance ? _buildAttendanceView() : _buildStaffView()),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) => FloatingActionButton(
    heroTag: selectedList.isEmpty ? 'scan' : 'add',
    onPressed: () => selectedList.isEmpty
        ? Navigator.push(
        context, MaterialPageRoute(builder: (_) => const QRScanner()))
        : _showScoreSheet(context),
    backgroundColor: Theme.of(context).colorScheme.primary,
    child: Icon(selectedList.isEmpty ? Icons.qr_code_scanner : Icons.add,
        color: Colors.white, size: 30),
  );

  AppBar _buildAppBar(BuildContext context) => AppBar(
    title: const PText(title: "Khoras 5&6", size: PSize.veryLarge),
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    actions: [
      PopupMenuButton<int>(
        onSelected: (value) => setState(() {
          if (value == 0) isAttendance = !isAttendance;
          if (value == 1) _sortStaff();
          if (value == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddScreen()));
          }
          if (value == 4) _exportToExcel();
        }),
        itemBuilder: (_) => [
          _menuItem(0, 'Toggle ${isAttendance ? 'Score' : 'Attendance'}',
              Icons.insert_chart_outlined),
          _menuItem(4, 'Export', Icons.save_alt),
          _menuItem(1, 'Sort', Icons.sort),
          _menuItem(2, 'Add User', Icons.add),
        ],
      ),
    ],
  );

  PopupMenuItem<int> _menuItem(int value, String text, IconData icon) =>
      PopupMenuItem(
        value: value,
        child: Row(children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 8),
          Text(text)
        ]),
      );

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        Expanded(
            flex: 10,
            child: CupertinoSearchTextField(
                padding: const EdgeInsets.all(16),
                onChanged: _updateSearch)),
        const SizedBox(width: 5),
        Expanded(child: _buildFilterMenu()),
      ],
    ),
  );

  Widget _buildFilterMenu() => PopupMenuButton<int>(
    onSelected: (value) => setState(() => staffList = _filterStaff(value)),
    itemBuilder: (_) => [
      const PopupMenuItem(value: 0, child: Text("all")),
      ...[
        "جورج مينا",
        "بولا برت",
        "يوسف جرجس",
        "بيشوي جوزيف",
        "بيتر القمص بيمن",
        "يوسف عصام",
        "ماريا الفونس",
        "فيلوباتير إيهاب",
        "كارين ماجد",
        "ديانا ماجد",
        "مريم فوزي",
        "اباكير سامي"
      ].asMap().entries.map(
              (e) => PopupMenuItem(value: e.key + 1, child: Text(e.value))),
    ],
  );

  List<User> _filterStaff(int value) => value == 0
      ? tempList
      : tempList
      .where((e) =>
  e.khadem ==
      [
        "جورج مينا",
        "بولا برت",
        "يوسف جرجس",
        "بيشوي جوزيف",
        "بيتر القمص بيمن",
        "يوسف عصام",
        "ماريا الفونس",
        "فيلوباتير إيهاب",
        "كارين ماجد",
        "ديانا ماجد",
        "مريم فوزي",
        "اباكير سامي"
      ][value - 1])
      .toList();

  Widget _buildAttendanceView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Radio buttons in a horizontal scrollable row
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: radioButtons.map((button) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ChoiceChip(
                      label: PText(
                        title: button["title"]!,
                        size: PSize.medium,
                        fontColor: selectedValue == button["value"]
                            ? Colors.white
                            : Colors.black,
                      ),
                      selected: selectedValue == button["value"],
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedValue = button["value"]!;
                            print("Selected: $selectedValue"); // Debug
                            switch (selectedValue) {
                              case "all":
                                headers = List.from(tempHeaders); // Deep copy
                                break;
                              case "khoras":
                                headers = tempHeaders.where((e) {
                                  final parts = e.toString().split(' ');
                                  return parts.length > 1 &&
                                      parts[1] == "khoras";
                                }).toList();
                                break;
                              case "tsb7a":
                                headers = tempHeaders.where((e) {
                                  final parts = e.toString().split(' ');
                                  return parts.length > 1 &&
                                      parts[1] == "tsb7a";
                                }).toList();
                                break;
                              case "3shea":
                                headers = tempHeaders.where((e) {
                                  final parts = e.toString().split(' ');
                                  return parts.length > 1 &&
                                      parts[1] == "3shea";
                                }).toList();
                                break;
                              case "2das":
                                headers = tempHeaders.where((e) {
                                  final parts = e.toString().split(' ');
                                  return parts.length > 1 && parts[1] == "2das";
                                }).toList();
                                break;
                              case "tsme3":
                                headers = tempHeaders.where((e) {
                                  final parts = e.toString().split(' ');
                                  return parts.length > 1 && parts[1] != "2das"&& parts[1] != "khoras"&& parts[1] != "tsb7a"&& parts[1] != "3shea";
                                }).toList();
                                break;
                            }
                            print("Headers updated to: $headers"); // Debug
                          });
                        }
                      },
                      selectedColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Attendance grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: (headers.length + 6) * 150.0, // +6 for additional columns
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: headers.length + 6, // +6 for additional columns
                  childAspectRatio: 2.5,
                ),
                itemCount: (staffList.length + 1) * (headers.length + 6),
                itemBuilder: (_, index) => _buildAttendanceCell(index),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAttendanceCell(int index) {
    final row = index ~/ (headers.length + 6); // +6 for additional columns
    final col = index % (headers.length + 6); // +6 for additional columns
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      alignment: Alignment.center,
      child: Text(
        row == 0
            ? (col == 0
            ? "Name"
            : col == 1
            ? "Score"
            : col == 2
            ? "2das"
            : col == 3
            ? "Khoras"
            : col == 4
            ? "Tsb7a"
            : col == 5
            ? "3shea"
            : headers[col - 6]) // Dynamic headers
            : col == 0
            ? staffList[row - 1].name!
            : col == 1
            ? (staffList[row - 1].score ?? 0).toString()
            : col == 2
            ? staffList[row - 1].count2das.toString()
            : col == 3
            ? staffList[row - 1].countKhoras.toString()
            : col == 4
            ? staffList[row - 1].countTsb7a.toString()
            : col == 5
            ? staffList[row - 1].count3shea.toString()
            : staffList[row - 1].attended.contains(headers[col - 6])
            ? '✓'
            : '',
        style: TextStyle(
          fontWeight: row == 0 || col == 0 ? FontWeight.bold : FontWeight.normal,
          fontSize: row > 0 && col > 0 ? 24 : null,
          color: row > 0 && col > 0 ? Colors.green : null,
        ),
      ),
    );
  }

  Widget _buildStaffView() => BlocConsumer<GetStaffCubit, GetStaffState>(
    listener: (context, state) {
      if (state is GetStaffErrorState) _showSnackBar(state.error);
      if (state is GetStaffSuccessState) {
        tempList = staffList = state.staffList;
      }
    },
    builder: (_, state) => state is GetStaffLoadingState
        ? const Center(child: CircularProgressIndicator())
        : state is GetStaffSuccessState
        ? GridView.builder(
      itemCount: staffList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
          MediaQuery.of(context).size.width ~/ 170),
      itemBuilder: (_, index) =>
          _buildStaffCard(staffList[index]),
    )
        : const SizedBox.shrink(),
  );

  Widget _buildStaffCard(User staff) => Column(
    children: [
      const SizedBox(height: 20),
      InkWell(
        onTap: () => selectedList.isNotEmpty
            ? _toggleSelection(staff)
            : _showUserDialog(staff),
        onLongPress: () => _toggleSelection(staff),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              child: staff.image == null
                  ? const Icon(Icons.person, size: 45)
                  : ClipOval(
                  child: CustomNetworkImage(
                      image: staff.image!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120)),
            ),
            if (selectedList.contains(staff))
              CircleAvatar(
                radius: 57,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withOpacity(0.7),
                child:
                const Icon(Icons.check, color: Colors.white, size: 50),
              ),
          ],
        ),
      ),
      const SizedBox(height: 15),
      PText(
          title: '${staff.name} (${staff.score ?? 0})', size: PSize.medium),
    ],
  );

  void _toggleSelection(User staff) =>
      setState(() => selectedList.contains(staff)
          ? selectedList.remove(staff)
          : selectedList.add(staff));

  void _showUserDialog(User staff) => showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('User Info'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildImagePicker(staff, setState),
              ..._buildUserFields(staff, setState),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildImagePicker(User staff, StateSetter setState) => InkWell(
    onTap: () async {
      final image =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage
            .from('images')
            .upload(fileName, File(image.path));
        staff.image = Supabase.instance.client.storage
            .from('images')
            .getPublicUrl(fileName);
        _updateField(staff, 'image', staff.image, setState);
      }
    },
    onLongPress: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Change Image'),
            content: _textField(
                'Image link', staff.image, TextInputType.url, (value) {
              _updateField(staff, 'image', value, setState);
              Navigator.of(context).pop();
            }),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
    child: Stack(
      children: [
        CircleAvatar(
          radius: 80,
          backgroundColor: Colors.grey[300],
          child: staff.image == null
              ? const Icon(Icons.person, size: 55)
              : ClipOval(
              child: CustomNetworkImage(
                  image: staff.image!,
                  fit: BoxFit.cover,
                  width: 160,
                  height: 160)),
        ),
        const Positioned(
            right: 5, bottom: 0, child: Icon(Icons.edit, size: 34)),
      ],
    ),
  );

  List<Widget> _buildUserFields(User staff, StateSetter setState) => [
    _textField('Name', staff.name, TextInputType.name,
            (value) => _updateField(staff, 'name', value, setState)),
    _textField(
        'Score',
        staff.score.toString(),
        TextInputType.number,
            (value) => _updateField(
            staff, 'score', int.parse(value ?? "0"), setState)),
    _textField('Phone', staff.phone, TextInputType.phone,
            (value) => _updateField(staff, 'phone', value)),
    _textField('Mom Phone', staff.momPhone, TextInputType.phone,
            (value) => _updateField(staff, 'momPhone', value)),
    _textField('Dad Phone', staff.dadPhone, TextInputType.phone,
            (value) => _updateField(staff, 'dadPhone', value)),
    _dropdownField(
        'class',
        ['5', '6'],
        staff.level.toString(),
            (value) =>
            _updateField(staff, 'class', int.parse(value!), setState)),
    _dropdownField(
        'Gender',
        ['بنت', 'ولد'],
        staff.gender, // Fixed here
            (value) => _updateField(staff, 'gender', value!, setState)),
    _textField(
        'Address',
        staff.address == "null" ? null : staff.address,
        TextInputType.streetAddress,
            (value) => _updateField(staff, 'address', value)),
    FormBuilderDateTimePicker(
      name: 'Date birth',
      initialValue: staff.dateBirth,
      format: DateFormat('MM-dd'),
      decoration: const InputDecoration(labelText: 'Date birth'),
      onChanged: (value) => _updateField(staff, 'dateBirth', value),
    ),
    _dropdownField(
        'khadem',
        [
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
        ],
        staff.khadem,
            (value) => _updateField(staff, 'khadem', value, setState)),
    _textField('Notes', staff.notes, TextInputType.text,
            (value) => _updateField(staff, 'notes', value)),
    staff.gender == "ولد"
        ? Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Is shamas?",
            style: TextStyle(fontSize: 20),
          ),
          Checkbox(
              value: staff.isShamas,
              onChanged: (val) {
                _updateField(staff, "isShamas", val, setState);
              }),
        ],
      ),
    )
        : const SizedBox.shrink(),
  ]
      .map((e) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.5), child: e))
      .toList();

  Widget _textField(String label, String? initialValue, TextInputType type,
      Function(String?) onSubmit) =>
      FormBuilderTextField(
        name: label,
        keyboardType: type,
        initialValue: initialValue,
        decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            floatingLabelBehavior: FloatingLabelBehavior.auto),
        onSubmitted: onSubmit,
      );

  Widget _dropdownField(String name, List<String> items, String? initialValue,
      Function(String?) onChanged) =>
      FormBuilderDropdown(
        name: name,
        decoration: InputDecoration(
            labelText: name[0].toUpperCase() + name.substring(1)),
        initialValue: initialValue,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      );

  Future<void> _updateField(User staff, String field, dynamic value,
      [StateSetter? setState]) async {
    staff.updateField(field, value);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(staff.uuid)
        .update({field: value});
    setState?.call(() {});
  }

  void _sortStaff() {
    setState(() {
      staffList.sort(sortByScore
          ? (a, b) => a.name!.compareTo(b.name!)
          : (a, b) => (b.score ?? 0).compareTo(a.score ?? 0));
      sortByScore = !sortByScore;
    });
  }

  void _showScoreSheet(BuildContext context) {
    DateTime dateTime = DateTime.now();
    final reasons = ["Bonus", "2das", "khoras", "tsb7a", "3shea", "tsme3"];
    String? selectedReason = reasons[0];
    String? selectedL7n;
    score = 0;
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => BlocProvider(
        create: (_) => AddScoreCubit(),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 25),
              Flexible(child: _buildSelectedUsersList()),
              const SizedBox(height: 10),
              if (selectedReason != "Bonus" && selectedReason != "tsme3")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FormBuilderDateTimePicker(
                    name: 'Date',
                    initialValue: dateTime,
                    format: DateFormat('yyyy-MM-dd'),
                    decoration: const InputDecoration(labelText: 'Date'),
                    onChanged: (value) => dateTime = value ?? DateTime.now(),
                  ),
                ),
              if (selectedReason == "tsme3")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: FormBuilderDropdown<String>(
                    name: 'All7n',
                    initialValue: null,
                    decoration: const InputDecoration(labelText: 'All7n'),
                    items: al7an
                        .map((e) => DropdownMenuItem(
                        value: e.toString(), child: Text(e.toString())))
                        .toList(),
                    onChanged: (value) => setState(() => selectedL7n = value),
                  ),
                ),
              if (score > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FormBuilderDropdown<String>(
                    name: 'Reason',
                    initialValue: reasons[0],
                    decoration: const InputDecoration(labelText: 'Event Type'),
                    items: reasons
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedReason = value);
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [-10, -5, -1, 0, 1, 5, 10]
                      .map((val) => val == 0
                      ? PText(title: score.toString(), size: PSize.large)
                      : _scoreButton(setState, val))
                      .toList(),
                ),
              ),
              const SizedBox(height: 25),
              BlocConsumer<AddScoreCubit, AddScoreState>(
                listener: (context, state) {
                  if (state is AddScoreSuccessState) {
                    selectedList.clear();
                    this.setState(() {});
                    Navigator.pop(context);
                  }
                  if (state is AddScoreErrorState) _showSnackBar(state.error);
                },
                builder: (context, state) => ElevatedButton(
                  onPressed: state is AddScoreLoadingState
                      ? null // Disable button while loading
                      : (selectedL7n == null && selectedReason == "tsme3")
                      ? () {
                    _showSnackBar("Please select all7n");
                  }
                      : () {
                    context.read<AddScoreCubit>().addScore(
                        selectedList,
                        tempList,
                        score,
                        selectedReason!,
                        selectedL7n,
                        DateFormat('yyyy-MM-dd').format(dateTime));
                  },
                  child: state is AddScoreLoadingState
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const PText(title: 'Submit', size: PSize.large),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedUsersList() => ListView.separated(
    shrinkWrap: true,
    separatorBuilder: (_, __) => const Divider(),
    itemCount: selectedList.length,
    itemBuilder: (_, index) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
            padding: EdgeInsets.all(25),
            child: CircleAvatar(
                radius: 25, child: Icon(Icons.person, size: 20))),
        Expanded(
            child: PText(
                title: selectedList.elementAt(index).name ?? '',
                size: PSize.veryLarge)),
      ],
    ),
  );

  Widget _scoreButton(StateSetter setState, int value) => SizedBox(
    width: 50,
    height: 50,
    child: InkWell(
      onTap: () => setState(() => score += value),
      child: Center(
          child: PText(
              title: value > 0 ? '+$value' : '$value',
              size: PSize.veryLarge)),
    ),
  );

  Future<void> _exportToExcel() async {
    if (await Permission.storage.isDenied) await Permission.storage.request();
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    sheet.appendRow(
        [TextCellValue("Name"),
        TextCellValue("Score"),
        TextCellValue("Khoras"),
        TextCellValue("2das"),
        TextCellValue("Tsb7a"),
        TextCellValue("3shea")
    ,...headers.map((h) => TextCellValue(h))]);
    for (var user in staffList) {
      sheet.appendRow([
        TextCellValue(user.name!),
        TextCellValue(user.score!.toString()),
        TextCellValue(user.countKhoras!.toString()),
        TextCellValue(user.count2das!.toString()),
        TextCellValue(user.countTsb7a!.toString()),
        TextCellValue(user.count3shea!.toString()),
        ...headers
            .map((h) => TextCellValue(user.attended.contains(h) ? "✓" : ""))
      ]);
    }
    final fileBytes = excel.encode();
    if (fileBytes == null) return;
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    if (directory != null) {
      final filePath =
          '${directory.path}/attendance_sheet_${DateTime.now().toIso8601String()}.xlsx';
      await File(filePath).writeAsBytes(fileBytes, flush: true);
      _showSnackBar("File saved successfully: $filePath");
    } else {
      _showSnackBar("Failed to get storage directory");
    }
  }

  void _showSnackBar(String message) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Alert!'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

  }
}

// Assuming User class has an updateField method
extension UserExtension on User {
  void updateField(String field, dynamic value) {
    switch (field) {
      case 'name':
        name = value;
        break;
      case 'score':
        score = value;
        break;
      case 'gender':
        gender = value;
        break;
      case 'phone':
        phone = value;
        break;
      case 'notes':
        notes = value;
        break;
      case 'momPhone':
        momPhone = value;
        break;
      case 'dadPhone':
        dadPhone = value;
        break;
      case 'class':
        level = value;
        break;
      case 'address':
        address = value;
        break;
      case 'dateBirth':
        dateBirth = value;
        break;
      case 'khadem':
        khadem = value;
        break;
      case 'isShamas':
        isShamas = value;
        break;
      case 'image':
        image = value;
        break;
    }
  }
}