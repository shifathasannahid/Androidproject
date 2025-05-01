import 'package:eventqc/signup/signup_page_dob.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';

class SignupPageName extends StatefulWidget {
  const SignupPageName({Key? key}) : super(key: key);

  @override
  _SignupPageNameState createState() => _SignupPageNameState();
}

class _SignupPageNameState extends State<SignupPageName> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  bool firstNameValidate = false;
  bool lastNameValidate = false;

  String firstName = "";
  String lastName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Name',
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
          const Center(
            child: Text(
              "What's your name?",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Enter the name you use in real life.",
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: firstNameController,
                  decoration: InputDecoration(
                    labelText: "First Name",
                    hintText: "Enter first name",
                    errorText: firstNameValidate ? "Enter your first name" : null,
                  ),
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: lastNameController,
                  decoration: InputDecoration(
                    labelText: "Surname",
                    hintText: "Enter surname",
                    errorText: lastNameValidate ? "Enter your surname" : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          TextButton(
            onPressed: () {
              if (!isNullField()) {
                UserBasicInfo info = UserBasicInfo("",firstName, lastName,
                    "", "", "", "","General", "");
                setState(() {

                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignupPageDOB(userBasicInfo: info,)));
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

  bool isNullField() {
    if (firstNameController.text.isEmpty) {
      firstNameValidate = true;
      setState(() {});
      return true;
    } else if (lastNameController.text.isEmpty) {
      lastNameValidate = true;
      firstNameValidate = false;
      setState(() {});
      return true;
    } else {
      firstNameValidate = false;
      lastNameValidate = false;
      firstName = firstNameController.text.trim();
      lastName = lastNameController.text.trim();
      setState(() {});
      return false;
    }
  }
}
