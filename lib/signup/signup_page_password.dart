import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/login/login_page.dart';
import 'package:eventqc/user_dashboard/user_home_page.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupPagePassword extends StatefulWidget {
  final UserBasicInfo userBasicInfo;
  const SignupPagePassword({Key? key, required this.userBasicInfo}) : super(key: key);

  @override
  _SignupPagePasswordState createState() => _SignupPagePasswordState();
}

class _SignupPagePasswordState extends State<SignupPagePassword> {

  final TextEditingController passwordController = TextEditingController();
  bool passwordValidate = false;
  String password = "";
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  Future<void> linkEmailWithPhone() async{
    AuthCredential authCredential = EmailAuthProvider.credential(email: widget.userBasicInfo.email, password: password);
    user!.linkWithCredential(authCredential).then((value) async{
      setState((){
        widget.userBasicInfo.userUid = user!.uid;
      });
      await FirebaseFirestore.instance.collection("Users").doc(user!.uid).collection("BasicInfo").doc(user!.uid).set(widget.userBasicInfo.toJson());
      await FirebaseFirestore.instance.collection("ActiveUsersUid").doc(user!.uid).set(
          {
            "userUid" : user!.uid,
            "phone" : widget.userBasicInfo.phone,
            "email" : widget.userBasicInfo.email,
          }).whenComplete(() {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
      });
    });

  }

  @override
  void initState() {
    user = auth.currentUser;
    setState((){

    });
    if(user == null){
      Fluttertoast.showToast(msg: "Something went wrong...\nPlease try again...");
      Navigator.pop(context);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Password',
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
              "Choose a password",
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
              "Create a password with at least 6 characters. It should be something that others couldn't guess.",
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
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Create a strong password",
                  errorText: passwordValidate? "Enter a valid password" :null,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40,),

          TextButton(
            onPressed: () async{
              if(passwordController.text.length >= 6){
                password = passwordController.text;
                passwordValidate = false;
                setState((){

                });
                await linkEmailWithPhone();
              }
              else{
                passwordValidate = true;
                setState((){

                });
              }
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPageDOB()));
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
                  'Signup',
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
