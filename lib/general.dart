import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<dynamic> data = [];
  int _selectedChatIndex = -1;

  void _selectChat(int index) async {
    setState(() {
      _selectedChatIndex = index;
    });

    // Get the target email from the selected chat
    final targetEmail = data[index]['email'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(targetEmail: targetEmail),
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
                  chatIcon: Icons.connect_without_contact, // Icon for chat thumbnails
                ); // Each element is an interactive ChatThumbnail
              },
            ),
          ),
          // Column for the chat content
          Expanded(
            child: Container(
              color: Color.fromARGB(255, 90, 14, 161), // Background color for chat content
              child: Column(
                children: [
                  // List of users as buttons
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: TextButton(
                            onPressed: () {
                              _selectChat(index);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                  // Set the background color of the button
                                  if (states.contains(MaterialState.pressed)) {
                                    return const Color.fromARGB(255, 255, 255, 255); // Color when pressed
                                  }
                                  return Color.fromARGB(255, 67, 6, 105); // Default color
                                },
                              ),
                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Text color
                              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(12)), // Padding
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                              ), // Shape of the button
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.account_circle), // Icon for users
                                SizedBox(width: 8), // Space between icon and text
                                Text(data[index]['username']), // Text
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _selectedChatIndex == -1
                          ? Text('Select a chat to send a message.')
                          : Container(), // Chat screen will be displayed here
                    ),
                  ),
                ],
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
  final IconData chatIcon;

  const ChatThumbnail({
    Key? key,
    required this.index,
    required this.isSelected,
    required this.onSelect,
    required this.chatIcon,
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
            color: isSelected ? Color.fromARGB(255, 255, 255, 255) : Colors.transparent, // Border color when selected
            width: isSelected ? 2 : 0, // Border width when selected
          ),
        ),
        child: Icon(chatIcon), // Icon for chat thumbnails
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
  final String targetEmail;

  const ChatScreen({Key? key, required this.targetEmail}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  List<String> _messages = [];
  TextEditingController _textController = TextEditingController();
  
 void initState() {
  SharedPreferences.getInstance().then((prefs) {
    final senderEmail = prefs.getString('email');
    fetchMessages();

    // Establish socket connection
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
    // Emit login event with user's email
    socket.emit('login', senderEmail);
    // Listen for private messages
    socket.on('private_message', (data) {
      setState(() {
        _messages.add('${data['sender']}: ${data['message']}');
      });
    });
    // Fetch messages from the server
    
  });

  super.initState();
}

  @override
  void dispose() {
    socket.emit('logout');
    socket.disconnect();
    super.dispose();
  }

  Future<void> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final senderEmail = prefs.getString('email');

    // Perform HTTP request to fetch messages from the server
    final response = await http.post(
      Uri.parse('http://localhost:3000/getChat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'senderId': senderEmail, // Replace with the actual sender email
        'receptorId': widget.targetEmail,
      }),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON and update the messages list
      final List<dynamic> messages = json.decode(response.body);
      setState(() {
        _messages.addAll(messages.map((message) => '${message['senderId']}: ${message['content']}'));
      });
    } else {
      // Handle errors if needed
      print('Failed to fetch messages: ${response.statusCode}');
    }
  }

  void _sendMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final senderEmail = prefs.getString('email');
    String message = _textController.text;
    if (message.isNotEmpty) {
      // Emit private_message event
      socket.emit('private_message', {
        'sender': senderEmail,
        'receptor': widget.targetEmail,
        'message': message,
      });
      setState(() {
        _messages.add('Me: $message');
        _textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
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
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}