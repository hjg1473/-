import 'package:block_english/utils/colors.dart';
import 'package:block_english/utils/constants.dart';
import 'package:flutter/material.dart';

class StudentProfileCard extends StatelessWidget {
  const StudentProfileCard({
    super.key,
    required this.name,
    this.age = '',
    this.isStudent = false,
    this.teamName,
  });

  final String name;
  final String age;
  final String? teamName;
  final bool isStudent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: lightSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black54,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: lightPrimary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Text(
                  name != '' ? name[0] : " ",
                  style: const TextStyle(
                    color: lightSurface,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    age == '' ? name : "$name / ${gradelist[int.parse(age)]}",
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            isStudent
                ? Container(
                    height: 80,
                    width: 125,
                    decoration: const BoxDecoration(
                        color: lightPrimary,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        )),
                    child: Center(
                      child: Text(
                        teamName ?? "반 등록하기",
                        style: const TextStyle(
                          color: lightSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
