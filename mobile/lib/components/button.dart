import 'package:flutter/material.dart';
import 'package:mobile/utils/config.dart';

class Button extends StatelessWidget {
  const Button({
    Key? key,
    required this.width,
    required this.title,
    required this.disable,
    required this.onPressed,
    required this.padding,
  }) : super(key: key);

  final double width;
  final String title;
  final bool disable;
  final EdgeInsets padding;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Preset.primaryColor,
          foregroundColor: Preset.foregroundColor,
          padding: padding
        ),
        onPressed: disable ? null : onPressed,
        child: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
