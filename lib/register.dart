import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController userController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C2F33),
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Center(
        child:Container(
          width: MediaQuery.of(context).size.width* 0.5,
          height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF40444B),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0,3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: userController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'User Name',
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Color(0xFF40444B),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: emailController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Color(0xFF40444B),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: confirmEmailController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Confirm Email',
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Color(0xFF40444B),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Color(0xFF40444B),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Confirm Password',
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Color(0xFF40444B),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  String user = userController.text;
                  String email = emailController.text;
                  String confirmEmail = confirmEmailController.text;
                  String password = passwordController.text;
                  String confirmPassword = confirmPasswordController.text;
                  
                  // Implementa la lógica de registro aquí
                  print('User: $user, Email: $email, Confirm Email: $confirmEmail, Password: $password, Confirm Password: $confirmPassword');
                },
                child: Text('Register'),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
