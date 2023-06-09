
import 'package:fluent_ui/fluent_ui.dart' as fluent_ui;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:localgptflutter/always-native/data/NativeData.dart';
import 'package:macos_ui/macos_ui.dart';
import 'dart:io' show Platform;

import 'package:yaru/yaru.dart';

class NativeApp extends StatefulWidget {
  final String title;
  final bool debugShowCheckedModeBanner;
  final Map<String, WidgetBuilder>? routes;
  Map<String, dynamic>? macosui;
  ThemeMode? themeMode;

  NativeApp(
      {Key? key,
      this.title = '',
      this.debugShowCheckedModeBanner = true,
      this.routes,
      this.macosui,
      this.themeMode})
      : super(key: key);

  @override
  State<NativeApp> createState() => _NativeAppState();
}

class _NativeAppState extends State<NativeApp> {
  @override
  Widget build(BuildContext context) {

    NativePlatform platform = NativeData.getPlatform();

    if (platform == NativePlatform.macOS) {
      return MacosApp(
        title: widget.title,
        debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
        routes: widget.routes!,
        theme: widget.macosui?['theme'],
        darkTheme: widget.macosui?['darkTheme'],
        themeMode: widget.themeMode,
      );
    } else if (platform == NativePlatform.Linux) {
      return YaruTheme(builder: (context, yaru, child) {
        return MaterialApp(
          theme: yaru.theme,
          darkTheme: yaru.darkTheme,
          title: widget.title,
          routes: widget.routes!,
          themeMode: widget.themeMode,
          debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
        );
      });
    } else if (platform == NativePlatform.Windows) {
      return fluent_ui.FluentApp(
        title: 'MyApp',
        darkTheme: fluent_ui.ThemeData(
          brightness: Brightness.dark,
        ),
        theme: fluent_ui.ThemeData(
        ),
        routes: widget.routes!,
      );
    }

    return MaterialApp(
      title: widget.title,
      routes: widget.routes!,
      themeMode: widget.themeMode,
    );
  }
}
