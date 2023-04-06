import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localgptflutter/always-native/widgets/NativeCircularProgressIndicator.dart';
import 'package:localgptflutter/always-native/widgets/NativeWindow.dart';
import 'package:localgptflutter/data/settings.dart';
import 'package:localgptflutter/networking/CustomDio.dart';
import 'package:localgptflutter/widgets/ConversationPlaceholder.dart';
import 'package:localgptflutter/widgets/ConversationsList.dart';
import 'package:localgptflutter/widgets/ConversationsWidget.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:flutter/services.dart' show rootBundle;

import 'SetupScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool backendIsRunning = false;
  String screen = 'loading';
  String loadingMessage = '';

  pingBackend() async {
    try {



      var pingReq = await CustomDio().get('/ping');

      if (pingReq.data['success']) {
        // check if the model has been downloaded
        final appSupportDir = await getApplicationSupportDirectory();


        var modelPath =
            '$appSupportDir/models/gpt4all/gpt4all-lora-quantized.bin';
        // for a file
        bool modelExists = await io.File(modelPath).exists();

        if(!modelExists) {
          screen = 'setup';
        } else {
          screen = 'conversations';
        }

        screen = 'conversations';

        setState(() {});
      } else {
        startBackend();
      }
    } catch (ex) {
      debugPrint('pingBackend');
      debugPrint(ex.toString());
      startBackend();
    }
  }

  startBackend() async {
    loadingMessage = 'Starting backend.';
    setState(() {});

    try {
      var process = await Process.start(
          SettingsData.backendExecPath, ['--db', SettingsData.databasePath]);

      process.stdout.listen((event) {
        debugPrint('received event stdout: ');

        String decoded =
            utf8.decode(event.where((element) => element != 8).toList());

        debugPrint(decoded);

        if (decoded.contains('localgpt-api listening on port ')) {
          if (!decoded.contains('1092')) {
            SettingsData.backendPort = int.parse(
                decoded.replaceAll('localgpt-api listening on port ', ''));
          }

          screen = 'conversations';
          setState(() {});
        }
      }, onDone: () {
        debugPrint('startBackend process done');
        setState(() {});
      });

      process.stderr.listen((event) {
        debugPrint('received even stderrt: ');

        String decoded =
            utf8.decode(event.where((element) => element != 8).toList());

        debugPrint(decoded);
      }, onDone: () {
        debugPrint('startBackend process done');
        setState(() {});
      });
    } catch (ex) {
      debugPrint('startBackend error');
      debugPrint(ex.toString());
    }
  }

  @override
  void initState() {
    super.initState();

    loadingMessage = 'Checking if backend is online.';
    pingBackend();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (screen == 'loading') {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NativeCircularProgressIndicator(
            width: 15,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(loadingMessage)
        ],
      );
    } else if (screen == 'setup') {
      body = const SetupScreen();
    } else {
      body = const ConversationsWidget();
    }

    return NativeWindow(
      windowTitle: 'LocalGPT',
      child: body,
    );
  }
}
