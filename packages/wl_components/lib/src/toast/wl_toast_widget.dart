import 'package:flutter/material.dart';
import 'package:wl_components/src/colors/wl_colors.dart';
import 'package:wl_components/src/fonts/wl_font.dart';
import 'package:wl_components/src/size/wl_padding.dart';
import 'package:wl_components/src/toast/wl_toast.dart';
import 'package:wl_components/src/toast/wl_toast_config.dart';
import 'package:wl_components/src/toast/wl_toast_theme.dart';

class WLToastWidget extends StatefulWidget {
  const WLToastWidget({
    super.key,
    required this.config,
    required this.theme,
    required this.onDismiss,
  });

  final WLToastConfig config;
  final WLToastTheme theme;
  final VoidCallback onDismiss;

  @override
  State<WLToastWidget> createState() => _WLToastWidgetState();
}

class _WLToastWidgetState extends State<WLToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.config.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: _getSlideBegin(),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    Future.delayed(widget.config.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  Offset _getSlideBegin() {
    switch (widget.config.position) {
      case WLToastPosition.top:
        return const Offset(0, -1);
      case WLToastPosition.center:
        return const Offset(0, -0.5);
      case WLToastPosition.bottom:
        return const Offset(0, 1);
    }
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedOpacity(
          duration: widget.config.animationDuration,
          curve: Curves.easeInOut,
          opacity: 1.0,
          child: _buildToastContent(),
        ),
      ),
    );
  }

  Widget _buildToastContent() {
    final icon = widget.config.icon;
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: widget.config.margin.horizontal,
          vertical: widget.config.margin.vertical,
        ),
        constraints: BoxConstraints(maxWidth: widget.config.maxWidth),
        width: MediaQuery.of(context).size.width - WLPadding.doubleMedium,
        decoration: BoxDecoration(
          color:
              widget.config.backgroundColor ?? WLColors.toastDefaultBackground(),
          borderRadius: BorderRadius.circular(widget.config.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: widget.config.padding.top,
            bottom: widget.config.padding.bottom,
            left: WLPadding.small,
            right: WLPadding.small,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (icon != null) ...[
                icon,
                const SizedBox(width: WLPadding.small),
              ],
              Flexible(
                child: Text(
                  widget.config.message,
                  style: WLFont.normal.copyWith(
                    color: widget.config.textColor ?? widget.theme.textColor,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
