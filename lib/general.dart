import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: GeneralPage(),
  ));
}

class GeneralPage extends StatefulWidget {
  @override
  _GeneralPageState createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  List<dynamic> data = [];
  int _selectedChatIndex = -1;

  void _selectChat(int index) {
    setState(() {
      _selectedChatIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatIndex: index),
      ),
    ).then((value) {
      // Reset the selected chat index when returning from ChatScreen
      setState(() {
        _selectedChatIndex = -1;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Call the method to fetch data when the screen loads
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://localhost:3000/getUsers'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      setState(() {
        data = json.decode(response.body);
      });
      print(data);
    } else {
      // If the server did not return a 200 OK response, throw an exception
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(219, 35, 2, 93),
      appBar: AppBar(
        title: Text('General'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column for the list of chats
          Container(
            width: 80, // Width of the chat list
            color: Color.fromARGB(219, 35, 2, 93), // Background color for chat list
            child: ListView.builder(
              itemCount: 10, // Arbitrary number of elements
              itemBuilder: (context, index) {
                return ChatThumbnail(
                  index: index,
                  isSelected: index == _selectedChatIndex,
                  onSelect: _selectChat,
                ); // Each element is an interactive ChatThumbnail
              },
            ),
          ),
          // Column for the chat content
          Expanded(
            child: Container(
              color: Color.fromARGB(255, 90, 14, 161), // Background color for chat content
              child: Center(
                child: _selectedChatIndex == -1
                    ? Text('Select a chat to send a message.')
                    : ChatScreen(chatIndex: _selectedChatIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatThumbnail extends StatelessWidget {
  final int index;
  final bool isSelected;
  final Function(int) onSelect;

  const ChatThumbnail({
    Key? key,
    required this.index,
    required this.isSelected,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSelect(index);
      },
      child: Container(
        width: 50,
        height: 50,
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getColorForIndex(index), // Color based on index
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent, // Border color when selected
            width: isSelected ? 2 : 0, // Border width when selected
          ),
        ),
        child: Icon(Icons.connect_without_contact), // Placeholder for user icon
      ),
    );
  }

  Color _getColorForIndex(int index) {
    // List of colors for chat bubbles
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.red,
      Colors.yellow,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    // Use modulo operator to cycle through colors list
    return colors[index % colors.length];
  }
}

class ChatScreen extends StatefulWidget {
  final int chatIndex;

  const ChatScreen({Key? key, required this.chatIndex}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> _messages = [];
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          // Set the result to return when back button is pressed
          Navigator.pop(context, true);
          // Prevent back button from popping the route
          return false;
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_messages[index]),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _sendMessage();
                    },
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    String message = _textController.text;
    if (message.isNotEmpty) {
      setState(() {
        _messages.add(message);
        _textController.clear();
      });
    }
  }
}
