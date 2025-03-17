import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:khoras_5_6/Cubits/get_staff_cubit.dart';
import 'package:khoras_5_6/staff_screen.dart';
import 'package:khoras_5_6/widgets/p_text.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'Cubits/add_score_cubit.dart';
import 'constants.dart';
import 'models/user_model.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  QRScannerState createState() => QRScannerState();
}

class QRScannerState extends State<QRScanner> {
  MobileScannerController cameraController = MobileScannerController();
  Timer? _scanTimer;
  bool _isScanning = true;
  int score = 0;
  DateTime dateTime = DateTime.now();
  final List<String> reasons = [
    "Bonus",
    "2das",
    "khoras",
    "tsb7a",
    "3shea",
    "tsme3"
  ];
  String? selectedReason = "Bonus";
  String? selectedL7n;
  @override
  void dispose() {
    _scanTimer?.cancel();
    cameraController.dispose();
    super.dispose();
  }

  void _handleScan(Barcode barcode) async {
    if (!_isScanning) return;

    setState(() => _isScanning = false);

    String resultName = "";
    for (User user in StaffScreenState.tempList) {
      if (user.id.toString() == barcode.rawValue.toString()) {
        AddScoreCubit().addScore({user}, StaffScreenState.tempList, score,
            selectedReason!,selectedL7n, DateFormat('yyyy-MM-dd').format(dateTime));
        resultName =
            user.name ?? "User"; // Assuming User model has a name field
        break;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scanned: $resultName'),
        duration: const Duration(seconds: 5),
      ),
    );
    context.read<GetStaffCubit>();
    _scanTimer = Timer(const Duration(seconds: 3), () {
      setState(() => _isScanning = true);
    });
  }

  Widget _scoreWidget(StateSetter stateSetter, {required int value}) {
    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: InkWell(
        onTap: () => stateSetter(() => score += value),
        child: Center(
          child: PText(
            title: value > 0 ? '+$value' : value.toString(),
            size: PSize.veryLarge,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                _handleScan(barcode);
              }
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedReason != "Bonus" && selectedReason != "tsme3")
                    FormBuilderDateTimePicker(
                      name: 'Date',
                      currentDate: dateTime,
                      initialValue: DateTime.now(),
                      format: DateFormat('yyyy-MM-dd'),
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) => dateTime = value ?? DateTime.now(),
                    )
                  else if (selectedReason == "tsme3")
                    FormBuilderDropdown<String>(
                      name: 'All7n',
                      initialValue: "Choose",
                      decoration: InputDecoration(
                        labelText: 'All7n',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: StaffScreenState.al7an
                          .map((type) => DropdownMenuItem(
                                value: type.toString(),
                                child: Text(type.toString()),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedL7n = value),
                    ),
                  if (score != 0) ...[
                    const SizedBox(height: 16),
                    FormBuilderDropdown<String>(
                      name: 'Reason',
                      initialValue: reasons[0],
                      decoration: InputDecoration(
                        labelText: 'Event Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: reasons
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedReason = value),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: _scoreWidget(setState, value: -10)),
                      Expanded(child: _scoreWidget(setState, value: -5)),
                      Expanded(child: _scoreWidget(setState, value: -1)),
                      Expanded(
                        child: Container(
                          width: 60,
                          alignment: Alignment.center,
                          child: PText(
                            title: score.toString(),
                            size: PSize.large,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(child: _scoreWidget(setState, value: 1)),
                      Expanded(child: _scoreWidget(setState, value: 5)),
                      Expanded(child: _scoreWidget(setState, value: 10)),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
