import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/quiz_utils/quiz_info_util.dart';
import 'package:eventqc/quiz_utils/quiz_start_page.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ntp/ntp.dart';

import '../community_utils/community_util.dart';

class QuizPage extends StatefulWidget {
  final List<Community> communityList;
  final UserBasicInfo userBasicInfo;
  const QuizPage({
    Key? key,
    required this.communityList,
    required this.userBasicInfo,
  }) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String todayString = "";
  Community? selectedCommunity;
  QuizInfo? quizInfo;
  bool isLoading = false;
  bool quizAvailable = false;
  int heartRemains = 0;
  Future<void> getQuizInfo() async {
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.userBasicInfo.userUid)
          .collection("QuizInfo")
          .doc(selectedCommunity!.key)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          quizInfo = QuizInfo.fromJson(snapshot.data()!);
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            quizInfo = QuizInfo(
              widget.userBasicInfo.userUid,
              selectedCommunity!.category,
              selectedCommunity!.categoryKey,
              selectedCommunity!.key,
              selectedCommunity!.name,
              0,
              0,
              [],
              [],
            );
            isLoading = false;
          });
        }
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Something went wrong...\nPlease try again");
    }
    if (selectedCommunity != null && quizInfo != null) {
      getTodaysQuiz();
    }
  }

  Future<void> setQuizInfo() async {
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.userBasicInfo.userUid)
          .collection("QuizInfo")
          .doc(selectedCommunity!.key).set(quizInfo!.toJson());
      setState((){
        isLoading = false;
      });

    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Something went wrong...\nPlease try again");
    }
  }

  Future<void> getTodaysQuiz() async {
    if (quizInfo!.takenDateList.contains(todayString)) {
      setState(() {
        quizAvailable = false;
      });
    } else {
      setState(() {
        quizAvailable = true;
      });
    }
  }

  Future<void> getToday() async {
    DateTime now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final int offset = await NTP.getNtpOffset();
    DateTime today = now.add(Duration(milliseconds: offset));
    if(!mounted){
      return;
    }
    setState(() {
      todayString = "${today.day}-${today.month}-${today.year}";
    });

    getQuizHeart();
  }

  Future<void> getQuizHeart() async{
    FirebaseFirestore.instance.collection("Users").doc(widget.userBasicInfo.userUid).collection("QuizHearts").doc(widget.userBasicInfo.userUid).snapshots().listen((snapshot) {
      if(snapshot.exists){
        if(snapshot["lastDate"] == null){
          FirebaseFirestore.instance.collection("Users").doc(widget.userBasicInfo.userUid).collection("QuizHearts").doc(widget.userBasicInfo.userUid).update({
            "lastDate" : todayString,
            "heartRemains" : snapshot["heartRemains"] + 5,
          });
          Fluttertoast.showToast(msg: "You've got first login bonus");
        }
        else if(snapshot["lastDate"] != todayString){
          FirebaseFirestore.instance.collection("Users").doc(widget.userBasicInfo.userUid).collection("QuizHearts").doc(widget.userBasicInfo.userUid).update({
            "lastDate" : todayString,
            "heartRemains" : snapshot["heartRemains"] + 3,
          });
          Fluttertoast.showToast(msg: "You've got daily bonus");
        }
        if(!mounted){
          return;
        }
        setState((){
          heartRemains = snapshot["heartRemains"];
        });
      }
    });
  }

  @override
  void initState() {
    getToday();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : ListView(
            children: [
              Card(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: widget.communityList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (MediaQuery.of(context).orientation ==
                              Orientation.portrait)
                          ? 3
                          : 5),
                  itemBuilder: (context, index) =>
                      quizCommunityLayout(widget.communityList[index]),
                ),
              ),
              selectedCommunity != null && quizInfo != null
                  ? const SizedBox(
                      height: 20,
                    )
                  : Container(),
              selectedCommunity != null && quizInfo != null
                  ? Center(
                      child: Text(
                        selectedCommunity!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : Container(),
              selectedCommunity != null && quizInfo != null
                  ? const SizedBox(
                      height: 20,
                    )
                  : Container(),
              selectedCommunity != null && quizInfo != null
                  ? Center(
                      child: Text(
                        "Result: ${quizInfo!.correctAnswer}/${quizInfo!.quizTaken}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : Container(),
              selectedCommunity != null && quizInfo != null
                  ? const SizedBox(
                      height: 20,
                    )
                  : Container(),
              selectedCommunity != null && quizInfo != null
                  ? TextButton(
                      onPressed: () async{
                        if(heartRemains == 0){
                          Fluttertoast.showToast(msg: "You've no chance left...");
                        }
                        else if(quizAvailable){
                          setState((){
                            quizInfo!.takenDateList.add(todayString);
                          });
                          await setQuizInfo().whenComplete(() {
                            Community community = selectedCommunity!;
                            QuizInfo quizInfoCommunity = quizInfo!;
                            DocumentReference communityReference = FirebaseFirestore.instance
                                .collection("Categories")
                                .doc(selectedCommunity!.categoryKey)
                                .collection("Communities").doc(selectedCommunity!.key);
                            setState((){
                              selectedCommunity = null;
                              quizInfo = null;
                            });
                            Navigator.push(context, MaterialPageRoute(builder: (context) => QuizStartPage(quizInfo: quizInfoCommunity, userBasicInfo: widget.userBasicInfo, community: community, communityReference: communityReference)));
                          });

                        }
                        else{
                          Fluttertoast.showToast(msg: "You've already taken today's quiz.\nCome back tomorrow for new quiz...", toastLength: Toast.LENGTH_LONG);
                        }

                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width - 40,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: quizAvailable? Colors.blue : Colors.red,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: quizAvailable? const Text(
                            "Take today's quiz",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ) : const Text(
                            "You've taken today's quiz",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          );
  }

  Widget quizCommunityLayout(Community community) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedCommunity = community;
          isLoading = true;
        });
        getQuizInfo();
      },
      child: Card(
        color: selectedCommunity == community ? Colors.amber : Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListView(
          physics: const ScrollPhysics(),
          shrinkWrap: true,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                community.coverImageUrl,
              ),
            ),
            Text(
              community.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}
