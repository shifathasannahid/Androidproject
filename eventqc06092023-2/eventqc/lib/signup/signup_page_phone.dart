import 'package:country_code_picker/country_code_picker.dart';
import 'package:eventqc/signup/signup_page_phone_verification.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupPagePhone extends StatefulWidget {
  final UserBasicInfo userBasicInfo;
  const SignupPagePhone({Key? key,required this.userBasicInfo}) : super(key: key);

  @override
  _SignupPagePhoneState createState() => _SignupPagePhoneState();
}

class _SignupPagePhoneState extends State<SignupPagePhone> {

  final TextEditingController phoneController = TextEditingController();
  bool phoneValidate = false;
  String countryCode = "+880";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mobile Number',
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
              "Enter your mobile number",
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
              "Enter your mobile number on which you can be contacted.",
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  child: CountryCodePicker(
                    favorite: const ["BD"],
                    initialSelection: "BD",
                    alignLeft: true,

                    onChanged: (countryCode){
                      if(countryCode.dialCode != null) {
                        this.countryCode = countryCode.dialCode!;
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width)/2,
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: "XXXXXXXXXX",
                      errorText: phoneValidate ? "Enter your phone number" : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(20,0,20,0),
          //   child: SizedBox(
          //     width: (MediaQuery.of(context).size.width) - 20,
          //     child: TextFormField(
          //       keyboardType: TextInputType.phone,
          //       controller: phoneController,
          //       decoration: InputDecoration(
          //         hintText: "XXXXXXXXXX",
          //         errorText: phoneValidate ? "Enter your phone number" : null,
          //       ),
          //     ),
          //   ),
          // ),

          const SizedBox(height: 40,),

          TextButton(
            onPressed: (){
              if(phoneController.text.isNotEmpty) {
                phoneValidate = false;
                widget.userBasicInfo.phone = "$countryCode${phoneController.text.trim()}";
                setState(() {

                });
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => SignupPagePhoneVerification(userBasicInfo: widget.userBasicInfo,)));
              }
              else{
                phoneValidate = true;
                setState(() {

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
