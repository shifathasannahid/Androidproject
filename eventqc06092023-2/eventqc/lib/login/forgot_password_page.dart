import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final TextEditingController emailController = TextEditingController();
  bool emailValidate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Forgot Password"
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 30,),
          const Center(
            child: Text(
              "Forgot your password?",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10,),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Enter your email address on which you can be contacted.\nWe will send a password reset link with which you can reset your password.",
              style: TextStyle(
                color: Color(0xff707071),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.fromLTRB(20,0,20,0),
            child: SizedBox(
              width: (MediaQuery.of(context).size.width) - 20,
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email address",
                  hintText: "Enter your email address",
                  errorText: emailValidate? "Enter a valid email address" : null,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40,),

          TextButton(
            onPressed: () async{
              if(emailController.text.trim().isNotEmpty && emailController.text.contains("@") && emailController.text.contains(".") && !emailController.text.trim().contains(" ")){
                emailValidate = false;
                setState((){

                });

                await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim()).whenComplete(() => Fluttertoast.showToast(msg: "Email sent.\nPlease check your email inbox / spam.")).whenComplete(() => Navigator.pop(context));

              }
              else{
                emailValidate = true;
                setState((){

                });
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Submit email',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
