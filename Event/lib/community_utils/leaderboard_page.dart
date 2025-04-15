import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/community_utils/community_util.dart';
import 'package:eventqc/quiz_utils/quiz_info_util.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LeaderboardCommunityPage extends StatefulWidget {
  final CollectionReference membersReference;
  final String communityUid;
  final Community community;
  const LeaderboardCommunityPage(
      {Key? key,
      required this.membersReference,
      required this.communityUid,
      required this.community})
      : super(key: key);

  @override
  State<LeaderboardCommunityPage> createState() =>
      _LeaderboardCommunityPageState();
}

class _LeaderboardCommunityPageState extends State<LeaderboardCommunityPage> {
  List<String> membersUidList = [];

  bool isLoading = true;
  int helpRank = 0;
  int quizRank = 0;

  Future<void> getMembersUidList() async {
    membersUidList.clear();
    await widget.membersReference.get().then((snapshot) {
      for (int i = 0; i < snapshot.size; i++) {
        setState(() {
          membersUidList.add(snapshot.docs[i]['userUid']);
        });
      }
    });
    getMembersMapList();
  }

  List<Map<String, dynamic>> membersMapList = [];
  List<Map<String, dynamic>> membersHelpPointMapList = [];
  List<Map<String, dynamic>> membersQuizMapList = [];

  Future<void> getMembersMapList() async {
    membersMapList.clear();
    for (String uid in membersUidList) {
      Map<String, dynamic> map = HashMap();
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .collection("BasicInfo")
          .doc(uid)
          .get()
          .then((value) {
        map["basicInfo"] = UserBasicInfo.fromJson(value.data()!);
      });
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .collection("HelpPoint")
          .doc(widget.communityUid)
          .get()
          .then((value) {
        if (value.exists) {
          map["helpPoint"] = value['helpPoint'];
        } else {
          map["helpPoint"] = 0;
        }
      });
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .collection("QuizInfo")
          .doc(widget.communityUid)
          .get()
          .then((value) {
        if (value.exists) {
          map["quizInfo"] = QuizInfo.fromJson(value.data()!);
        } else {
          map["quizInfo"] = QuizInfo(
              uid,
              widget.community.category,
              widget.community.categoryKey,
              widget.community.key,
              widget.community.name,
              0,
              0,
              [],
              []);
        }
      });
      setState(() {
        membersMapList.add(map);
      });
    }
    await getHelpPointRanking();
    await getQuizRanking();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> getHelpPointRanking() async {
    // setState(() {
      membersHelpPointMapList.addAll(membersMapList);
      membersHelpPointMapList.sort((a, b) {
        int aHelpPoint = a["helpPoint"];
        int bHelpPoint = b["helpPoint"];
        return bHelpPoint.compareTo(aHelpPoint);
      });

    // });
    for (int index = 0; index < membersHelpPointMapList.length; index++) {
      if (index == 0) {
        helpRank++;

        membersHelpPointMapList[index]['rankHelpPoint'] = helpRank;

      } else if (membersHelpPointMapList[index]['helpPoint'] ==
          membersHelpPointMapList[index - 1]['helpPoint']) {
        // Fluttertoast.showToast(msg: "Same: $helpRank");
        // setState(() {
          membersHelpPointMapList[index]['rankHelpPoint'] = helpRank;
        // });
      } else {
        // setState(() {
          helpRank++;

          membersHelpPointMapList[index]['rankHelpPoint'] = helpRank;
        // });
      }
      await FirebaseFirestore.instance.collection("Users").doc(membersHelpPointMapList[index]['basicInfo'].userUid).collection("HelpPointRank").doc(widget.communityUid).set({
        "rankHelpPoint" : membersHelpPointMapList[index]['rankHelpPoint'],
      });
      setState((){

      });
    }
  }

  Future<void> getQuizRanking() async {
    // setState(() {
    membersQuizMapList.addAll(membersMapList);
      membersQuizMapList.sort((a, b) {
        QuizInfo aQuizInfo = a['quizInfo'];
        QuizInfo bQuizInfo = b['quizInfo'];
        double resultA = 0;
        double resultB = 0;
        if(aQuizInfo.quizTaken != 0 && bQuizInfo.quizTaken != 0){
          resultA = (aQuizInfo.correctAnswer / aQuizInfo.quizTaken) *
              100;
          resultB = (bQuizInfo.correctAnswer / bQuizInfo.quizTaken) *
              100;
        }else if(aQuizInfo.quizTaken != 0 ){
          resultA = (aQuizInfo.correctAnswer / aQuizInfo.quizTaken) *
              100;
        }
        else if(bQuizInfo.quizTaken != 0){
          resultB = (bQuizInfo.correctAnswer / bQuizInfo.quizTaken) *
              100;
        }
        return resultB.compareTo(resultA);
      });
    // });

    // setState(() {
    //   membersQuizMapList = membersMapList;
    // });
    for (int index = 0; index < membersQuizMapList.length; index++) {
      if (index == 0) {
        // setState(() {
        quizRank++;

          membersQuizMapList[index]['rankQuiz'] = quizRank;
        // });
      } else if (isEqualResult(
          membersQuizMapList[index], membersQuizMapList[index - 1])) {
        // setState(() {
          membersQuizMapList[index]['rankQuiz'] = quizRank;
        // });
      } else {
        // setState(() {
          membersQuizMapList[index]['rankQuiz'] = quizRank + 1;
          quizRank++;
        // });
      }
      await FirebaseFirestore.instance.collection("Users").doc(membersQuizMapList[index]['basicInfo'].userUid).collection("QuizRank").doc(widget.communityUid).set({
        "rankQuiz" : membersQuizMapList[index]['rankQuiz'],
      });
      setState((){

      });
    }
  }

  bool isEqualResult(Map<String, dynamic> a, Map<String, dynamic> b) {
    QuizInfo aQuizInfo = a['quizInfo'];
    QuizInfo bQuizInfo = b['quizInfo'];
    double resultA = 0;
    double resultB = 0;
    if(aQuizInfo.quizTaken != 0 && bQuizInfo.quizTaken != 0){
      resultA = (aQuizInfo.correctAnswer / aQuizInfo.quizTaken) *
          100;
      resultB = (bQuizInfo.correctAnswer / bQuizInfo.quizTaken) *
          100;
    }else if(aQuizInfo.quizTaken != 0 ){
      resultA = (aQuizInfo.correctAnswer / aQuizInfo.quizTaken) *
          100;
    }
    else if(bQuizInfo.quizTaken != 0){
      resultB = (bQuizInfo.correctAnswer / bQuizInfo.quizTaken) *
          100;
    }
    return resultA == resultB;
  }

  @override
  void initState() {
    getMembersUidList();
    super.initState();
  }

  bool quizLeaderboardSelected = false;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
          children: [
            Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: (){
                      setState((){
                        quizLeaderboardSelected = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: quizLeaderboardSelected? Colors.blue : Colors.green,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              "Help Point\nLeaderboard",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      setState((){
                        quizLeaderboardSelected = true;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: quizLeaderboardSelected? Colors.green : Colors.blue,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              "Quiz Result\nLeaderboard",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            quizLeaderboardSelected? Card(
      child: ListView(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Rank",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      width: 40,
                      height: 40,
                      // child: Center(
                      //   child: userBasicInfo!.profileImageUrl.isEmpty
                      //       ? CircleAvatar(
                      //     radius: 20,
                      //     backgroundImage: userBasicInfo!
                      //         .gender ==
                      //         "Male"
                      //         ? const AssetImage(
                      //         'assets/male_profile_image.png')
                      //         : const AssetImage(
                      //       'assets/female_profile_image.png',
                      //     ),
                      //     // child: ClipOval(
                      //     //   child: widget.userBasicInfo.gender == "Male"
                      //     //       ? Image.asset(
                      //     //           "assets/male_profile_image.png",
                      //     //           fit: BoxFit.fill,
                      //     //         )
                      //     //       : Image.asset(
                      //     //           "assets/female_profile_image.png",
                      //     //           fit: BoxFit.fill,
                      //     //         ),
                      //     // ),
                      //   )
                      //       : CircleAvatar(
                      //     radius: 20,
                      //     // child: ClipOval(
                      //     //   child: Image.network(
                      //     //     widget.userBasicInfo.profileImageUrl,
                      //     //     fit: BoxFit.fill,
                      //     //   ),
                      //     // ),
                      //     backgroundImage: NetworkImage(
                      //         userBasicInfo!.profileImageUrl),
                      //   ),
                      // ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2.2,
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      // decoration: BoxDecoration(
                      //   color: Colors.black,
                      // ),
                      child: const Text(
                        "Member Name",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Text(
                      "Quiz\nResult",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: membersHelpPointMapList.length,
                physics: const ScrollPhysics(),
                itemBuilder: (context, index) => quizResultRankingLayout(membersQuizMapList[index]),),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     SizedBox(
              //       width: 40,
              //       height: 40,
              //       child: Center(
              //         child: userBasicInfo!.profileImageUrl.isEmpty
              //             ? CircleAvatar(
              //           radius: 20,
              //           backgroundImage: userBasicInfo!
              //               .gender ==
              //               "Male"
              //               ? const AssetImage(
              //               'assets/male_profile_image.png')
              //               : const AssetImage(
              //             'assets/female_profile_image.png',
              //           ),
              //           // child: ClipOval(
              //           //   child: widget.userBasicInfo.gender == "Male"
              //           //       ? Image.asset(
              //           //           "assets/male_profile_image.png",
              //           //           fit: BoxFit.fill,
              //           //         )
              //           //       : Image.asset(
              //           //           "assets/female_profile_image.png",
              //           //           fit: BoxFit.fill,
              //           //         ),
              //           // ),
              //         )
              //             : CircleAvatar(
              //           radius: 20,
              //           // child: ClipOval(
              //           //   child: Image.network(
              //           //     widget.userBasicInfo.profileImageUrl,
              //           //     fit: BoxFit.fill,
              //           //   ),
              //           // ),
              //           backgroundImage: NetworkImage(
              //               userBasicInfo!.profileImageUrl),
              //         ),
              //       ),
              //     ),
              //
              //     Container(
              //       width: MediaQuery.of(context).size.width /1.5,
              //       padding: const EdgeInsets.all(10),
              //       alignment: Alignment.centerLeft,
              //       child: Text(
              //         widget.answer.answer,
              //         style: const TextStyle(
              //           color: Colors.black,
              //           fontWeight: FontWeight.normal,
              //           fontSize: 16,
              //         ),
              //         textAlign: TextAlign.left,
              //       ),
              //     ),
              //     Column(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         InkWell(onTap: (){setHelpPoint(true);},child: const Icon(Icons.keyboard_arrow_up_sharp, size: 30,)),
              //         Text(
              //           "${widget.answer.helpPoint}",
              //           style: const TextStyle(
              //             color: Colors.blue,
              //             fontSize: 18,
              //             fontWeight: FontWeight.bold,
              //           ),
              //           textAlign: TextAlign.center,
              //         ),
              //         InkWell(onTap: (){setHelpPoint(false);},child: const Icon(Icons.keyboard_arrow_down_sharp, size: 30,)),
              //       ],
              //     )
              //   ],
              // )
            ],
      ),
    ) :Card(
                child: ListView(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Rank",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            width: 40,
                            height: 40,
                            // child: Center(
                            //   child: userBasicInfo!.profileImageUrl.isEmpty
                            //       ? CircleAvatar(
                            //     radius: 20,
                            //     backgroundImage: userBasicInfo!
                            //         .gender ==
                            //         "Male"
                            //         ? const AssetImage(
                            //         'assets/male_profile_image.png')
                            //         : const AssetImage(
                            //       'assets/female_profile_image.png',
                            //     ),
                            //     // child: ClipOval(
                            //     //   child: widget.userBasicInfo.gender == "Male"
                            //     //       ? Image.asset(
                            //     //           "assets/male_profile_image.png",
                            //     //           fit: BoxFit.fill,
                            //     //         )
                            //     //       : Image.asset(
                            //     //           "assets/female_profile_image.png",
                            //     //           fit: BoxFit.fill,
                            //     //         ),
                            //     // ),
                            //   )
                            //       : CircleAvatar(
                            //     radius: 20,
                            //     // child: ClipOval(
                            //     //   child: Image.network(
                            //     //     widget.userBasicInfo.profileImageUrl,
                            //     //     fit: BoxFit.fill,
                            //     //   ),
                            //     // ),
                            //     backgroundImage: NetworkImage(
                            //         userBasicInfo!.profileImageUrl),
                            //   ),
                            // ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2.2,
                            padding: const EdgeInsets.all(10),
                            alignment: Alignment.centerLeft,
                            // decoration: BoxDecoration(
                            //   color: Colors.black,
                            // ),
                            child: const Text(
                              "Member Name",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Text(
                            "Help\nPoint",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: membersHelpPointMapList.length,
                      physics: const ScrollPhysics(),
                      itemBuilder: (context, index) => helpPointRankingLayout(membersHelpPointMapList[index]),),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     SizedBox(
                    //       width: 40,
                    //       height: 40,
                    //       child: Center(
                    //         child: userBasicInfo!.profileImageUrl.isEmpty
                    //             ? CircleAvatar(
                    //           radius: 20,
                    //           backgroundImage: userBasicInfo!
                    //               .gender ==
                    //               "Male"
                    //               ? const AssetImage(
                    //               'assets/male_profile_image.png')
                    //               : const AssetImage(
                    //             'assets/female_profile_image.png',
                    //           ),
                    //           // child: ClipOval(
                    //           //   child: widget.userBasicInfo.gender == "Male"
                    //           //       ? Image.asset(
                    //           //           "assets/male_profile_image.png",
                    //           //           fit: BoxFit.fill,
                    //           //         )
                    //           //       : Image.asset(
                    //           //           "assets/female_profile_image.png",
                    //           //           fit: BoxFit.fill,
                    //           //         ),
                    //           // ),
                    //         )
                    //             : CircleAvatar(
                    //           radius: 20,
                    //           // child: ClipOval(
                    //           //   child: Image.network(
                    //           //     widget.userBasicInfo.profileImageUrl,
                    //           //     fit: BoxFit.fill,
                    //           //   ),
                    //           // ),
                    //           backgroundImage: NetworkImage(
                    //               userBasicInfo!.profileImageUrl),
                    //         ),
                    //       ),
                    //     ),
                    //
                    //     Container(
                    //       width: MediaQuery.of(context).size.width /1.5,
                    //       padding: const EdgeInsets.all(10),
                    //       alignment: Alignment.centerLeft,
                    //       child: Text(
                    //         widget.answer.answer,
                    //         style: const TextStyle(
                    //           color: Colors.black,
                    //           fontWeight: FontWeight.normal,
                    //           fontSize: 16,
                    //         ),
                    //         textAlign: TextAlign.left,
                    //       ),
                    //     ),
                    //     Column(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         InkWell(onTap: (){setHelpPoint(true);},child: const Icon(Icons.keyboard_arrow_up_sharp, size: 30,)),
                    //         Text(
                    //           "${widget.answer.helpPoint}",
                    //           style: const TextStyle(
                    //             color: Colors.blue,
                    //             fontSize: 18,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //           textAlign: TextAlign.center,
                    //         ),
                    //         InkWell(onTap: (){setHelpPoint(false);},child: const Icon(Icons.keyboard_arrow_down_sharp, size: 30,)),
                    //       ],
                    //     )
                    //   ],
                    // )
                  ],
                ),
              ),
          ],
        );
  }

  Widget helpPointRankingLayout(Map<String, dynamic> map){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: (){
                Fluttertoast.showToast(msg: map['rankHelpPoint'].toString());
              },
              child: Text(
                map['rankHelpPoint'].toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: map['basicInfo'].profileImageUrl.isEmpty
                    ? CircleAvatar(
                  radius: 20,
                  backgroundImage: map['basicInfo']
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
                      map['basicInfo'].profileImageUrl),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2.2,
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              // decoration: BoxDecoration(
              //   color: Colors.black,
              // ),
              child: Text(
                "${map['basicInfo'].firstName} ${map['basicInfo'].lastName}",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              "${map["helpPoint"]}",
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


  Widget quizResultRankingLayout(Map<String, dynamic> map){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: (){
                Fluttertoast.showToast(msg: map['rankQuiz'].toString());
              },
              child: Text(
                map['rankQuiz'].toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: map['basicInfo'].profileImageUrl.isEmpty
                    ? CircleAvatar(
                  radius: 20,
                  backgroundImage: map['basicInfo']
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
                      map['basicInfo'].profileImageUrl),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2.2,
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              // decoration: BoxDecoration(
              //   color: Colors.black,
              // ),
              child: Text(
                "${map['basicInfo'].firstName} ${map['basicInfo'].lastName}",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        map["quizInfo"].quizTaken != 0? Text(
              "${ ((map["quizInfo"].correctAnswer / map["quizInfo"].quizTaken) *
                  100).toStringAsFixed(2)}%\n(${map["quizInfo"].quizTaken})",
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ): const Text(
          "0.00%\n(0)",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
          ],
        ),
      ),
    );
  }
}

