import 'package:flutter/material.dart';
import '/core/mixins/sound_mixin.dart';

class SoundButton extends StatelessWidget with SoundMixin {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  const SoundButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: onPressed == null
          ? null
          : () {
              playButtonSound(context);
              onPressed!();
            },
      child: child,
    );
  }
}

class SoundIconButton extends StatelessWidget with SoundMixin {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;

  const SoundIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      onPressed: onPressed == null
          ? null
          : () {
              playButtonSound(context);
              onPressed!();
            },
    );
  }
}

class SoundTextButton extends StatelessWidget with SoundMixin {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  const SoundTextButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: style,
      onPressed: onPressed == null
          ? null
          : () {
              playButtonSound(context);
              onPressed!();
            },
      child: child,
    );
  }
}

class SoundGestureDetector extends StatelessWidget with SoundMixin {
  final Widget child;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

  const SoundGestureDetector({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              playButtonSound(context);
              onTap!();
            },
      onLongPress: onLongPress == null
          ? null
          : () {
              playButtonSound(context);
              onLongPress!();
            },
      child: child,
    );
  }
}
