import 'package:flutter/material.dart';

class GeneralPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('General'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna para la lista de chats
          Container(
            width: 200, // Ancho de la lista de chats
            color: Colors.grey[200],
            child: ListView.builder(
              itemCount: 10, // Número arbitrario de elementos
              itemBuilder: (context, index) {
                return ChatItem(index: index); // Cada elemento es un ChatItem interactivo
              },
            ),
          ),
          // Columna para el contenido del chat
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Text('Contenido del Chat'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navega de regreso a la página de inicio de sesión
          Navigator.pop(context);
        },
        child: Icon(Icons.logout),
      ),
    );
  }
}

class ChatItem extends StatefulWidget {
  final int index;

  const ChatItem({Key? key, required this.index}) : super(key: key);

  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded; // Cambia el estado al hacer clic
        });
      },
      child: Container(
        padding: EdgeInsets.all(10),
        color: isExpanded ? Colors.blue[100] : null, // Color de fondo cuando se expande
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chat ${widget.index}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (isExpanded) // Muestra el contenido del chat solo si está expandido
              Expanded(
                child: Stack(
                  children: [
                    // Contenido del chat
                    Container(
                      color: Colors.white,
                      child: Center(
                        child: Text('Contenido del Chat ${widget.index}'),
                      ),
                    ),
                    // Botón para cerrar el chat
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            isExpanded = false; // Cerrar el chat al presionar el botón
                          });
                        },
                        icon: Icon(Icons.close),
                      ),
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
