import 'dart:async';

import 'package:eventqc/signup/signup_page_email.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupPagePhoneVerification extends StatefulWidget {
  final UserBasicInfo userBasicInfo;
  const SignupPagePhoneVerification({Key? key, required this.userBasicInfo})
      : super(key: key);

  @override
  _SignupPagePhoneVerificationState createState() =>
      _SignupPagePhoneVerificationState();
}

class _SignupPagePhoneVerificationState
    extends State<SignupPagePhoneVerification> {

  String? verificationId;
  int? forceResendingToken;
  final TextEditingController codeController = TextEditingController();
  bool codeValidate = false;
  String code = "";
  bool disableCodeSend = false;

  FirebaseAuth auth = FirebaseAuth.instance;

  Timer timer() {
    return Timer(const Duration(seconds: 60), timerWork);
  }

  void timerWork(){
    disableCodeSend = false;
    setState(() {

    });
  }

  Future<void> sendCode() async {
    disableCodeSend = true;
    auth.verifyPhoneNumber(
        phoneNumber: widget.userBasicInfo.phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential){
          auth.signInWithCredential(authCredential).then((UserCredential result){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SignupPageEmail(userBasicInfo: widget.userBasicInfo,)));
          }).catchError((e){
            Fluttertoast.showToast(msg: "Something went wrong...\nPlease try again...");
            Fluttertoast.showToast(msg: "${e.message}", toastLength: Toast.LENGTH_LONG);

          });
        },
        verificationFailed: (FirebaseAuthException authException){
          Fluttertoast.showToast(msg: "Verification failed...\nPlease try again...");
          Fluttertoast.showToast(msg: "${authException.message}", toastLength: Toast.LENGTH_LONG);

        },
        codeSent: (String id, int? token){
          verificationId = id;
          forceResendingToken = token;
          timer();
          setState(() {

          });
        },
        codeAutoRetrievalTimeout: (String verificationId){
          this.verificationId = verificationId;
        },
    );
  }

  Future<void> verifyCode() async{
    if(verificationId!=null) {
      AuthCredential authCredential = PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: code);
      auth.signInWithCredential(authCredential).then((UserCredential result){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SignupPageEmail(userBasicInfo: widget.userBasicInfo,)));
      }).catchError((e){
        Fluttertoast.showToast(msg: "Something went wrong...\nPlease try again...");
        Fluttertoast.showToast(msg: "${e.message}", toastLength: Toast.LENGTH_LONG);

      });
    }
    else{
      Fluttertoast.showToast(msg: "Something went wrong...\nPlease try again...");
    }
  }

  @override
  void initState() {
    sendCode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verify your mobile number',
        ),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        shadowColor: const Color(0xffe8e8e8),
      ),
      body: mobilePage(),
    );
  }

  Widget mobilePage() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: ListView(
        children: [
          const SizedBox(
            height: 30,
          ),
          Center(
            child: Text(
              "Enter the code that we sent to\n${widget.userBasicInfo.phone}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "We sent a 6-digit code to your mobile number.\nEnter the code to verify your mobile number.",
              style: TextStyle(
                color: Color(0xff707071),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: SizedBox(
                width: (MediaQuery.of(context).size.width) / 2,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  controller: codeController,
                  decoration: InputDecoration(
                    hintText: "Enter Code",
                    errorText: codeValidate ? "Enter a valid code" : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          TextButton(
            onPressed: () async{
              if(codeController.text.trim().isEmpty || codeController.text.trim().length != 6){
                codeValidate = true;
                setState(() {

                });
              }
              else{
                codeValidate = false;
                code = codeController.text.trim();
                setState(() {

                });
                await verifyCode();
              }
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => const SignupPageEmail()));
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
          const SizedBox(
            height: 20,
          ),
          disableCodeSend ? Container() : Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              onTap: sendCode,
              leading: const Icon(Icons.send),
              title: const Text(
                "Send Code Again",
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
