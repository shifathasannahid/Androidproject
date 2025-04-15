import 'package:eventqc/signup/signup_page_email.dart';
import 'package:eventqc/signup/signup_page_phone.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupPageGender extends StatefulWidget {
  final UserBasicInfo userBasicInfo;
  const SignupPageGender({Key? key, required this.userBasicInfo}) : super(key: key);

  @override
  _SignupPageGenderState createState() => _SignupPageGenderState();
}

class _SignupPageGenderState extends State<SignupPageGender> {

  String? selectedGender;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gender',
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
              "What's your gender?",
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
              "Select your gender.",
              style: TextStyle(
                color: Color(0xff707071),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20,),

          InkWell(
            onTap: (){
              setState(() {
                selectedGender = "Female";
              });
            },
            child: ListTile(
              title: const Text("Female"),
              trailing: Radio(value: "Female", groupValue: selectedGender, onChanged: (String? value) {

                setState(() {
                  selectedGender = value;
                });
              },

              ),
            ),
          ),
          Container(
            height: 2,
            decoration: const BoxDecoration(
              color: Color(0xffd0d0d0),
            ),
          ),
          InkWell(
            onTap: (){
              setState(() {
                selectedGender = "Male";
              });
            },
            child: ListTile(
              title: const Text("Male"),
              trailing: Radio(value: "Male", groupValue: selectedGender, onChanged: (String? value) {

                setState(() {
                  selectedGender = value;
                });
              },

              ),
            ),
          ),
          Container(
            height: 2,
            decoration: const BoxDecoration(
              color: Color(0xffd0d0d0),
            ),
          ),


          const SizedBox(height: 40,),

          TextButton(
            onPressed: (){
              if(selectedGender != null){
                widget.userBasicInfo.gender = selectedGender!;
                setState(() {

                });
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPagePhone(userBasicInfo: widget.userBasicInfo,)));
              }
              else{
                Fluttertoast.showToast(msg: "Please select your gender to continue...");
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
