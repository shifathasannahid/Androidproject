import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/community_utils/answer_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../user_utils/user_basic_info_util.dart';

class AnswerLayout extends StatefulWidget {
  final DocumentReference answerReference;
  final Answer answer;
  final String viewerUid;
  final String communityUid;
  const AnswerLayout({Key? key, required this.answerReference, required this.answer, required this.viewerUid, required this.communityUid}) : super(key: key);

  @override
  State<AnswerLayout> createState() => _AnswerLayoutState();
}

class _AnswerLayoutState extends State<AnswerLayout> {

  UserBasicInfo? userBasicInfo;
  bool helpPointGiven = false;
  bool isPositive = false;
  bool isProcessing = false;
  Future<void> getGivenHelpPoint() async{
    await widget.answerReference.collection("HelpPoint").doc(widget.viewerUid).get().then((value) {
      if(value.exists){
        if(!mounted){
          return;
        }
        setState((){
          isPositive = value.data()!['isPositive'];
          helpPointGiven = true;
        });
      }
      else{
        if(!mounted){
          return;
        }
        setState((){
          helpPointGiven = false;
        });
      }
    });
  }

  Future<void> setHelpPoint(bool helpful) async{
    if(isProcessing){
      return;
    }
    if(widget.answer.userUid == widget.viewerUid){
      Fluttertoast.showToast(msg: "You can't give yourself feedback");
      return;
    }
    if(helpful && isPositive && helpPointGiven){
      Fluttertoast.showToast(msg: "You've already given positive feedback");
      return;
    }
    if(!helpful && !isPositive && helpPointGiven){
      Fluttertoast.showToast(msg: "You've already given negative feedback");
      return;
    }

    setState((){
      isProcessing = true;
    });

    int helpPoint = 0;

    await FirebaseFirestore.instance.collection("Users").doc(widget.answer.userUid).collection("HelpPoint").doc(widget.communityUid).get().then((value) {
      if(value.exists){
        setState((){
          helpPoint = value.data()!["helpPoint"];
        });
      }
      else {
        FirebaseFirestore.instance.collection("Users").doc(widget.answer.userUid).collection("HelpPoint").doc(widget.communityUid).set({
          "helpPoint" : 0,
        });
      }
    });
    if(!helpful && isPositive && helpPointGiven){
      // helpPoint -2
      await widget.answerReference.update({
        "helpPoint" : widget.answer.helpPoint - 2,
      });

      await FirebaseFirestore.instance.collection("Users").doc(widget.answer.userUid).collection("HelpPoint").doc(widget.communityUid).update({
        "helpPoint" : helpPoint -2,
      });
      await widget.answerReference.collection("HelpPoint").doc(widget.viewerUid).set({
        "isPositive" : helpful,
      });

      setState((){
        widget.answer.helpPoint = widget.answer.helpPoint -2;
        helpPointGiven = true;
      });
    }
    else if(helpful && !isPositive && helpPointGiven){
      // helpPoint +2
      await widget.answerReference.update({
        "helpPoint" : widget.answer.helpPoint + 2,
      });

      await FirebaseFirestore.instance.collection("Users").doc(widget.answer.userUid).collection("HelpPoint").doc(widget.communityUid).update({
        "helpPoint" : helpPoint + 2,
      });
      await widget.answerReference.collection("HelpPoint").doc(widget.viewerUid).set({
        "isPositive" : helpful,
      });

      setState((){
        widget.answer.helpPoint = widget.answer.helpPoint + 2;
        helpPointGiven = true;
      });
    }
    else if(helpful && !helpPointGiven){
      // helpPoint + 1
      await widget.answerReference.update({
        "helpPoint" : widget.answer.helpPoint + 1,
      });

      await FirebaseFirestore.instance.collection("Users").doc(widget.answer.userUid).collection("HelpPoint").doc(widget.communityUid).update({
        "helpPoint" : helpPoint + 1,
      });
      await widget.answerReference.collection("HelpPoint").doc(widget.viewerUid).set({
        "isPositive" : helpful,
      });

      setState((){
        widget.answer.helpPoint = widget.answer.helpPoint + 1;
        helpPointGiven = true;
      });
    }
    else if(!helpful && !helpPointGiven){
      //helpPoint - 1
      await widget.answerReference.update({
        "helpPoint" : widget.answer.helpPoint - 1,
      });

      await FirebaseFirestore.instance.collection("Users").doc(widget.answer.userUid).collection("HelpPoint").doc(widget.communityUid).update({
        "helpPoint" : helpPoint - 1,
      });
      await widget.answerReference.collection("HelpPoint").doc(widget.viewerUid).set({
        "isPositive" : helpful,
      });

      setState((){
        widget.answer.helpPoint = widget.answer.helpPoint - 1;
        helpPointGiven = true;
      });

    }
    await getGivenHelpPoint();
    setState((){
      isProcessing = false;
    });
  }


  Future<void> getUserBasicInfo() async {

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.answer.userUid)
          .collection("BasicInfo")
          .doc(widget.answer.userUid)
          .get()
          .then((value) {
        if(!mounted){
          return;
        }
        setState(() {
          userBasicInfo = UserBasicInfo.fromJson(value.data()!);
        });
      });

  }

  @override
  void initState(){

    getUserBasicInfo();
    getGivenHelpPoint();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return userBasicInfo == null? Container() : Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: userBasicInfo!.profileImageUrl.isEmpty
                  ? CircleAvatar(
                radius: 20,
                backgroundImage: userBasicInfo!
                    .gender ==
                    "Male"
                    ? const AssetImage(
                    'assets/male_profile_image.png')
                    : const AssetImage(
                  'assets/female_profile_image.png',
                ),
                // child: ClipOval(
                //   child: widget.userBasicInfo.gender == "Male"
                //       ? Image.asset(
                //           "assets/male_profile_image.png",
                //           fit: BoxFit.fill,
                //         )
                //       : Image.asset(
                //           "assets/female_profile_image.png",
                //           fit: BoxFit.fill,
                //         ),
                // ),
              )
                  : CircleAvatar(
                radius: 20,
                // child: ClipOval(
                //   child: Image.network(
                //     widget.userBasicInfo.profileImageUrl,
                //     fit: BoxFit.fill,
                //   ),
                // ),
                backgroundImage: NetworkImage(
                    userBasicInfo!.profileImageUrl),
              ),
            ),
          ),

          Container(
            width: MediaQuery.of(context).size.width /1.5,
            padding: const EdgeInsets.all(10),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.answer.answer,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(onTap: (){setHelpPoint(true);},child: const Icon(Icons.keyboard_arrow_up_sharp, size: 30,)),
              Text(
                "${widget.answer.helpPoint}",
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              InkWell(onTap: (){setHelpPoint(false);},child: const Icon(Icons.keyboard_arrow_down_sharp, size: 30,)),
            ],
          )
        ],
      ),
    );
  }
}
