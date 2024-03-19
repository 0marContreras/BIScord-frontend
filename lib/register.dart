import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';


class RegisterPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController userController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(219, 35, 2, 93),
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color.fromARGB(219, 35, 2, 93),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
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
              const SizedBox(height: 20), // Espacio adicional
              Container(
                width: 400,
                height: 50,
                child: TextField(
                  controller: userController,
                  style: TextStyle(color: Color.fromARGB(255, 21, 21, 21)),
                  decoration: InputDecoration(
                    hintText: 'User name',
                    hintStyle: TextStyle(
                        color: const Color.fromARGB(153, 107, 107, 107)),
                    fillColor: Color.fromARGB(255, 255, 255, 255),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),

              
              TextField(
                controller: emailController,
                style: TextStyle(color: const Color.fromARGB(255, 17, 17, 17)),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(
                      color: const Color.fromARGB(153, 107, 107, 107)),
                  fillColor: Color.fromARGB(255, 255, 255, 255),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20,),
              TextField(
                controller: passwordController,
                style: TextStyle(color: const Color.fromARGB(255, 17, 17, 17)),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(
                      color: const Color.fromARGB(153, 107, 107, 107)),
                  fillColor: Color.fromARGB(255, 255, 255, 255),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20,),

              SizedBox(
                width: 400,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 90, 14, 161)),
                  onPressed: () async {
  String username = userController.text;
  String email = emailController.text;
  String password = passwordController.text;

  final url = Uri.parse('http://localhost:3000/createUser');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username': username,
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 201) {
    // Registration successful
    // Redirect to the login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  } else {
    // Registration failed
    // Handle failure as needed
    print('Registration failed');
  }
},
                  child: Text('Register',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
