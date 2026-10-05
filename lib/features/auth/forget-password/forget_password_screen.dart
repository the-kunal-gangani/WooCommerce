import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Change your Password here"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TextField(
            controller: emailController,
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
