import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/community_utils/answer_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../user_utils/user_basic_info_util.dart';
import 'answer_layout.dart';

class AnswerPage extends StatefulWidget {
  final DocumentReference discussionReference;
  final String communityUid;
  const AnswerPage({Key? key, required this.discussionReference, required this.communityUid}) : super(key: key);

  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {

  bool isLoading = false;
  UserBasicInfo? userBasicInfo;
  String? userUid;
  int answerNumber = -1;
  final TextEditingController answerController = TextEditingController();
  bool canSend = false;
  Future<void> getUserBasicInfo() async {
    userUid = FirebaseAuth.instance.currentUser?.uid;
    if(userUid != null){
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userUid)
          .collection("BasicInfo")
          .doc(userUid)
          .get()
          .then((value) {
        setState(() {
          userBasicInfo = UserBasicInfo.fromJson(value.data()!);
          isLoading = false;
        });
      });
    }
  }


  List<DocumentSnapshot> answers = []; // stores fetched products
  bool hasMore = true; // flag for more products available or not
  int documentLimit = 10; // documents to be fetched per request
  DocumentSnapshot?
  lastDocument; // flag for last document from where next 10 records to be fetched
  // ScrollController scrollController =
  //     ScrollController(); // listener for listview scrolling

  List<Answer> answersList = [];
  getAnswers() async {
    if (!hasMore) {
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      await widget.discussionReference
          .collection('Answers')
          .orderBy('answerNumber', descending: true)
          .limit(documentLimit)
          .get().then((value) {

        for(int i = 0; i< value.size; i++){
          if(!mounted){
            return;
          }
          setState((){
            answersList.add(Answer.fromJson(value.docs[i].data()));
          });
        }
      });
      querySnapshot = await widget.discussionReference
          .collection('Answers')
          .orderBy('answerNumber', descending: true)
          .limit(documentLimit)
          .get();
    } else {
      await widget.discussionReference
          .collection('Answers')
          .orderBy('answerNumber', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(documentLimit)
          .get().then((value) {
        for(int i = 0; i< value.size; i++){
          if(!mounted){
            return;
          }
          setState((){
            answersList.add(Answer.fromJson(value.docs[i].data()));
          });
        }
      });
      querySnapshot = await widget.discussionReference
          .collection('Answers')
          .orderBy('answerNumber', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(documentLimit)
          .get();
    }
    if (querySnapshot.size < documentLimit) {
      hasMore = false;
    }
    if(querySnapshot.size != 0){
      lastDocument = querySnapshot.docs[querySnapshot.size - 1];
    }

    answers.addAll(querySnapshot.docs);
    setState(() {
      isLoading = false;
      answersList.sort((a,b) => b.answerNumber.compareTo(a.answerNumber));
    });
  }

  Future<void> onTextChange() async{
    setState((){
      canSend = answerController.text.trim().isNotEmpty;

    });
    // Fluttertoast.showToast(msg: canSend.toString());
  }

  @override
  void initState(){
    answerController.addListener(() {
      onTextChange();
    });
    getUserBasicInfo();
    getAnswers();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: userBasicInfo == null? Container() : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          hasMore && answersList.isNotEmpty ? Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: (){
                getAnswers();
              },
              child: const Text("show more", style: TextStyle(
                color: Colors.blue,
              ),),
            ),
          ) : Container(),
          TextFormField(
            maxLines: null,
            keyboardType: TextInputType.multiline,
            controller: answerController,
            decoration: InputDecoration(
              hintText: "Write your answer here",
              prefixIcon: SizedBox(
                width: 20,
                height: 20,
                child: Center(
                  child: userBasicInfo!.profileImageUrl.isEmpty
                      ? CircleAvatar(
                    radius: 15,
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
                    radius: 15,
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
              suffixIcon: canSend ? InkWell(
                onTap: (){
                  postAnswer();
                },
                  child: const Icon(Icons.send, color: Colors.blue,),) : null,
            ),
          ),
          ListView.builder(
            itemCount: answersList.length,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemBuilder: (context, index) => AnswerLayout(answer: answersList[index], answerReference: widget.discussionReference.collection("Answers").doc(answersList[index].key), viewerUid: userBasicInfo!.userUid, communityUid: widget.communityUid,),
          ),
          isLoading? const Center(child: CircularProgressIndicator(),) : Container(),

        ],
      )
    );
  }

  Future<void> postAnswer() async{

    String key = widget.discussionReference.collection("Answers").doc().id;
    await widget.discussionReference.collection("Answers").get().then((value) {
      setState((){
        answerNumber = value.size;
      });
    });
    if(answerNumber != -1){

      Answer answer = Answer(key, userBasicInfo!.userUid, answerController.text.trim(), 0, answerNumber);
      await widget.discussionReference.collection("Answers").doc(key).set(answer.toJson()).whenComplete((){
        // getAnswers();
        setState((){
          answersList.add(answer);
          answersList.sort((a,b) => b.answerNumber.compareTo(a.answerNumber));
          canSend = false;
          answerController.text = "";
          answerNumber = -1;
          hasMore = true;
        });
      });
    }
    else{
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }
}
