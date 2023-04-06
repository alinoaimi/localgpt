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
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(conversation['engine']),
                const SizedBox(height: 5,),
                Container(
                  width: 180,
                  child: Text(
                    conversation['last_message'] == null
                        ? ''
                        : conversation['last_message']['text'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryTextTheme.bodySmall?.color,
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.red,
                  height: 1,
                ),
              ],
            )
          ],
        ),
      ),
    );

    return body;
  }
}
