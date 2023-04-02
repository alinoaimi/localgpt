import 'package:flutter/material.dart';
import 'package:localgptflutter/widgets/ConversationPlaceholder.dart';
import 'package:localgptflutter/widgets/ConversationWidget.dart';
import 'package:localgptflutter/widgets/ConversationsList.dart';

class ConversationsWidget extends StatefulWidget {
  const ConversationsWidget({Key? key}) : super(key: key);

  @override
  State<ConversationsWidget> createState() => _ConversationsWidgetState();
}

class _ConversationsWidgetState extends State<ConversationsWidget> {

  int? selectedConversationId;

  @override
  Widget build(BuildContext context) {

    final currentWidth = MediaQuery.of(context).size.width;

    Widget body;

    Widget conversationArea;

    if(selectedConversationId == null) {
      conversationArea = const ConversationPlaceholder();
    } else {
      conversationArea = ConversationWidget(conversationId: selectedConversationId!);
    }

    var mobileBody = const ConversationPlaceholder();

    var desktopBody = Row(
      children: [
        ConversationsList(onConversationSelected: (conversationId) {
          selectedConversationId = conversationId;
          setState(() {

          });
        },),
        const VerticalDivider(color: Colors.white24,indent: 0, endIndent: 0, width: 1,),
        Expanded(child: conversationArea)
      ],
    );

    if(currentWidth < 500) {
      return mobileBody;
    }

    return desktopBody;
  }
}
