import 'package:flutter/material.dart';
import '../../utils/palette.dart';
import 'styled_text.dart';

class RandomFloatingButton extends StatelessWidget {
  const RandomFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xFFFFCC00),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      icon: Icon(Icons.auto_awesome_rounded, color: gray[500]),
      label: StyledText(text: "Random", style: Theme.of(context).textTheme.labelLarge!, textHeight: 20,),
      onPressed: () {
        // Button pressed action can be implemented here
      },
    );
  }
}