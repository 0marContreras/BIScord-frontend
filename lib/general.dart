

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
  int _selectedChatIndex = -1;

  void _selectChat(int index) {
    setState(() {
      _selectedChatIndex = index;
    });
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
            width: 200, // Width of the chat list
            color: Color.fromARGB(219, 35, 2, 93), // Background color for chat list
            child: ListView.builder(
              itemCount: 10, // Arbitrary number of elements
              itemBuilder: (context, index) {
                return ChatItem(
                  index: index,
                  isSelected: index == _selectedChatIndex,
                  onSelect: _selectChat,
                ); // Each element is an interactive ChatItem
              },
            ),
          ),
          // Column for the chat content
          Expanded(
            child: Container(
              color: Color.fromARGB(255, 90, 14, 161), // Background color for chat content
              child: Center(
                child: Text('Contenido del Chat'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedChatIndex != -1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  chatIndex: _selectedChatIndex,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Select a chat to send a message.'),
              ),
            );
          }
        },
        child: Icon(Icons.send),
      ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final int chatIndex;

  const ChatDetailScreen({Key? key, required this.chatIndex}) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  List<String> _messages = <String>[];
  final TextEditingController _textController = TextEditingController();
  late IO.Socket socket;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    socket = IO.io("http://localhost:3000", <String, dynamic>{
      "transports": ['websocket'],
      "autoConnect": false,
    });

    socket.connect();
    socket.on("message", (data) {
      setState(() {
        _messages.add(data);
      });
    });
  }

    @override
  void dispose() {
    socket.dispose();
    super.dispose();
    _focusNode.dispose();
  }

  void sendMessage() {
    if (_textController.text.isNotEmpty) {
      socket.emit("message", _textController.text);
      _textController.clear();
      _focusNode.requestFocus();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade200,
      appBar: AppBar(
        title: Text('Chat ${widget.chatIndex}'),
        backgroundColor: Colors.purple.shade800,
      ),
      body: Column(
        
        children: [
          
          Expanded(
            
            child: ListView.builder(
              
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: _messages[index].startsWith('You:') ? Colors.orange.shade500 : Colors.white, // You can customize colors here
                        borderRadius: BorderRadius.circular(12.0), // You can adjust the radius to make it more or less rounded
                      ),
                      child: Text(
                        _messages[index],
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
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
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Type a message...',
                      
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    sendMessage();
                  },
                  icon: Icon(Icons.send),
                  color: Colors.purple.shade800,
                  
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    String message = 'you: '+ _textController.text;
    if (message.isNotEmpty) {
      setState(() {
        _messages.add(message);
        _textController.clear();
      });
    }
  }
}

class ChatItem extends StatelessWidget {
  final int index;
  final bool isSelected;
  final Function(int) onSelect;

  const ChatItem({
    Key? key,
    required this.index,
    required this.isSelected,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onSelect(index);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        color: isSelected ? Color.fromARGB(255, 26, 0, 51) : null, // Color when selected
        child: Text(
          'Chat $index',
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: Colors.white, // Text color
          ),
        ),
      ),
    );
  }
}