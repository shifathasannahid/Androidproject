import 'package:eventqc/signup/signup_page_gender.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';

class SignupPageDOB extends StatefulWidget {
  final UserBasicInfo userBasicInfo;
  const SignupPageDOB({Key? key, required this.userBasicInfo}) : super(key: key);

  @override
  _SignupPageDOBState createState() => _SignupPageDOBState();
}

class _SignupPageDOBState extends State<SignupPageDOB> {

  DateTime _selectedDate = DateTime(2000,1,1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Date of birth',
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
              "What's your date of birth?",
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
              "Choose your date of birth.",
              style: TextStyle(
                color: Color(0xff707071),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20,),

          SizedBox(
            height: 250,
            child: ScrollDatePicker(
              selectedDate: _selectedDate,
              // locale: DatePickerLocale.enUS,
              onDateTimeChanged: (DateTime value) {
                setState(() {
                  _selectedDate = value;
                });
              },
            ),
          ),

          const SizedBox(height: 40,),

          TextButton(
            onPressed: (){
              String dob = "${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}";
              widget.userBasicInfo.dateOfBirth = dob;
              setState(() {

              });
              Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPageGender(userBasicInfo: widget.userBasicInfo,)));
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
