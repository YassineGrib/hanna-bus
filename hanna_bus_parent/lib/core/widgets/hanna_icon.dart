import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HannaIcon extends StatelessWidget {
  const HannaIcon(
    this.name, {
    super.key,
    this.size = 20,
    this.color,
  });

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? IconTheme.of(context).color ?? Colors.black;
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}
