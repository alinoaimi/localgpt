import 'package:flutter/material.dart';

class ConversationListItem extends StatelessWidget {

  dynamic conversation;

  ConversationListItem({Key? key, this.conversation}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Widget body;

    body = Container(
      width: 250,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/typingrobot.png'),
            ),
            SizedBox(width: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('GPT4all'),
                const Text('last message', style: TextStyle(fontSize: 12, color: Colors.white54),),
               const Divider(color: Colors.red, height: 1,),
              ],
            )
          ],
        ),
      ),
    );

    return body;
  }
}
