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
  List<dynamic> userLobbies = [];
  int _selectedChatIndex = -1;
  late String userEmail;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchUserEmail();
    initializeSocket();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://localhost:3000/getUsers'));

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    setState(() {
      userEmail = email!;
    });
    fetchUserLobbies(email!);
  }

  Future<void> fetchUserLobbies(String email) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/getUserLobbies'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'userId': email}),
    );

    if (response.statusCode == 200) {
      setState(() {
        userLobbies = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load user lobbies');
    }
  }

  void initializeSocket() async {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    socket.emit('login', email);
  }

  void joinLobby(String lobbyId) {
    socket.emit('join_lobby', lobbyId);
  }

  void _selectChat(int index) {
    setState(() {
      _selectedChatIndex = index;
    });

    final targetEmail = data[index]['email'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(targetEmail: targetEmail, socket: socket),
      ),
    ).then((value) {
      setState(() {
        _selectedChatIndex = -1;
      });
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
          Container(
            width: 80,
            color: Color.fromARGB(219, 35, 2, 93),
            child: Column(
              children: [
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 63, 1, 90),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                // Display user lobbies as color bubbles
                Expanded(
                  child: Column(
                    children: userLobbies.map((lobby) {
                      return GestureDetector(
                        onTap: () {
                          joinLobby(lobby['_id']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LobbyChatScreen(lobbyId: lobby['_id'], socket: socket),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue, // Replace with lobby color
                          ),
                          child: Center(
                            child: Text(
                              'L', // Example: Display 'L' for each lobby
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Color.fromARGB(255, 90, 14, 161),
              child: Column(
                children: [
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
                                  if (states.contains(MaterialState.pressed)) {
                                    return const Color.fromARGB(255, 255, 255, 255);
                                  }
                                  return Color.fromARGB(255, 67, 6, 105);
                                },
                              ),
                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(12)),
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.account_circle),
                                SizedBox(width: 8),
                                Text(data[index]['username']),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: _selectedChatIndex == -1 ? 0 : 8),
                  if (_selectedChatIndex == -1)
                    Expanded(
                      child: _selectedChatIndex == -1
                          ? Container()
                          : Center(
                              child: Container(),
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

class ChatScreen extends StatefulWidget {
  final String targetEmail;
  final IO.Socket socket;

  const ChatScreen({Key? key, required this.targetEmail, required this.socket}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> _messages = [];
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMessages();
    widget.socket.on('private_message', (data) {
      setState(() {
        _messages.add('${data['sender']}: ${data['message']}');
      });
    });
  }

  @override
  void dispose() {
    
    widget.socket.off('private_message');
    widget.socket.emit('logout');
    
    super.dispose();
  }

  Future<void> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final senderEmail = prefs.getString('email');

    final response = await http.post(
      Uri.parse('http://localhost:3000/getChat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'senderId': senderEmail,
        'receptorId': widget.targetEmail,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> messages = json.decode(response.body);
      messages.sort((a, b) {
        final int timestampA = DateTime.parse(a['createdAt']).millisecondsSinceEpoch;
        final int timestampB = DateTime.parse(b['createdAt']).millisecondsSinceEpoch;
        return timestampA - timestampB;
      });

      setState(() {
        _messages.clear();
        _messages.addAll(messages.map((message) => '${message['senderId']}: ${message['content']}'));
      });
    } else {
      print('Failed to fetch messages: ${response.statusCode}');
    }
  }

  void _sendMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final senderEmail = prefs.getString('email');
    String message = _textController.text;
    if (message.isNotEmpty) {
      widget.socket.emit('private_message', {
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

class LobbyChatScreen extends StatefulWidget {
  final String lobbyId;
  final IO.Socket socket;

  const LobbyChatScreen({Key? key, required this.lobbyId, required this.socket}) : super(key: key);

  @override
  _LobbyChatScreenState createState() => _LobbyChatScreenState();
}

class _LobbyChatScreenState extends State<LobbyChatScreen> {
  List<String> _messages = [];
  TextEditingController _textController = TextEditingController();
  late String userEmail;

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    widget.socket.on('lobby_message', (data) {
      setState(() {
        // Check if the sender is not the current user before adding the message
        if (data['sender'] != userEmail) {
          _messages.add('${data['sender']}: ${data['message']}');
        }
      });
    });
    joinLobby(widget.lobbyId);
  }

  Future<void> fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    setState(() {
      userEmail = email!;
    });
  }

  @override
  void dispose() {
    widget.socket.off('lobby_message');
    super.dispose();
  }

  void joinLobby(String lobbyId) {
    widget.socket.emit('join_lobby', lobbyId);
  }

  void _sendMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final senderEmail = prefs.getString('email');
    String message = _textController.text;
    if (message.isNotEmpty) {
      widget.socket.emit('lobby_message', {
        'sender': senderEmail,
        'message': message,
        'lobbyId': widget.lobbyId,
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
        title: Text('Lobby Chat'),
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