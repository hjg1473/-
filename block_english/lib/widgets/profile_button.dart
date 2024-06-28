import 'package:block_english/screens/Super/super_group_screen.dart';
import 'package:block_english/screens/Super/super_profile_screen.dart';
import 'package:block_english/utils/colors.dart';
import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({
    super.key,
    required this.name,
    this.isStudent = false,
  });

  final String name;
  final bool isStudent;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        if (isStudent) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileScreen(studentName: name)));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GroupScreen(groupName: name)));
        }
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: lightSurface,
        minimumSize: const Size(330, 80),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
                name[0],
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
            ],
          ),
        ],
      ),
    );
  }
}
