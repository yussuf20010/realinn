import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedWhatsAppIcon extends StatefulWidget {
  final double? size;
  final Color? color;

  const AnimatedWhatsAppIcon({
    Key? key,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  State<AnimatedWhatsAppIcon> createState() => _AnimatedWhatsAppIconState();
}

class _AnimatedWhatsAppIconState extends State<AnimatedWhatsAppIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size ?? 24.sp,
        height: widget.size ?? 24.sp,
        decoration: BoxDecoration(
          color: widget.color ?? Color(0xFF25D366), // WhatsApp green
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.chat,
          color: Colors.white,
          size: (widget.size ?? 24.sp) * 0.6,
        ),
      ),
    );
  }
}

