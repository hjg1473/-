import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PinCodeWidget extends ConsumerStatefulWidget {
  const PinCodeWidget({
    super.key,
    required this.onButtonClicked,
    required this.pinCode,
    required this.elapsed,
  });
  final VoidCallback onButtonClicked;
  final String pinCode;
  final Duration elapsed;

  @override
  ConsumerState<PinCodeWidget> createState() => _PinCodeWidgetState();
}

class _PinCodeWidgetState extends ConsumerState<PinCodeWidget>
    with SingleTickerProviderStateMixin {
  String _formatDuration() {
    final seconds = (180 - widget.elapsed.inSeconds) % 60;
    final minutes = (180 - widget.elapsed.inSeconds) ~/ 60;

    var returnString = '';

    if (minutes != 0) {
      returnString += '$minutes분';
    }

    if (seconds != 0) {
      if (returnString.isNotEmpty) {
        returnString += ' ';
      }
      returnString += '$seconds초';
    }

    if (seconds == 0 && minutes == 0) {
      returnString = '핀 번호가 만료되었습니다. 다시 생성해주세요';
    }

    return returnString;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black,
              offset: Offset(
                0.5,
                0.5,
              ),
              blurRadius: 1.0,
            ),
          ],
          color: Colors.white),
      width: double.infinity,
      child: Column(
        children: [
          const Text(
            '모니터링 학습차 추가 핀코드',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            '학습자는 학습자 추가 핀코드를 입력해주세요',
            style: TextStyle(
              color: Color.fromARGB(255, 148, 148, 148),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (String pin in widget.pinCode.split('')) PinBlock(pin: pin)
            ],
          ),
          Text(
            _formatDuration(),
            style: const TextStyle(
              color: Color.fromARGB(255, 148, 148, 148),
              fontWeight: FontWeight.w500,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: widget.onButtonClicked,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 65, 65, 65),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  '닫기',
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PinBlock extends StatelessWidget {
  const PinBlock({super.key, required this.pin});

  final String pin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        child: Text(
          pin,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
