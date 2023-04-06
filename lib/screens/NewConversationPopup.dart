import 'package:flutter/material.dart';
import 'package:localgptflutter/always-native/actions/DialogsSheetsActions.dart';
import 'package:localgptflutter/always-native/widgets/NativeButton.dart';
import 'package:localgptflutter/always-native/widgets/NativeMaterial.dart';
import 'package:localgptflutter/data/settings.dart';
import 'package:localgptflutter/networking/CustomDio.dart';
import 'package:localgptflutter/screens/DownloadPopup.dart';
import 'package:localgptflutter/widgets/ParentDialog.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:flutter_download_manager/flutter_download_manager.dart';

class NewConversationPopup extends StatefulWidget {
  VoidCallback? onRefreshRequests;

  NewConversationPopup({Key? key, this.onRefreshRequests}) : super(key: key);

  @override
  State<NewConversationPopup> createState() => _NewConversationPopupState();
}

class _NewConversationPopupState extends State<NewConversationPopup> {
  List<DropdownMenuItem> modelChildren = [];
  ModelObject? _selectedModel;
  var appSupportDir;

  @override
  void initState() {
    super.initState();

    setupVariables();

    for (ModelObject model in SettingsData.models) {
      DropdownMenuItem dropdownMenuItem =
          DropdownMenuItem(child: Text(model.label));
      modelChildren.add(dropdownMenuItem);
    }
    setState(() {});
  }

  setupVariables() async {
    appSupportDir = await getApplicationSupportDirectory();
    setState(() {});
  }

  startConversation() async {
    var modelPath =
        '${appSupportDir.absolute.path}/${_selectedModel!.localPath}';
    // for a file
    bool modelExists = io.File(modelPath).existsSync();

    if (modelExists) {
      doStartConversation();
    } else {
      // download it

      DialogsSheetsActions.nativeShowSheet(
          context: context,
          child: DownloadPopup(
              url: _selectedModel!.downloadUrl!,
              destination:
                  '${appSupportDir.absolute.path}/${_selectedModel!.localPath}',
              onDownloadComplete: () {
                doStartConversation();
              }));

    }
  }

  doStartConversation() async {
    try {
      var req = await CustomDio().post('/conversations', data: {
        'engine': 'gpt4all',
        'model_path':
            '${appSupportDir.absolute.path}/${_selectedModel!.localPath}'
      });

      if (req.data['conversation_id'] != null) {
        if (widget.onRefreshRequests != null) {
          widget.onRefreshRequests!();
          Navigator.pop(context);
        }
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    List<Widget> children = [];

    children.add(const Text('Engine'));
    children.add(const SizedBox(
      height: 5,
    ));
    children.add(NativeMaterial(
      child: DropdownButton(
          hint: Text('Engine'),
          items: [
            DropdownMenuItem(
                child: Container(width: 200, child: Text('gpt4all')))
          ],
          onChanged: (newVal) {}),
    ));

    children.add(const SizedBox(
      height: 20,
    ));

    children.add(const Text('Model'));
    children.add(const SizedBox(
      height: 5,
    ));

    if (appSupportDir != null) {
      children.add(NativeMaterial(
        child: DropdownButton(
            hint: const Text('Engine'),
            value: _selectedModel,
            items: SettingsData.models
                .map<DropdownMenuItem<ModelObject>>((ModelObject value) {
              // check if it is donwloaded

              var modelPath =
                  '${appSupportDir.absolute.path}/${value.localPath}';
              // for a file
              bool modelExists = io.File(modelPath).existsSync();

              debugPrint(modelPath);

              return DropdownMenuItem<ModelObject>(
                value: value,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value.label,
                        style: TextStyle(fontSize: 17),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      modelExists
                          ? Text(
                              'downloaded',
                              style: TextStyle(color: Colors.green),
                            )
                          : Text(
                              '${value.size} - will be downloaded if selected',
                              style: TextStyle(fontSize: 13),
                            )
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (newVal) {
              _selectedModel = newVal;

              setState(() {});
            }),
      ));
    } else {
      children.add(const Text('loading...'));
    }

    children.add(SizedBox(
      height: 20,
    ));

    if (_selectedModel != null) {
      children.add(NativeButton(
        child: const Text(
          'Start',
          style: TextStyle(fontSize: 20),
        ),
        onPressed: () {
          startConversation();
        },
      ));
    }

    body = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );

    return ParentDialog(title: 'New Conversation', child: body);
  }
}
