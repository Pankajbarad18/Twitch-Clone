import 'package:flutter/material.dart';
import 'package:twitch_clone/utilities/colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color color;
  const CustomButton(
      {super.key,
      required this.onTap,
      required this.text,
      this.color = buttonColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Text(
        text,
        style: color == buttonColor
            ? const TextStyle(fontSize: 20, color: Colors.white)
            : const TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }
}
