import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localgptflutter/always-native/widgets/NativeButton.dart';
import 'package:localgptflutter/always-native/widgets/NativeCircularProgressIndicator.dart';
import 'package:localgptflutter/always-native/widgets/NativeIconButton.dart';
import 'package:localgptflutter/always-native/widgets/NativeListItem.dart';
import 'package:localgptflutter/data/GlobalUtils.dart';
import 'package:localgptflutter/widgets/ConversationListItem.dart';
import 'package:macos_ui/macos_ui.dart';

import '../networking/CustomDio.dart';

class ConversationsList extends StatefulWidget {

  DataCallback? onConversationSelected;
  int? selectedConversationId;


  ConversationsList({Key? key, this.onConversationSelected, this.selectedConversationId}) : super(key: key);

  @override
  State<ConversationsList> createState() => _ConversationsListState();
}

class _ConversationsListState extends State<ConversationsList> {
  bool conversationsLoading = true;
  List<dynamic> conversations = [];
  int? selectedConversationId;

  loadConversations() async {

    try {

      var response = await CustomDio().get('/conversations');

      conversations = [];
      conversations = response.data;

      conversationsLoading = false;
      setState(() {

      });

    } catch(ex) {
      debugPrint(ex.toString());
    }

  }

  @override
  void initState() {
    super.initState();

    if(widget.selectedConversationId != null) {
      selectedConversationId = widget.selectedConversationId;
    }

    loadConversations();

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
      
      for(var conversation in conversations) {
        conversationsWidgets.add(Container(
          color: conversation['id'] == selectedConversationId ? Theme.of(context).primaryColorDark : Colors.transparent,
          child: NativeListItem(
              hoverColors: false,
              onTap: () {
                if(widget.onConversationSelected != null) {
                  selectedConversationId = conversation['id'];
                  widget.onConversationSelected!(conversation['id']);
                }
              },
              child: ConversationListItem(conversation: conversation)),
        ));
        conversationsWidgets.add(
          Container(
            height: 1,
            width: 250,
            color: Colors.white24,
          )
        );
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
          const Divider(
            color: Colors.white24,
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
                  child: const Text('New Conversation', style: TextStyle(fontSize: 16),),
                  onPressed: () {},
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
              child: const Center(child: Text('LocalGPT', style: TextStyle(
                fontSize: 20
              ),)),
            ),
            SizedBox(width: 40,),
            NativeIconButton(icon: Icon(Icons.settings)),
            SizedBox(width: 10,),
            NativeIconButton(icon: Icon(Icons.info_outline)),
          ],
        ),
        Container(
          height: 1,
          width: 250,
          color: Colors.white24,
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
