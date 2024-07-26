import 'package:flutter/material.dart';
import 'package:speech_balloon/speech_balloon.dart';

class StudentGameScreen extends StatefulWidget {
  const StudentGameScreen({super.key});

  @override
  State<StudentGameScreen> createState() => _StudentGameScreenState();
}

class _StudentGameScreenState extends State<StudentGameScreen> {
  int? pin;
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                const SpeechBalloon(
                  borderRadius: 12,
                  color: Color(0xFFD0BCFF),
                  width: 300,
                  height: 80,
                  nipLocation: NipLocation.bottom,
                  nipHeight: 30,
                  child: Center(
                    child: Text(
                      "게임 코드를 입력하세요",
                      style: TextStyle(
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 30),
                  textAlign: TextAlign.center,
                  onSaved: (String? value) {},
                  validator: (String? value) {
                    value = value?.trim() ?? "";
                    if (value.isEmpty) {
                      return '입장할 게임 방의 번호를 입력해주세요';
                    }
                    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                      return '정확한 방 번호를 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 100,
                ),
                Transform.scale(
                  scale: 2.4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(45),
                      color: const Color(0xFF6750A4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          offset: Offset(1, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("게임 접속 중..."),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.check,
                        color: Color(0xFFD0BCFF),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
