import 'package:eventqc/signup/signup_page_password.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';

class SignupPageEmailVerification extends StatefulWidget {
  final UserBasicInfo userBasicInfo;
  const SignupPageEmailVerification({Key? key, required this.userBasicInfo}) : super(key: key);

  @override
  _SignupPageEmailVerificationState createState() => _SignupPageEmailVerificationState();
}

class _SignupPageEmailVerificationState extends State<SignupPageEmailVerification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verify your email address',
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
              "Enter the code that we sent to\nemail@address.com",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10,),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "We sent a 6-digit code to your email address.\nEnter the code to verify your email address.",
              style: TextStyle(
                color: Color(0xff707071),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20,),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20,0,20,0),
              child: SizedBox(
                width: (MediaQuery.of(context).size.width)/2,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(

                    hintText: "Enter Code",
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40,),

          TextButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPagePassword(userBasicInfo: widget.userBasicInfo,)));
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

          const SizedBox(height: 20,),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: ListTile(
              leading: Icon(Icons.send),
              title: Text(
                "Send Email Again",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
