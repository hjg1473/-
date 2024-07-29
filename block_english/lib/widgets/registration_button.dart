import 'package:flutter/material.dart';

class RegistrationWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final String routeName;

  const RegistrationWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.text,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 200,
      child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(20),
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(routeName);
          },
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                //TODO: 이미지 추가
                Icon(icon, color: Colors.black),
              ],
            ),
          )),
    );
  }
}
