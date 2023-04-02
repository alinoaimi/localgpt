import 'package:flutter/material.dart';
import 'package:localgptflutter/always-native/widgets/NativeButton.dart';

class ConversationPlaceholder extends StatelessWidget {
  const ConversationPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget body;

    body = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text('Select a conversation from the left'),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );

    return body;
  }
}
