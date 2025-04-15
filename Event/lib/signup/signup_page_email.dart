import 'package:eventqc/signup/signup_page_email_verification.dart';
import 'package:eventqc/signup/signup_page_password.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';

class SignupPageEmail extends StatefulWidget {
  final UserBasicInfo userBasicInfo;
  const SignupPageEmail({Key? key, required this.userBasicInfo}) : super(key: key);

  @override
  _SignupPageEmailState createState() => _SignupPageEmailState();
}

class _SignupPageEmailState extends State<SignupPageEmail> {

  final TextEditingController emailController = TextEditingController();
  bool emailValidate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Email Address',
        ),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        shadowColor: const Color(0xffe8e8e8),
      ),
      body: mobilePage(),
    );
  }

  Widget mobilePage(){
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: ListView(
        children: [
          const SizedBox(height: 30,),
          const Center(
            child: Text(
              "Enter your email address",
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
              "Enter your email address on which you can be contacted.",
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
            onPressed: (){
              if(emailController.text.trim().isNotEmpty && emailController.text.contains("@") && emailController.text.contains(".") && !emailController.text.trim().contains(" ")){
                emailValidate = false;
                widget.userBasicInfo.email = emailController.text.trim();

                setState((){

                });
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPagePassword(userBasicInfo: widget.userBasicInfo,)));
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
                  'Next',
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
