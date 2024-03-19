import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: Text('General'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column for the list of chats
          Container(
            width: 200, // Width of the chat list
            color: Color(0xFF2C2F33), // Background color for chat list
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
              color: Color(0xFF2C2F33), // Background color for chat content
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
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  List<String> _messages = [];
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat ${widget.chatIndex}'),
      ),
      body: Column(
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
        color: isSelected ? Colors.blue[100] : null, // Color when selected
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
