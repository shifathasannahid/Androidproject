import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/community_utils/answers_page.dart';
import 'package:eventqc/community_utils/discussion_util.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DiscussionLayout extends StatefulWidget {
  final Discussion discussion;
  final DocumentReference discussionReference;
  final bool isModerator;
  final bool isAdmin;
  final String viewerUid;
  const DiscussionLayout(
      {Key? key,
      required this.discussion,
      required this.discussionReference,
      required this.isModerator,
      required this.isAdmin,
      required this.viewerUid})
      : super(key: key);

  @override
  State<DiscussionLayout> createState() => _DiscussionLayoutState();
}

class _DiscussionLayoutState extends State<DiscussionLayout> {
  bool isLoading = true;
  UserBasicInfo? publisherBasicInfo;
  bool answerSelected = false;

  Future<void> getPublisherBasicInfo() async {
    String userUid = widget.discussion.publisherUid;
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userUid)
        .collection("BasicInfo")
        .doc(userUid)
        .get()
        .then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        publisherBasicInfo = UserBasicInfo.fromJson(value.data()!);
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    getPublisherBasicInfo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   widget.discussion.problemTitle,
                  //   style: const TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black,
                  //   ),
                  // ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  publisherBasicInfo == null
                      ? Container()
                      : Row(
                          children: [
                            Center(
                              child: publisherBasicInfo!.profileImageUrl.isEmpty
                                  ? CircleAvatar(
                                      radius: 25,
                                      backgroundImage: publisherBasicInfo!
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
                                      radius: 25,
                                      // child: ClipOval(
                                      //   child: Image.network(
                                      //     widget.userBasicInfo.profileImageUrl,
                                      //     fit: BoxFit.fill,
                                      //   ),
                                      // ),
                                      backgroundImage: NetworkImage(
                                          publisherBasicInfo!.profileImageUrl),
                                    ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 90,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "${publisherBasicInfo!.firstName} ${publisherBasicInfo!.lastName} ",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: "published a problem.",
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          "\n${getTime(widget.discussion.publishTime)}\n${getDate(widget.discussion.publishDate)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                  widget.discussion.isSolved == "true"
                      ? const SizedBox(
                          height: 10,
                        )
                      : Container(),
                  widget.discussion.isSolved == "true"
                      ? const Center(
                        child: Text(
                            "(SOLVED)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      )
                      : Container(),
                  widget.discussion.isPined == "true"
                      ? widget.discussion.isSolved == "true"
                          ? Container()
                          : const SizedBox(
                              height: 10,
                            )
                      : Container(),
                  widget.discussion.isPined == "true"
                      ? widget.discussion.isSolved == "true"
                          ? Container()
                          : const Center(
                            child: Text(
                                "(IMPORTANT)",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                          )
                      : Container(),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.discussion.problemTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    widget.discussion.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 1,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        answerSelected = !answerSelected;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            answerSelected ? Colors.blue : Colors.transparent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.comment,
                              color:
                                  answerSelected ? Colors.white : Colors.black,
                            ),
                            Text(
                              "  Answers",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: answerSelected
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  widget.isAdmin || widget.isModerator
                      ? widget.discussion.isSolved == "true"
                          ? Container()
                          : Container(
                              height: 1,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                              ),
                            )
                      : Container(),
                  widget.isAdmin || widget.isModerator
                      ? widget.discussion.isSolved == "true"
                          ? Container()
                          : widget.discussion.isPined == "true"
                              ? InkWell(
                                  onTap: unpinDiscussion,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.label_important_outline,
                                          color: Colors.black,
                                        ),
                                        Text(
                                          "  Mark as not important",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: pinDiscussion,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.label_important,
                                          color: Colors.black,
                                        ),
                                        Text(
                                          "  Mark as important",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                      : Container(),
                  widget.isAdmin ||
                          widget.isModerator ||
                          widget.viewerUid == widget.discussion.publisherUid
                      ? widget.discussion.isSolved == "true"
                          ? Container()
                          : Container(
                              height: 1,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                              ),
                            )
                      : Container(),
                  widget.isAdmin ||
                          widget.isModerator ||
                          widget.viewerUid == widget.discussion.publisherUid
                      ? widget.discussion.isSolved == "true"
                          ? Container()
                          : InkWell(
                              onTap: solvedDiscussion,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.check,
                                      color: Colors.black,
                                    ),
                                    Text(
                                      "  Mark as solved",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                      : Container(),
                  widget.isAdmin || widget.isModerator
                      ? Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                          ),
                        )
                      : Container(),

                  widget.isAdmin || widget.isModerator
                      ? InkWell(
                          onTap: deleteDiscussion,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.delete,
                                  color: Colors.black,
                                ),
                                Text(
                                  "  Delete",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    height: 1,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                    ),
                  ),
                  answerSelected
                      ? AnswerPage(
                          discussionReference: widget.discussionReference,
                          communityUid: widget.discussion.communityKey,
                        )
                      : Container(),
                ],
              ),
      ),
    );
  }

  String getTime(String time) {
    int hour = int.parse(time.split(":").toList()[0]);
    int minute = int.parse(time.split(":").toList()[1]);
    String meridian = "AM";
    if (hour / 12 > 1) {
      hour = hour % 12;
      meridian = "PM";
    }
    if (hour / 12 == 1) {
      meridian = "PM";
    }
    if (hour == 0) {
      hour = 12;
      meridian = "AM";
    }
    String hourString = hour.toString();
    String minuteString = minute.toString();
    if (hour / 10 < 1) {
      hourString = "0$hourString";
    }
    if (minute / 10 < 1) {
      minuteString = "0$minuteString";
    }
    return "$hourString:$minuteString $meridian";
  }

  String getDate(String date) {
    String month = "";
    int i = int.parse(date.split("-").toList()[1]);
    if (i == 1) {
      month = "January";
    } else if (i == 2) {
      month = "February";
    } else if (i == 3) {
      month = "March";
    } else if (i == 4) {
      month = "April";
    } else if (i == 5) {
      month = "May";
    } else if (i == 6) {
      month = "June";
    } else if (i == 7) {
      month = "July";
    } else if (i == 8) {
      month = "August";
    } else if (i == 9) {
      month = "September";
    } else if (i == 10) {
      month = "October";
    } else if (i == 11) {
      month = "November";
    } else {
      month = "December";
    }
    return "${date.split("-").toList()[0]} $month, ${date.split("-").toList()[2]}";
  }

  Future<void> pinDiscussion() async {
    await widget.discussionReference.update({
      "isPined": "true",
    });
    setState(() {
      widget.discussion.isPined = "true";
    });
  }

  Future<void> unpinDiscussion() async {
    await widget.discussionReference.update({
      "isPined": "false",
    });
    setState(() {
      widget.discussion.isPined = "false";
    });
  }

  Future<void> solvedDiscussion() async {
    await widget.discussionReference.update({
      "isSolved": "true",
      "isPined": "false",
    });
    setState(() {
      widget.discussion.isSolved = "true";
      widget.discussion.isPined = "false";
    });
  }

  Future<void> deleteDiscussion() async {
    await widget.discussionReference.delete().whenComplete(() {
      Fluttertoast.showToast(msg: "Deleted Successfully");
    });
  }
}
