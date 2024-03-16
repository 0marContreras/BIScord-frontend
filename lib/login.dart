import 'package:flutter/material.dart';
import 'general.dart'; // Importa la página principal
import 'register.dart'; // Importa la página de registro


class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño mínimo permitido para el contenedor, investigar como definir dimensiones para movil sepradas de web
    final double minContainerWidth = MediaQuery.of(context).size.width * 0.5;
    final double minContainerHeight = MediaQuery.of(context).size.height * 0.6;
    return Scaffold(
      backgroundColor: Color(0xFF2C2F33),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8, // Utiliza el 70% del ancho disponible,
          height: MediaQuery.of(context).size.height * 0.7, 
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(minWidth: minContainerWidth, minHeight: minContainerHeight,), // Establecer el ancho mínimo del contenedor
          decoration: BoxDecoration(
            color: Color(0xFF40444B), 
            borderRadius: BorderRadius.circular(10), 
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5), // Color y opacidad de la sombra
                spreadRadius: 2, // El radio de extensión de la sombra
                blurRadius: 5, // El radio de desenfoque de la sombra
                offset: Offset(0, 3), // La distancia de desplazamiento de la sombra
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 600, 
                child: TextField(
                  controller: emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white60),
                    fillColor: Color(0xFF40444B),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 600,
                child: TextField(
                  controller: passwordController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.white60),
                    fillColor: Color(0xFF40444B),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 250, 
                child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor:  Colors.green,),
                  onPressed: () {
                    // Supongamos que la autenticación es exitosa
                    // Navega a la página principal, general
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => GeneralPage()),
                      result: false, // Esto indica que esta ruta no es un resultado
                    );
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
                  'Register',
                  style: TextStyle(color: Colors.blue.shade600,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
