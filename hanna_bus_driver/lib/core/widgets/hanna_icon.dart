import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HannaIcon extends StatelessWidget {
  const HannaIcon(this.name, {super.key, this.size = 20, this.color});

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? IconTheme.of(context).color ?? Colors.black;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final effectiveName = isRtl
        ? const {
                'arrow-left': 'arrow-right',
                'arrow-right': 'arrow-left',
                'caret-left': 'caret-right',
                'caret-right': 'caret-left',
              }[name] ??
              name
        : name;
    return SvgPicture.asset(
      'assets/icons/$effectiveName.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}
