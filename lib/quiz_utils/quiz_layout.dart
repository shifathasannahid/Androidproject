import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/quiz_utils/quiz_info_util.dart';
import 'package:eventqc/quiz_utils/quiz_util.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class QuizLayout extends StatefulWidget {
  final List<Quiz> quizList;
  final String communityKey;
  final UserBasicInfo userBasicInfo;
  final Future<void> Function(bool) onSubmit;
  const QuizLayout(
      {Key? key,
      required this.quizList,
      required this.communityKey,
      required this.onSubmit,
      required this.userBasicInfo})
      : super(key: key);

  @override
  State<QuizLayout> createState() => _QuizLayoutState();
}

class _QuizLayoutState extends State<QuizLayout> {
  String? selectedAnswer;
  QuizInfo? quizInfo;
  bool isLoading = true;
  int quizIndex = 0;

  Future<void> getQuizInfo() async {
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.userBasicInfo.userUid)
          .collection("QuizInfo")
          .doc(widget.communityKey)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          quizInfo = QuizInfo.fromJson(snapshot.data()!);
          if (!mounted) {
            return;
          }
          setState(() {
            isLoading = false;
          });
        } else {
          Fluttertoast.showToast(msg: "Something went wrong...");
          Navigator.pop(context);
        }
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Something went wrong...");
      Navigator.pop(context);
    }
  }

  Future<void> setQuizInfo() async {
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.userBasicInfo.userUid)
          .collection("QuizInfo")
          .doc(widget.communityKey)
          .set(quizInfo!.toJson());
      setState(() {
        isLoading = false;
      });
      getQuizInfo();
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Something went wrong...\nPlease try again");
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    getQuizInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.quizList[quizIndex].question,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedAnswer = "A";
                      });
                    },
                    child: ListTile(
                      title: Text("A. ${widget.quizList[quizIndex].optionA}"),
                      trailing: Radio(
                        value: "A",
                        groupValue: selectedAnswer,
                        onChanged: (String? value) {
                          setState(() {
                            selectedAnswer = value;
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
                    onTap: () {
                      setState(() {
                        selectedAnswer = "B";
                      });
                    },
                    child: ListTile(
                      title: Text("B. ${widget.quizList[quizIndex].optionB}"),
                      trailing: Radio(
                        value: "B",
                        groupValue: selectedAnswer,
                        onChanged: (String? value) {
                          setState(() {
                            selectedAnswer = value;
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
                    onTap: () {
                      setState(() {
                        selectedAnswer = "C";
                      });
                    },
                    child: ListTile(
                      title: Text("C. ${widget.quizList[quizIndex].optionC}"),
                      trailing: Radio(
                        value: "C",
                        groupValue: selectedAnswer,
                        onChanged: (String? value) {
                          setState(() {
                            selectedAnswer = value;
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
                    onTap: () {
                      setState(() {
                        selectedAnswer = "D";
                      });
                    },
                    child: ListTile(
                      title: Text("D. ${widget.quizList[quizIndex].optionD}"),
                      trailing: Radio(
                        value: "D",
                        groupValue: selectedAnswer,
                        onChanged: (String? value) {
                          setState(() {
                            selectedAnswer = value;
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
                  const SizedBox(
                    height: 30,
                  ),
                  TextButton(
                    onPressed: () {
                      if (quizInfo != null) {
                        if (selectedAnswer == null) {
                          Fluttertoast.showToast(msg: "Select an answer");
                        } else if (selectedAnswer ==
                            widget.quizList[quizIndex].answer
                                .trim()
                                .toUpperCase()) {
                          setState(() {
                            isLoading = true;
                            quizInfo!.correctAnswer =
                                quizInfo!.correctAnswer + 1;
                            quizInfo!.quizTaken = quizInfo!.quizTaken + 1;
                            quizInfo!.takenIdList
                                .add(widget.quizList[quizIndex].id.toString());
                          });
                          setQuizInfo().whenComplete(() {
                            widget.onSubmit(true).whenComplete(() {
                              if(quizIndex == widget.quizList.length -1){
                                Fluttertoast.showToast(msg: "You've taken all today's quiz.");
                                Navigator.pop(context);
                              }
                              else{
                                setState((){
                                  quizIndex++;
                                  selectedAnswer = null;
                                });
                              }

                            });
                          });
                        } else {
                          setState(() {
                            isLoading = true;
                            quizInfo!.quizTaken = quizInfo!.quizTaken + 1;
                            quizInfo!.takenIdList
                                .add(widget.quizList[quizIndex].id.toString());
                          });
                          setQuizInfo().whenComplete(() async{
                            await widget.onSubmit(false).whenComplete(() {
                              if(quizIndex == widget.quizList.length -1){
                                Fluttertoast.showToast(msg: "You've taken all today's quiz.");
                                Navigator.pop(context);
                              }
                              else{
                                setState((){
                                  quizIndex++;
                                  selectedAnswer = null;
                                });
                              }
                            });
                          });
                        }
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
                          'Submit Answer',
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
            ),
          );
  }
}
