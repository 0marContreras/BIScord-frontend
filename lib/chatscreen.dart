import 'package:flutter/material.dart';

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
  final List<ChatMessage> _messages = [];
  final FocusNode _focusNode = FocusNode(); // Define FocusNode

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose(); // Dispose the FocusNode
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.isNotEmpty) { // Check if the text is not empty
      _textController.clear();
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: text,
          ),
        );
      });
      _focusNode.requestFocus(); // Keep focus on the text input field
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF422674), // Customizing app bar color
        title: Text(
          'Chat',
          textAlign: TextAlign.center, // Centering the text within the app bar
        ),
        centerTitle: true, // Centering the title within the app bar
      ),
      body: Container(
        color: Color.fromARGB(255, 44, 3, 56),
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (_, int index) => _messages[index],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Color(0xFF230559), // Customizing input container color
                borderRadius: BorderRadius.circular(20.0), // Adding rounded corners
              ),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      focusNode: _focusNode, // Assign the FocusNode
                      controller: _textController,
                      onSubmitted: _handleSubmitted,
                      decoration: InputDecoration(
                        hintText: 'Send a message',
                        hintStyle: TextStyle(color: Colors.white), // Customizing hint text color
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      style: TextStyle(color: Colors.white), // Customizing text input color
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => _handleSubmitted(_textController.text),
                    color: Colors.white, // Customizing icon color
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;

  ChatMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFF5A11A1), // Customizing avatar color
              child: Text('User'), // You can replace this with user avatar
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'User Name', // You can replace this with user name
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Customizing user name color
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5.0),
                  child: Text(
                    text,
                    style: TextStyle(color: Colors.white), // Customizing message text color
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