import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UpdateRecordedVideoLink extends StatefulWidget {
  final DocumentReference eventReference;
  const UpdateRecordedVideoLink({Key? key, required this.eventReference}) : super(key: key);

  @override
  State<UpdateRecordedVideoLink> createState() => _UpdateRecordedVideoLinkState();
}

class _UpdateRecordedVideoLinkState extends State<UpdateRecordedVideoLink> {

  TextEditingController linkController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(height: 20,),
          const Center(
            child: Text(
              "Enter your recorded video link",
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
              "Upload your recorded video anywhere with public access. Only members who joined in this event can view this video if you don't share the link with others.",
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
                keyboardType: TextInputType.url,
                controller: linkController,
                decoration: const InputDecoration(
                  labelText: "Video Link",
                  hintText: "Enter your recorded video link",
                ),
              ),
            ),
          ),

          const SizedBox(height: 20,),

          TextButton(
            onPressed: () async{
              await widget.eventReference.update({
                "recordedEventLink" : linkController.text.trim(),
              });
              Fluttertoast.showToast(msg: "Link updated successfully");
              setState((){
                linkController.text = "";
              });
              // if(emailController.text.trim().isNotEmpty && emailController.text.contains("@") && emailController.text.contains(".") && !emailController.text.trim().contains(" ")){
              //   emailValidate = false;
              //   widget.userBasicInfo.email = emailController.text.trim();
              //
              //   setState((){
              //
              //   });
              //   Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPagePassword(userBasicInfo: widget.userBasicInfo,)));
              // }
              // else{
              //   emailValidate = true;
              //   setState((){
              //
              //   });
              // }
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
                  'Update link',
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
