import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primaryColor: Colors.blue, // You can change this to fit your design
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  // Example list of channels fetched from the database
  List<String> _channels = [
    'Channel 1',
    'Channel 2',
    'Channel 3',
    'Channel 4',
    'Channel 5',
    'Channel 6',
    'General',
  ];

  // Index of the currently selected channel
  int _selectedChannelIndex = 0;

  // Example list of messages for each channel
  List<List<ChatMessage>> _messages = [
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
  ];

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _messages[_selectedChannelIndex].insert(
        0,
        ChatMessage(
          text: text,
          isSentByCurrentUser: true, // Indicate that the message was sent by the current user
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        backgroundColor: const Color.fromARGB(153, 107, 107, 107),
      ),
      body: Row(
        children: <Widget>[
          // List of channels
          Container(
            width: 300,
            height: 900,
            color: const Color.fromARGB(153, 107, 107, 107),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _channels.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _channels[index],
                    style: TextStyle(
                      fontWeight: _selectedChannelIndex == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedChannelIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          // Chat messages
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: <Widget>[
                  Flexible(
                    child: ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      reverse: true,
                      itemCount: _messages[_selectedChannelIndex].length,
                      itemBuilder: (_, int index) =>
                          _messages[_selectedChannelIndex][index],
                    ),
                  ),
                  Divider(
                    height: 0.1,
                  ),
                  // Input field for sending messages
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                    ),
                    child: _buildTextComposer(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    final focusNode = FocusNode();

    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 2.0,
          vertical: 4.0,
        ),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                focusNode: focusNode,
                decoration: InputDecoration.collapsed(
                  hintText: 'Send a message',
                ),
                onSubmitted: (text) {
                  if (text.isNotEmpty) {
                    _handleSubmitted(text);
                    _textController.clear();
                  }
                  // Request focus again to enable typing after sending a message
                  FocusScope.of(context).requestFocus(focusNode);
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              color: Colors.white,
              tooltip: 'Send',
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  _handleSubmitted(_textController.text);
                  _textController.clear();
                  // Request focus again to enable typing after sending a message
                  FocusScope.of(context).requestFocus(focusNode);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isSentByCurrentUser;

  ChatMessage({
    required this.text,
    this.isSentByCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: isSentByCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: isSentByCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'User Name', // You can replace this with user name
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5.0),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSentByCurrentUser
                        ? Colors.purple.shade800
                        : Colors.grey[300], // Adjust the background color based on the sender
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isSentByCurrentUser
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
