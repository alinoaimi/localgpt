import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:localgptflutter/always-native/actions/DialogsSheetsActions.dart';
import 'package:localgptflutter/always-native/widgets/NativeButton.dart';
import 'package:localgptflutter/always-native/widgets/NativeCircularProgressIndicator.dart';
import 'package:localgptflutter/always-native/widgets/NativeIconButton.dart';
import 'package:localgptflutter/always-native/widgets/NativeListItem.dart';
import 'package:localgptflutter/data/GlobalUtils.dart';
import 'package:localgptflutter/data/settings.dart';
import 'package:localgptflutter/screens/NewConversationPopup.dart';
import 'package:localgptflutter/widgets/ConversationListItem.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:url_launcher/url_launcher.dart';

import '../networking/CustomDio.dart';

class ConversationsList extends StatefulWidget {
  DataCallback? onConversationSelected;
  int? selectedConversationId;

  ConversationsList(
      {Key? key, this.onConversationSelected, this.selectedConversationId})
      : super(key: key);

  @override
  State<ConversationsList> createState() => _ConversationsListState();
}

class _ConversationsListState extends State<ConversationsList> {
  bool conversationsLoading = true;
  List<dynamic> conversations = [];
  int? selectedConversationId;
  late IO.Socket socket;

  loadConversations({loadLatest = false}) async {
    try {
      var response = await CustomDio().get('/conversations');

      conversations = [];
      conversations = response.data;

      conversationsLoading = false;
      setState(() {});

      if(loadLatest) {
        int latestConvoId;
        latestConvoId = conversations[0]['id'];
        if (widget.onConversationSelected != null && latestConvoId != null) {
          selectedConversationId = latestConvoId;
          widget.onConversationSelected!(latestConvoId);
        }
      }

    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  newConversation() async {


    DialogsSheetsActions.nativeShowSheet(context: context, child: NewConversationPopup(
      onRefreshRequests: () {
        loadConversations(loadLatest: true);
      }
    ));

    // try {
    //   var req = await CustomDio().post('/conversations', data: {});
    //
    //   if (req.data['conversation_id'] != null) {
    //     await loadConversations();
    //     selectedConversationId = req.data['conversation_id'];
    //     setState(() {});
    //   }
    // } catch (ex) {
    //   debugPrint(ex.toString());
    // }
  }

  @override
  void initState() {
    super.initState();

    if (widget.selectedConversationId != null) {
      selectedConversationId = widget.selectedConversationId;
    }

    socket = IO.io(
        SettingsData.apiSocketsUrl,
        IO.OptionBuilder()
            .enableForceNew()
            .setTransports(['websocket']) // for Flutter or Dart VM
            // .disableAutoConnect()  // disable auto-connection
            .enableAutoConnect()
            // .setQuery({'access_token': widget.newToken == null ? storage.read('access_token') : widget.newToken})
            .build());

    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
    });
    socket.on('ui_action', (data) {
      debugPrint('received sockets event: ui_action');
      debugPrint(data);

      if (data == 'refresh_conversations_list') {
        loadConversations();
      }
    });

    loadConversations();
  }

  @override
  void dispose() {
    try {
      socket.dispose();
    } catch (ex) {
      debugPrint(ex.toString());
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    var children = <Widget>[];

    // to be added in the future
    // Widget searchBox = Container(
    //   height: 45,
    //   child:  Text('search'),
    // );
    //
    // children.add(searchBox);

    body = Column(
      children: children,
    );

    Widget conversationsList;
    if (conversationsLoading) {
      conversationsList = Center(
        child: NativeCircularProgressIndicator(
          width: 10,
        ),
      );
    } else {
      List<Widget> conversationsWidgets = [];

      for (var conversation in conversations) {
        conversationsWidgets.add(Container(
          color: conversation['id'] == selectedConversationId
              ? Theme.of(context).primaryColorDark
              : Colors.transparent,
          child: NativeListItem(
              hoverColors: false,
              onTap: () {
                if (widget.onConversationSelected != null) {
                  selectedConversationId = conversation['id'];
                  widget.onConversationSelected!(conversation['id']);
                }
              },
              child: ConversationListItem(conversation: conversation)),
        ));
        conversationsWidgets.add(Container(
          height: 1,
          width: 250,
          color: Theme.of(context).dividerColor,
        ));
      }

      conversationsList = SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: conversationsWidgets,
        ),
      );
    }

    var bottomBar = Container(
      height: 60,
      width: 250,
      child: Column(
        children: [
          Divider(
            color: Theme.of(context).dividerColor,
            indent: 0,
            endIndent: 0,
            height: 1,
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 200,
                child: NativeButton(
                  icon: Icons.messenger_outline,
                  child: const Text(
                    'New Conversation',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    newConversation();
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );

    Widget topBar = Column(
      children: [
        Row(
          children: [
            Container(
              height: 60,
              child: const Center(
                  child: Text(
                'LocalGPT',
                style: TextStyle(fontSize: 20),
              )),
            ),
            SizedBox(
              width: 100,
            ),
            // NativeIconButton(icon: Icon(Icons.settings)),
            // SizedBox(
            //   width: 10,
            // ),
            NativeIconButton(icon: Icon(Icons.info_outline), onPressed: () async {
              PackageInfo packageInfo =
                  await PackageInfo.fromPlatform();

              showAboutDialog(
                  context: context,
                  applicationVersion: packageInfo.version,
                  applicationIcon: SizedBox(
                    height: 48,
                    child:
                    Image.asset('assets/images/rounded-icon.png'),
                  ),
                  children: [
                    const Text(
                        'A unified client for open source AI chat engines.'),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const Text('by Ali Alnoaimi'),
                        const SizedBox(
                          width: 10,
                        ),
                        IconButton(
                            onPressed: () {
                              try {
                                launchUrl(Uri.parse(
                                    'https://twitter.com/ghost013li'));
                              } catch (ex) {
                                debugPrint(ex.toString());
                              }
                            },
                            icon: const Iconify(Mdi.twitter)),
                        IconButton(
                            onPressed: () {
                              try {
                                launchUrl(Uri.parse(
                                    'https://github.com/alinoaimi'));
                              } catch (ex) {
                                debugPrint(ex.toString());
                              }
                            },
                            icon: const Iconify(Mdi.github)),
                      ],
                    )
                  ]);
            },),
          ],
        ),
        Container(
          height: 1,
          width: 250,
          color: Theme.of(context).dividerColor,
        )
      ],
    );

    body = Container(
      color: const Color.fromRGBO(255, 255, 255, 0.07),
      child: Column(
        children: [topBar, Expanded(child: conversationsList), bottomBar],
      ),
    );

    return body;
  }
}
