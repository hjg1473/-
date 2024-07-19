import 'package:block_english/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegSuperFirstScreen extends ConsumerStatefulWidget {
  const RegSuperFirstScreen({super.key});

  @override
  ConsumerState<RegSuperFirstScreen> createState() => _RegSuperScreenState();
}

class _RegSuperScreenState extends ConsumerState<RegSuperFirstScreen> {
  final formkey = GlobalKey<FormState>();

  String username = '';
  String phonenumber = '';

  bool usernameExist = false;
  bool phonenumberExist = false;

  bool isValidated = false;

  onCheckPressed() async {
    if (!formkey.currentState!.validate()) {
      // TODO: show popup widget to fill data in proper format
      return;
    }
    // TODO: post auth/username_phone/verify

    final result = await ref
        .watch(authServiceProvider)
        .postAuthExistVerify(username, phonenumber);

    result.fold(
      (failure) {
        // TODO: show popup widget to notify that server is in some problem
      },
      (existCheckModel) {
        debugPrint('user: $usernameExist, phone: $phonenumberExist');
        setState(() {
          usernameExist = existCheckModel.usernameExist;
          phonenumberExist = existCheckModel.phonenumberExist;
          if (!(usernameExist || phonenumberExist)) isValidated = true;
        });
      },
    );

    return;
  }

  navigateNext() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RegSuperSecondScreen(username, phonenumber)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 40,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    "닉네임과 전화번호, 이메일을 입력해주세요",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Zㄱ-ㅎ가-힣]'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Color.fromRGBO(237, 231, 246, 1),
                    border: UnderlineInputBorder(),
                    labelText: '닉네임',
                    hintText: '닉네임을 입력해주세요',
                  ),
                  onChanged: (value) => setState(() {
                    username = value;
                    usernameExist = false;
                    phonenumberExist = false;
                    isValidated = false;
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '닉네임은 필수정보입니다';
                    }
                    if (usernameExist) {
                      return '이미 등록된 닉네임입니다.';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const Text(
                  "10자 이내",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  maxLength: 11,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9]'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Color.fromRGBO(237, 231, 246, 1),
                    border: UnderlineInputBorder(),
                    labelText: '전화번호',
                  ),
                  onChanged: (value) => setState(() {
                    phonenumber = value;
                    usernameExist = false;
                    phonenumberExist = false;
                    isValidated = false;
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '전화번호는 필수정보입니다.';
                    }
                    if (value.length < 11) {
                      return '전화번호가 너무 짧습니다';
                    }
                    if (phonenumberExist) {
                      return '이미 등록된 전화번호입니다';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const Text(
                  "(-)없이 전화번호를 입력해주세요 Ex) 01012341234",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60.0,
                    child: ElevatedButton(
                      onPressed: onCheckPressed,
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 102, 80, 164),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0))),
                      child: const Text(
                        "중복 확인",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60.0,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(
                              width: 1.0,
                              color: Color(0xFF6750A4),
                            ),
                          ),
                        ),
                      ),
                      onPressed: isValidated ? navigateNext : null,
                      child: const Text(
                        "다음으로",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegSuperSecondScreen extends ConsumerStatefulWidget {
  const RegSuperSecondScreen(this.username, this.phonenumber, {super.key});

  final String username;
  final String phonenumber;

  @override
  ConsumerState<RegSuperSecondScreen> createState() =>
      _RegSuperSecondScreenState();
}

class _RegSuperSecondScreenState extends ConsumerState<RegSuperSecondScreen> {
  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 40,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "인증번호와 비밀번호를",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "입력해주세요",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Zㄱ-ㅎ가-힣]'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Color.fromRGBO(237, 231, 246, 1),
                    border: UnderlineInputBorder(),
                    labelText: '인증번호',
                    hintText: '인증번호를 입력해주세요',
                  ),
                  // onChanged: (value) => setState(() {
                  //   username = value;
                  //   usernameExist = false;
                  //   phonenumberExist = false;
                  //   isValidated = false;
                  // }),
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return '닉네임은 필수정보입니다';
                  //   }
                  //   if (usernameExist) {
                  //     return '이미 등록된 닉네임입니다.';
                  //   }
                  //   return null;
                  // },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60.0,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 102, 80, 164),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0))),
                      child: const Text(
                        "중복 확인",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60.0,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(
                              width: 1.0,
                              color: Color(0xFF6750A4),
                            ),
                          ),
                        ),
                      ),
                      onPressed:
                          // isValidated ? navigateNext :
                          null,
                      child: const Text(
                        "다음으로",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
