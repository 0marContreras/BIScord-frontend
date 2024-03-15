
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textcontroller = TextEditingController();
  final List<String> messages = <String>[];
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
        messages.add(data);
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
    if (textcontroller.text.isNotEmpty) {
      socket.emit("message", textcontroller.text);
      textcontroller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade200,
        appBar: AppBar(title: const Text("VsCord"),
        backgroundColor: Colors.deepPurple,),
        body: Column(
          
          children: <Widget>[
            Expanded(
                child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            )),
            Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child:
                         TextField(
                          
                            onSubmitted: (value)=> sendMessage(),
                            controller: textcontroller,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                                
                                hintText: "send message",
                                hintStyle: TextStyle(
                                  color: Colors.black,
                                ),
                                filled: true, 
                                fillColor: Colors.deepPurple.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                
                                ))),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple.shade800,
                        backgroundColor: Colors.deepPurple.shade500
                      ),
                      onPressed: sendMessage,
                      child: const Text('Send'),
                    )
                  ],
                ))
          ],
        ));
  }
}
