import 'package:flutter/material.dart';
import '../../l10n/l10n_extensions.dart';
import '../shared/styled_text.dart';

// The button is yellow in both themes, so its content stays dark.
const _onYellow = Color(0xFF283141);

class RandomFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RandomFloatingButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xFFFFCC00),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      icon: Icon(Icons.auto_awesome_rounded, color: _onYellow),
      label: StyledText(
        text: context.l10n.random,
        style: Theme.of(
          context,
        ).textTheme.labelLarge!.copyWith(color: _onYellow),
        textHeight: 20,
      ),
      onPressed: onPressed,
    );
  }
}
