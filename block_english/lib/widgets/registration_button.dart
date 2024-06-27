import 'package:flutter/material.dart';

class RegistrationWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final String routeName;

  const RegistrationWidget({
    super.key,
    required this.icon,
    required this.text,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 300,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
        ),
        onPressed: () {
          // Navigator.of(context).pushNamed(routeName);
        },
        icon: Icon(
          icon,
          size: 35,
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 35,
          ),
        ),
      ),
    );
  }
}
