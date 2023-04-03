import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'dart:io' show Platform;

import '../data/NativeData.dart';

class NativeListItem extends StatefulWidget {
  final Widget child;
  VoidCallback? onTap;
  bool hoverColors = true;

  NativeListItem({Key? key, required this.child, this.onTap, this.hoverColors = true}) : super(key: key);

  @override
  State<NativeListItem> createState() => _NativeListItemState();
}

class _NativeListItemState extends State<NativeListItem> {
  Color containerColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    NativePlatform platform = NativeData.getPlatform();

    if (platform == NativePlatform.macOS) {
      return Column(
        children: [
          GestureDetector(
            onTap: widget.onTap,
            onTapDown: widget.hoverColors ? (details) {
              if (widget.onTap != null) {
                containerColor = MacosColors.systemBlueColor.withOpacity(0.6);
                setState(() {});
              }
            } : null,
            onTapUp:  widget.hoverColors ? (details) {
              containerColor = Colors.transparent;
              setState(() {});
            } : null,
            child: MouseRegion(
              cursor: (widget.onTap == null ||  !widget.hoverColors)
                  ? SystemMouseCursors.basic
                  : SystemMouseCursors.click,
              onEnter: (details) {
                if (widget.onTap != null && widget.hoverColors) {
                  containerColor = MacosTheme.brightnessOf(context).resolve(
                    MacosColors.systemBlueColor.withOpacity(0.1),
                    MacosColors.alternatingContentBackgroundColor,
                    // const Color.fromRGBO(255, 255, 255, 0.25),
                  );
                  setState(() {});
                }
              },
              onExit: (details) {
                containerColor = Colors.transparent;
                setState(() {});
              },
              child: Container(
                color: containerColor,
                child: widget.child,
              ),
            ),
          ),
          Container(
            color: MacosTheme.of(context).brightness.resolve(
                  MacosColors.disabledControlTextColor,
                  MacosColors.disabledControlTextColor.darkColor,
                ),
            height: 0.5,
          )
        ],
      );
    } else {
      return Column(
        children: [
          GestureDetector(
            onTap: widget.onTap,
            onTapDown: (details) {
              if (widget.onTap != null) {
                containerColor = Theme.of(context).primaryColor.withOpacity(0.6);
                setState(() {});
              }
            },
            onTapUp: (details) {
              containerColor = Colors.transparent;
              setState(() {});
            },
            child: MouseRegion(
              cursor: widget.onTap == null
                  ? SystemMouseCursors.basic
                  : SystemMouseCursors.click,
              onEnter: (details) {
                if (widget.onTap != null) {
                  containerColor = Theme.of(context).primaryColor.withOpacity(0.1);
                  setState(() {});
                }
              },
              onExit: (details) {
                containerColor = Colors.transparent;
                setState(() {});
              },
              child: Container(
                color: containerColor,
                child: widget.child,
              ),
            ),
          ),
          Container(
            color: Theme.of(context).dividerColor,
            height: 0.5,
          )
        ],
      );
    }
  }
}
