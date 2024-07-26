import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class SuperGameScreen extends StatefulWidget {
  const SuperGameScreen({super.key});

  @override
  State<SuperGameScreen> createState() => _SuperGameScreenState();
}

class _SuperGameScreenState extends State<SuperGameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Column(
            children: [
              Text(
                '문장 맞추기',
              ),
              Text(
                '1/14',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF989898),
                ),
              ),
            ],
          ),
          actions: const [
            Icon(
              Icons.group_rounded,
              size: 24,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              '24',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            SizedBox(
              width: 20,
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(children: [
          LinearPercentIndicator(
            percent: 0.05,
            progressColor: const Color(0xFFA0A0A0),
            backgroundColor: const Color(0xFFD9D9D9),
            barRadius: const Radius.circular(10),
            lineHeight: 22,
            padding: const EdgeInsets.all(0),
            center: const Padding(
              padding: EdgeInsets.only(right: 13.0),
              child: SizedBox.expand(
                child: Text(
                  '7분 남음',
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ),
          const Spacer(flex: 1),
          Container(
            width: double.infinity,
            height: 440,
            decoration: BoxDecoration(
                color: const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(17.0),
              child: Stack(children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: const Color(0xFFc2c2c2),
                          ),
                          child: const Center(
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: Color(0xFFf7f7f7),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          '문장을 번역해 보세요',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            '그는 그녀를 좋아한다',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            '사진',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Container(
                    width: 230,
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA0A0A0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 30.0),
                      child: Column(children: [
                        Text(
                          '친구들이 들어오고 있어요',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.group_rounded,
                                color: Colors.white,
                                size: 35,
                              ),
                              SizedBox(width: 10),
                              Text(
                                '6/24',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ])
                      ]),
                    ),
                  ),
                )
              ]),
            ),
          ),
          const Spacer(flex: 3),
        ]),
      ),
    );
  }
}
