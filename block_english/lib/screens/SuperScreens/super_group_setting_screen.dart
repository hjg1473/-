import 'package:block_english/services/super_service.dart';
import 'package:block_english/widgets/GroupWidget/pin_code_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupSettingScreen extends ConsumerStatefulWidget {
  const GroupSettingScreen(
      {super.key, required this.groupName, required this.groupId});
  final String groupName;
  final int groupId;

  @override
  ConsumerState<GroupSettingScreen> createState() => _GroupSettingScreenState();
}

class _GroupSettingScreenState extends ConsumerState<GroupSettingScreen>
    with SingleTickerProviderStateMixin {
  final _groupNameEditController = TextEditingController();

  bool pinCodeExist = false;
  bool pinCodeExpired = false;
  String _pinCode = '';
  Ticker? _ticker;
  Duration _elapsed = Duration.zero;

  onPinGeneratePressed() async {
    final result =
        await ref.watch(superServiceProvider).postPinNumber(widget.groupId);

    result.fold((failure) {
      //TODO: error handling
      debugPrint('[SUPER_GROUP_SETTING_SCREEN] onPinGenerated error');
      debugPrint(
          '[ERROR] code: ${failure.statusCode} detail: ${failure.detail}');
    }, (pinModel) {
      _ticker ??= createTicker((elapsed) {
        setState(() {
          _elapsed = elapsed;

          if (_elapsed.inSeconds >= 180) {
            pinCodeExpired = true;
            _ticker!.stop();
          }
        });
      });

      setState(() {
        _pinCode = pinModel.groupPinNumber;
        pinCodeExist = true;
        pinCodeExpired = false;
      });

      _elapsed = Duration.zero;
      if (!_ticker!.isActive) {
        _ticker!.start();
      }

      debugPrint('[PINCODE] $_pinCode');
    });
  }

  @override
  void dispose() {
    _groupNameEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('그룹 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '그룹명 변경',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _groupNameEditController..text = widget.groupName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixIcon: Icon(
                  Icons.edit,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      // TODO: add onPressed
                      () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 65, 65, 65),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    '저장하기',
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            const Text(
              '그룹 입장 핀코드 생성',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                onPressed: (pinCodeExpired || !pinCodeExist)
                    ? onPinGeneratePressed
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                ),
                child: const Text(
                  'PIN 코드 생성하기',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
            if (pinCodeExist)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: PinCodeWidget(
                  pinCode: _pinCode,
                  onButtonClicked: () {
                    setState(() {
                      _ticker!.stop();
                      pinCodeExist = false;
                    });
                  },
                  elapsed: _elapsed,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
