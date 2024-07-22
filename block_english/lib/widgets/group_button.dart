import 'package:block_english/screens/SuperScreens/super_monitor_group_screen.dart';
import 'package:flutter/material.dart';

class GroupButton extends StatelessWidget {
  const GroupButton({
    super.key,
    required this.name,
    required this.id,
    required this.studentNum,
  });

  final String name;
  final int id;
  final int studentNum;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MonitorGroupScreen(
                      groupName: name,
                      groupId: id,
                    )));
      },
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFEAEAEA),
        minimumSize: const Size(330, 80),
        padding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                id.toString(),
                style: const TextStyle(
                  color: Color(0xFFC2C2C2),
                  fontSize: 30,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.person_rounded,
                      color: Color(0xFF838383), size: 15),
                  Text(' $studentNum명',
                      style: const TextStyle(color: Color(0xFF9D9D9D))),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
