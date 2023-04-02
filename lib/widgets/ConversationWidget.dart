import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localgptflutter/always-native/widgets/NativeButton.dart';
import 'package:localgptflutter/always-native/widgets/NativeIconButton.dart';
import 'package:macos_ui/macos_ui.dart';

class ConversationWidget extends StatefulWidget {

  int conversationId;

  ConversationWidget({Key? key, required this.conversationId}) : super(key: key);

  @override
  State<ConversationWidget> createState() => _ConversationWidgetState();
}

class _ConversationWidgetState extends State<ConversationWidget> {

  String title = 'loading';
  TextEditingController humanMessageController = TextEditingController();
  bool sendEnabled = false;

  @override
  Widget build(BuildContext context) {

    List<Widget> topBarTitleChildren = [];
    topBarTitleChildren.add(Text(title));
    topBarTitleChildren.add(const SizedBox(height: 3,));
    topBarTitleChildren.add(Text('typing...', style: TextStyle(
      color: Colors.white70,
      fontSize: 12
    ),));


    var topWidget = Container(
      height: 60,
      child: Row(
        children: [
          const SizedBox(width: 10,),
          const CircleAvatar(
            backgroundImage: AssetImage('assets/images/typingrobot.png'),
          ),
          const SizedBox(width: 10,),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: topBarTitleChildren,
          ),
        ],
      ),
    );

    List<Widget> children = [];

    children.add(topWidget);
    children.add(Container(
      height: 1,
      color: Colors.white24,
    ));

    Widget conversationArea;
    conversationArea = Expanded(
      child: Container(
        child: Center(
          child: Text('conversation area'),
        ),
      ),
    );

    children.add(conversationArea);

    children.add(Container(
      height: 1,
      color: Colors.white24,
    ));

    Widget bottomBar;
    bottomBar = Container(
      height: 59,
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: 200,
                height: 60,
                child: MacosTextField(
                  controller: humanMessageController,
                )),
          ),
          const SizedBox(width: 10,),
          NativeIconButton(icon: Icon(Icons.send), onPressed: sendEnabled ? () {} : null,),
          const SizedBox(width: 10,)
        ],
      ),
    );
    children.add(bottomBar);

    var body = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: children,
      ),
    );

    return body;
  }
}
