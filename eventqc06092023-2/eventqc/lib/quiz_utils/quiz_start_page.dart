import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/community_utils/community_util.dart';
import 'package:eventqc/quiz_utils/quiz_info_util.dart';
import 'package:eventqc/quiz_utils/quiz_layout.dart';
import 'package:eventqc/quiz_utils/quiz_util.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class QuizStartPage extends StatefulWidget {
  final Community community;
  final DocumentReference communityReference;
  final UserBasicInfo userBasicInfo;
  final QuizInfo quizInfo;
  const QuizStartPage(
      {Key? key,
      required this.quizInfo,
      required this.userBasicInfo,
      required this.community,
      required this.communityReference})
      : super(key: key);
  @override
  State<QuizStartPage> createState() => _QuizStartPageState();
}

class _QuizStartPageState extends State<QuizStartPage> {
  int minute = 8;
  int second = 0;
  int quizTaken = 0;
  int correctAnswer = 0;
  int wrongAnswer = 0;
  int heartRemains = 0;
  List<Quiz> quizList = [];
  void startTimer() {
    Timer timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (second == 0 && minute == 0) {
        setState(() {
          timer.cancel();
          Fluttertoast.showToast(msg: "Time up\nTry again tomorrow");
          Navigator.pop(context);
        });
      } else if (second == 0) {
        if (!mounted) {
          return;
        }
        setState(() {
          second = 59;
          minute--;
        });
      } else {
        if (!mounted) {
          return;
        }
        setState(() {
          second--;
        });
      }
    });
  }

  Future<void> getQuizList() async {
    quizList.clear();
    if (widget.quizInfo.takenIdList.isEmpty) {
      await widget.communityReference
          .collection("Quiz")
          .limit(15)
          .get()
          .then((snapshot) {
        for (int index = 0; index < snapshot.size; index++) {
          quizList.add(Quiz.fromJson(snapshot.docs[index].data()));
          setState(() {});
        }
      }).whenComplete(() {
        if(quizList.isEmpty){
          Fluttertoast.showToast(msg: "No quiz available");
          Navigator.pop(context);
        }
      });
    } else {
      await widget.communityReference.collection("Quiz").get().then((snapshot) {
        for (int index = 0; index < snapshot.size; index++) {
          Quiz quiz = Quiz.fromJson(snapshot.docs[index].data());
          if (quizList.length < 15) {
            if (!widget.quizInfo.takenIdList.contains(quiz.id)) {
              quizList.add(quiz);
              setState(() {});
            }
          } else {
            break;
          }
        }
      }).whenComplete(() {
        if(quizList.isEmpty){
          Fluttertoast.showToast(msg: "No quiz available");
          Navigator.pop(context);
        }
      });
    }

    startTimer();
  }

  Future<void> getQuizHeart() async {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.userBasicInfo.userUid)
        .collection("QuizHearts")
        .doc(widget.userBasicInfo.userUid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        if (!mounted) {
          return;
        }
        setState(() {
          heartRemains = snapshot['heartRemains'];
        });
        if(heartRemains == 0){
          Fluttertoast.showToast(msg: "You've no chance left");
          Navigator.pop(context);
        }
      }
    });
  }

  Future<void> setQuizHeart() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.userBasicInfo.userUid)
        .collection("QuizHearts")
        .doc(widget.userBasicInfo.userUid)
        .update({
      "heartRemains": heartRemains,
    });
  }

  @override
  void initState() {
    getQuizList();
    getQuizHeart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: showExitQuizPopup,
      child: Scaffold(
        appBar: AppBar(
          title:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width/2,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Daily Quiz\n${widget.quizInfo.communityName}",
                  textAlign: TextAlign.left,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.heart_broken,color: Colors.white,),
                  Text("  $heartRemains"),
                ],
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Remaining time: ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      children: [
                        minute < 10
                            ? const TextSpan(
                                text: "0",
                              )
                            : const TextSpan(),
                        TextSpan(
                          text: minute.toString(),
                        ),
                        const TextSpan(
                          text: ":",
                        ),
                        second < 10
                            ? const TextSpan(
                                text: "0",
                              )
                            : const TextSpan(),
                        TextSpan(
                          text: second.toString(),
                        ),
                      ],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: minute < 1 ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Quiz taken: ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "$quizTaken/${quizList.length}",
                        ),
                      ],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Correct/Wrong: ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "$correctAnswer/",
                        ),
                      ],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "$wrongAnswer",
                        ),
                      ],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            quizList.isEmpty? Container() : QuizLayout(
                quizList: quizList,
                communityKey: widget.community.key,
                onSubmit: (bool isCorrect) async {
                  if (isCorrect) {
                    setState(() {
                      correctAnswer++;
                      quizTaken++;
                    });
                    Fluttertoast.showToast(msg: "Correct");
                  } else {
                    setState(() {
                      wrongAnswer++;
                      quizTaken++;
                      heartRemains--;
                    });
                    setQuizHeart();
                    Fluttertoast.showToast(msg: "Wrong");
                  }
                },
                userBasicInfo: widget.userBasicInfo),
          ],
        ),
      ),
    );
  }

  Future<bool> showExitQuizPopup() async {
    return await showDialog( //show confirm dialogue
      //the return value will be from "Yes" or "No" options
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Are you sure?'),
        content: const Text("If you go back you won't be able to take this community quiz today."),
        actions:[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            //return false when click on "NO"
            child:const Text('No'),
          ),

          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            //return true when click on "Yes"
            child:const Text('Yes'),
          ),

        ],
      ),
    )??false; //if showDialouge had returned null, then return false
  }
}
