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
    socket.on('new_lobby', (lobby) {
      setState(() {
        userLobbies.add(lobby);
      });
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
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Seleccionar acción"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context); // Cerrar el diálogo
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CreateLobbyDialog(socket: socket);
                                    },
                                  ).then((value) {
                                    if (value == true) {
                                      // Si se creó el lobby, actualizar la lista de lobbies del usuario
                                      fetchUserLobbies(userEmail);
                                    }
                                  });
                                },
                                child: Text("Crear"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context); // Cerrar el diálogo
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return JoinLobbyDialog(socket: socket);
                                    },
                                  ).then((value) {
                                    if (value == true) {
                                      // Si se unió al lobby, actualizar la lista de lobbies del usuario
                                      fetchUserLobbies(userEmail);
                                    }
                                  });
                                },
                                child: Text("Unirse"),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
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
                      child: _selectedChatIndex == -1 ? Container() : Center(child: Container()),
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

class CreateLobbyDialog extends StatefulWidget {
  final IO.Socket socket;
  const CreateLobbyDialog({Key? key, required this.socket}) : super(key: key);

  @override
  _CreateLobbyDialogState createState() => _CreateLobbyDialogState();
}

class _CreateLobbyDialogState extends State<CreateLobbyDialog> {
  TextEditingController _lobbyNameController = TextEditingController();

  Future<bool> _createLobby() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('email');
    final response = await http.post(
      Uri.parse('http://localhost:3000/createLobby'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'lobbyName': _lobbyNameController.text,
        'memberIds': [userEmail], // Agregar al usuario como miembro del lobby
      }),
    );
    if (response.statusCode == 200) {
      // Lobby creado exitosamente
      Navigator.pop(context, true); // Cerrar el diálogo de creación de lobby y notificar que se creó correctamente
      return true;
    } else {
      // Falló la creación del lobby
      print('Failed to create lobby: ${response.statusCode}');
      // Podrías mostrar un mensaje de error al usuario aquí
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Crear Lobby"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _lobbyNameController,
            decoration: InputDecoration(
              labelText: 'Nombre del lobby',
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _createLobby().then((value) => Navigator.pop(context, value)),
            child: Text("Crear Lobby"),
          ),
        ],
      ),
    );
  }
}

class JoinLobbyDialog extends StatefulWidget {
  final IO.Socket socket;
  const JoinLobbyDialog({Key? key, required this.socket}) : super(key: key);

  @override
  _JoinLobbyDialogState createState() => _JoinLobbyDialogState();
}

class _JoinLobbyDialogState extends State<JoinLobbyDialog> {
  TextEditingController _lobbyNameController = TextEditingController();

  Future<bool> _joinLobby() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('email');
    final response = await http.post(
      Uri.parse('http://localhost:3000/joinLobby'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'lobbyName': _lobbyNameController.text,
        'userEmail': userEmail,
      }),
    );
    if (response.statusCode == 200) {
      // Usuario unido al lobby exitosamente
      Navigator.pop(context, true); // Cerrar el diálogo de unirse al lobby y notificar que se unió correctamente
      return true;
    } else {
      // Falló al unirse al lobby
      print('Failed to join lobby: ${response.statusCode}');
      // Podrías mostrar un mensaje de error al usuario aquí
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Unirse a Lobby"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _lobbyNameController,
            decoration: InputDecoration(
              labelText: 'Nombre del lobby',
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _joinLobby().then((value) => Navigator.pop(context, value)),
            child: Text("Unirse al Lobby"),
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
    //widget.socket.emit('logout');
    
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
      // messages.sort((a, b) {
      //   final int timestampA = DateTime.parse(a['createdAt']).millisecondsSinceEpoch;
      //   final int timestampB = DateTime.parse(b['createdAt']).millisecondsSinceEpoch;
      //   return timestampA - timestampB;
      // });

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
    joinLobby(widget.lobbyId);
    fetchLobbyMessages(widget.lobbyId);
    widget.socket.on('lobby_message', (data) {
      setState(() {
        // Check if the sender is not the current user before adding the message
        if (data['sender'] != userEmail) {
          _messages.add('${data['sender']}: ${data['message']}');
        }
      });
    });
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

   Future<void> fetchLobbyMessages(String lobbyId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/getLobbyMessages'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'lobbyId': lobbyId}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messages = json.decode(response.body);
        setState(() {
          _messages.addAll(messages.map((message) => '${message['senderId']}: ${message['content']}'));
        });
      } else {
        print('Failed to fetch lobby messages: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to fetch lobby messages: $error');
    }
  }

  void _sendMessage() async {
    String message = _textController.text;
    if (message.isNotEmpty) {
      widget.socket.emit('lobby_message', {
        'lobbyId': widget.lobbyId,
        'sender': userEmail,
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
