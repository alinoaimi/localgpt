import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localgptflutter/always-native/widgets/NativeButton.dart';
import 'package:localgptflutter/always-native/widgets/NativeCircularProgressIndicator.dart';
import 'package:localgptflutter/always-native/widgets/NativeIconButton.dart';
import 'package:localgptflutter/data/settings.dart';
import 'package:localgptflutter/networking/CustomDio.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_platform_alert/flutter_platform_alert.dart';


class ConversationWidget extends StatefulWidget {
  int conversationId;

  ConversationWidget({Key? key, required this.conversationId})
      : super(key: key);

  @override
  State<ConversationWidget> createState() => _ConversationWidgetState();
}

class _ConversationWidgetState extends State<ConversationWidget> {
  TextEditingController humanMessageController = TextEditingController();
  bool sendEnabled = false;
  String? conversationStatus;

  bool isConversationLoading = true;
  dynamic? conversation;
  List<dynamic> messages = [];
  String? computerTypingMessage;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();

    // Dart client

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
    socket.on('event', (data) {
      debugPrint('received sockets event');
      debugPrint(data);
    });
    socket.on('test', (data) {
      debugPrint('received sockets event');
      debugPrint(data);
    });
    socket.on('conversation_${widget.conversationId}_status', (data) {
      debugPrint(
          'received sockets event: conversation_${widget.conversationId}_status');
      debugPrint(data);
      if (data == '{START_TYPING}') {
        conversationStatus = 'typing...';
      } else if (data == 'booting_engine') {
        conversationStatus = 'Booting the engine, may take some time...';
      } else if (data == 'engine_booted') {
        conversationStatus = 'Engine is ready, you may send a message.';
      } else {
        conversationStatus = null;
        computerTypingMessage = null;
      }

      setState(() {});
    });
    socket.on('conversation_${widget.conversationId}_typing', (data) {
      debugPrint(
          'received sockets event: conversation_${widget.conversationId}_status');
      debugPrint(data);
      conversationStatus = 'typing...';
      computerTypingMessage = data;

      setState(() {});
    });

    socket.on('conversation_${widget.conversationId}_new_message', (data) {
      debugPrint(
          'received sockets event: conversation_${widget.conversationId}_new_message');
      debugPrint(data.toString());

      messages.add(data);
      computerTypingMessage = null;
      sendEnabled = true;
      setState(() {});
    });

    socket.onDisconnect((_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));
    socket.onError((data) => {debugPrint(data.toString())});

    loadConversation();
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

  loadConversation() async {
    try {
      var req =
          await CustomDio().get('/conversations/${widget.conversationId}');

      if (req.data['id'] != null) {
        conversation = req.data;
        loadMessages();
        setState(() {});
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  loadMessages() async {
    try {
      var req = await CustomDio().get(
          '/messages/?filter[conversation_id]=${widget.conversationId}&sort[]=id,asc');

      if (req.data != null) {
        messages = req.data;
        isConversationLoading = false;
        sendEnabled = true;

        setState(() {});
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  sendMessage() async {

    if(humanMessageController.text.isEmpty) {
      FlutterPlatformAlert.showAlert(
        windowTitle: 'empty message',
        text: 'type something',
        alertStyle: AlertButtonStyle.ok,
        iconStyle: IconStyle.none
      );
      return;
    }

    sendEnabled = false;
    setState(() {});


    try {
      var req = await CustomDio().post('/messages', data: {
        'conversation_id': widget.conversationId,
        'text': humanMessageController.text,
        'author': 'human'
      });
      humanMessageController.text = '';
      setState(() {});

      if (req.data != null && req.data['message_id'] != null) {}
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> topBarTitleChildren = [];
    topBarTitleChildren
        .add(Text(conversation == null ? 'loading' : conversation['engine']));
    topBarTitleChildren.add(const SizedBox(
      height: 3,
    ));
    if (conversationStatus != null && conversationStatus != '') {
      topBarTitleChildren.add(Text(
        conversationStatus!,
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ));
    }

    var topWidget = Container(
      height: 60,
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          const CircleAvatar(
            backgroundImage: AssetImage('assets/images/typingrobot.png'),
          ),
          const SizedBox(
            width: 10,
          ),
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
      color: Theme.of(context).dividerColor,
    ));

    Widget conversationArea;
    if (isConversationLoading) {
      conversationArea = Expanded(
          child: Center(
        child: NativeCircularProgressIndicator(
          width: 10,
        ),
      ));
    } else {
      List<Widget> messageBubbles = [];

      messageBubbles.add(SizedBox(
        height: 20,
      ));

      for (var message in messages) {
        Widget bubboola = BubbleSpecialTwo(
          isSender: message['author'] == 'human',
          text: message['text'],
          color: message['author'] == 'human' ? Color(0xFF1B97F3) : Colors.grey,
          tail: true,
          textStyle: TextStyle(
              color: message['author'] == 'human' ? Colors.black : Colors.black,
              fontSize: 16),
        );
        messageBubbles.add(bubboola);

        messageBubbles.add(SizedBox(
          height: 10,
        ));
      }

      if (computerTypingMessage != null) {
        Widget typingBubboola = BubbleSpecialThree(
          isSender: false,
          text: (computerTypingMessage == null ? '' : computerTypingMessage)!,
          color: Color(0xFFA0A0A0),
          tail: false,
          textStyle: TextStyle(color: Colors.white, fontSize: 16),
        );
        messageBubbles.add(typingBubboola);
      }

      messageBubbles.add(SizedBox(
        height: 20,
      ));

      conversationArea = Expanded(
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            children: messageBubbles,
          ),
        ),
      );
    }

    children.add(conversationArea);

    children.add(Container(
      height: 1,
      color: Theme.of(context).dividerColor,
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
          const SizedBox(
            width: 10,
          ),
          NativeIconButton(
            icon: Icon(Icons.send),
            onPressed: sendEnabled
                ? () {
                    sendMessage();
                  }
                : null,
          ),
          const SizedBox(
            width: 10,
          )
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
