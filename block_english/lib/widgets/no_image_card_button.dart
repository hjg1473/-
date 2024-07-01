import 'package:block_english/utils/colors.dart';
import 'package:flutter/material.dart';

class NoImageCard extends StatelessWidget {
  const NoImageCard({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      height: 55,
      decoration: BoxDecoration(
        color: lightSurface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.black54,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 15,
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.black54,
            ),
            onPressed: null,
          ),
        ],
      ),
    );
  }
}
