import 'dart:convert';

import 'package:flutter/material.dart';
import 'general.dart'; // Importa la página principal
import 'register.dart'; // Importa la página de registro
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño mínimo permitido para el contenedor, investigar como definir dimensiones para movil sepradas de web
    final double minContainerWidth = MediaQuery.of(context).size.width * 0.5;
    final double minContainerHeight = MediaQuery.of(context).size.height * 0.6;
    return Scaffold(
      backgroundColor: Color.fromARGB(219, 35, 2, 93),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width *
              0.8, // Utiliza el 70% del ancho disponible,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            minWidth: minContainerWidth,
            minHeight: minContainerHeight,
          ), // Establecer el ancho mínimo del contenedor
          decoration: BoxDecoration(
            color: Color.fromARGB(219, 35, 2, 93),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.5), // Color y opacidad de la sombra
                spreadRadius: 2, // El radio de extensión de la sombra
                blurRadius: 5, // El radio de desenfoque de la sombra
                offset:
                    Offset(0, 3), // La distancia de desplazamiento de la sombra
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                            // Aquí está la imagen
              Image.asset(
                'assets/LogoBiscord.jpeg', // Ruta de la imagen en tus activos
                width: 70, // Ancho deseado de la imagen
                height: 70, // Alto deseado de la imagen
                fit: BoxFit.cover, // Ajuste de la imagen dentro del contenedor
              ),
              const SizedBox(height: 40), // Espacio adicional
              Container(
                width: 400,
                height: 50,
                child: TextField(
                  controller: emailController,
                  style: TextStyle(color: Color.fromARGB(255, 21, 21, 21)),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Color.fromARGB(153, 107, 107, 107)),
                    fillColor: Color.fromARGB(255, 255, 255, 255),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 400,
                height: 50,
                child: TextField(
                  controller: passwordController,
                  style: TextStyle(color: Color.fromARGB(255, 21, 21, 21)),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Color.fromARGB(153, 107, 107, 107)),
                    fillColor: Color.fromARGB(255, 255, 255, 255),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 400,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 90, 14, 161),
                  ),
                  onPressed: () async {
                    final email = emailController.text;
                    final password = passwordController.text;

                    final url = Uri.parse('http://localhost:3000/authUser');
                    final response = await http.post(
                      url,
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(<String, String>{
                        'email': email,
                        'password': password,
                      }),
                    );

                    if (response.statusCode == 200) {
                      // Parse the response body
                      final Map<String, dynamic> responseData =
                          json.decode(response.body);

                      // Save response data to local storage
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString('userId', responseData['_id']);
                      prefs.setString('username', responseData['username']);
                      prefs.setString('email', responseData['email']);
                      prefs.setString('password', responseData['password']);
                      prefs.setString('createdAt', responseData['createdAt']);
                      prefs.setString('updatedAt', responseData['updatedAt']);

                      //DEBUG---------------------------------------
                      void retrieveAndDisplayData() async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        // Retrieve data from local storage
                        String userId = prefs.getString('userId') ?? '';
                        String username = prefs.getString('username') ?? '';
                        String email = prefs.getString('email') ?? '';
                        String password = prefs.getString('password') ?? '';
                        String createdAt = prefs.getString('createdAt') ?? '';
                        String updatedAt = prefs.getString('updatedAt') ?? '';

                        // Display data in the console
                        print('User ID: $userId');
                        print('Username: $username');
                        print('Email: $email');
                        print('Password: $password');
                        print('Created At: $createdAt');
                        print('Updated At: $updatedAt');
                      }
                      //DEBUG---------------------------------------

// Call the function to retrieve and display data
                      retrieveAndDisplayData();

                      // Assuming successful authentication
                      // Navigate to the general page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => GeneralPage()),
                        result:
                            false, // Indicates that this route is not a result
                      );
                    } else {
                      // Handle authentication failure
                      // For example, show an error message
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Authentication Failed'),
                            content: Text('Invalid email or password.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Navega a la página de registro
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text(
                  'If you have not register yet click here',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
