import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/community_utils/members_page.dart';
import 'package:eventqc/community_utils/pending_members_page.dart';
import 'package:eventqc/event_utils/event_util.dart';
import 'package:eventqc/event_utils/load_live_link.dart';
import 'package:eventqc/event_utils/play_video_from_link.dart';
import 'package:eventqc/event_utils/updateRecordedVideoLink.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../user_utils/user_basic_info_util.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;
  final DocumentReference eventDocumentReference;
  final UserBasicInfo userBasicInfo;
  const EventDetailsPage(
      {Key? key,
      required this.event,
      required this.eventDocumentReference,
      required this.userBasicInfo})
      : super(key: key);

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  int currentWidgetNumber = 0;

  bool isJoined = false;
  bool requestSent = false;
  bool isLoading = false;
  int pendingMembersCount = 0;
  int approvedMembersCount = 0;

  Future<void> getPendingMembersCount() async {
    widget.eventDocumentReference
        .collection("PendingMembers")
        .snapshots()
        .listen((event) {
      setState(() {
        pendingMembersCount = event.size;
      });
    });
  }

  Future<void> getApprovedMembersCount() async {
    widget.eventDocumentReference
        .collection("ApprovedMembers")
        .snapshots()
        .listen((event) {
      setState(() {
        approvedMembersCount = event.size;
      });
    });
  }

  Future<void> getJoinedMember() async {
    FirebaseFirestore.instance
        .collection("Categories")
        .doc(widget.event.categoryKey)
        .collection("Communities")
        .doc(widget.event.communityKey)
        .collection("ApprovedEvents")
        .doc(widget.event.key)
        .collection("ApprovedMembers")
        .doc(widget.userBasicInfo.userUid)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        isJoined = snapshot.exists;
      });
    });
  }

  Future<void> getSentRequest() async {
    FirebaseFirestore.instance
        .collection("Categories")
        .doc(widget.event.categoryKey)
        .collection("Communities")
        .doc(widget.event.communityKey)
        .collection("ApprovedEvents")
        .doc(widget.event.key)
        .collection("PendingMembers")
        .doc(widget.userBasicInfo.userUid)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        requestSent = snapshot.exists;
      });
    });
  }

  Future<void> getTotalRegistration() async{
    FirebaseFirestore.instance
        .collection("Categories")
        .doc(widget.event.categoryKey)
        .collection("Communities")
        .doc(widget.event.communityKey)
        .collection("ApprovedEvents")
        .doc(widget.event.key).snapshots().listen((event) {
          setState((){
            widget.event.totalRegistration = event['totalRegistration'];
          });
    });
  }

  @override
  void initState() {
    getTotalRegistration();
    getJoinedMember();
    getSentRequest();
    getTotalRegistration();
    getPendingMembersCount();
    getApprovedMembersCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                Stack(
                  alignment: AlignmentDirectional.topStart,
                  fit: StackFit.passthrough,
                  clipBehavior: Clip.none,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        widget.event.coverImageUrl,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: -70.0,
                      left: 15.0,
                      child: Card(
                        elevation: 15,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xfffd9f1b),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15)),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      getDate(widget.event.startDate, 1, true),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      getDate(widget.event.startDate, 0, false),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15)),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      getDate(widget.event.startDate, 2, false),
                                      style: const TextStyle(
                                        color: Color(0xfffd9f1b),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      bottom: -20,
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: widget.event.eventType == "PAID"
                              ? Colors.red
                              : const Color(0xfffd9f1b),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: Text(
                            widget.event.eventType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30,),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width/2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 20, 20),
                      child: Text(
                        widget.event.communityName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    widget.event.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20.0,
                    0,
                    20,
                    5,
                  ),
                  child: Text(
                    "Published on: ${widget.event.publishDate.split("/").toList()[1]}, ${getDate(widget.event.publishDate.split("/").toList()[0], 0, false)} ${getDate(widget.event.publishDate.split("/").toList()[0], 1, true)}, ${getDate(widget.event.publishDate.split("/").toList()[0], 2, false)}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                  child: Text(
                    "Published by: ${widget.event.publisherName}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                  child: Text(
                    "Community: ${widget.event.communityName}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                  child: Text(
                    "Contact number: ${widget.event.publicContactNumber}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                  child: Text(
                    "Event location: ${widget.event.location}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                  child: int.parse(widget.event.maximumRegistration) == 0
                      ? Text(
                          "Registration: ${widget.event.totalRegistration}/∞",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        )
                      : Text(
                          "Registration: ${widget.event.totalRegistration}/${widget.event.maximumRegistration}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                ),
                widget.event.eventType == "PAID"
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                        child: Text(
                          "Registration Fee: ${widget.event.registrationFee} TK",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                  child: Text(
                    "Event format: ${widget.event.eventFormat}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoadLiveLink(liveLinkUrl: widget.event.liveEventLink, eventName: widget.event.title,),),);
                  },
                  child: widget.event.eventFormat == "ONLINE" && isJoined
                      ? const Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                          child: Text(
                            "Live event: Click here to view",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        )
                      : Container(),
                ),
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PlayVideoFromLink(videoUrl: widget.event.recordedEventLink)));
                  },
                  child: widget.event.recordedEventLink.isNotEmpty && isJoined
                      ? const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                    child: Text(
                      "Recorded event: Click here to view",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  )
                      : Container(),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(20.0),
                //   child: Text(
                //     widget.event.title,
                //     style: const TextStyle(
                //       color: Colors.black,
                //       fontSize: 20,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 20),
                  child: Text(
                    "${widget.event.startTime} - ${widget.event.endTime}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 20),
                  child: SelectableText(
                    widget.event.description,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                isJoined
                    ? Container()
                    : requestSent
                        ? TextButton(
                            onPressed: () {
                              onCancelRequest();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width - 40,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text(
                                  'Cancel Joining Request',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : TextButton(
                            onPressed: () {
                              onJoin();
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
                                  'Join',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                widget.userBasicInfo.userType == "Admin" ||
                        widget.userBasicInfo.userType == "Moderator" ||
                        widget.event.publisherUid ==
                            widget.userBasicInfo.userUid
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Card(
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    currentWidgetNumber = 0;
                                    setState(() {});
                                  },
                                  child: Text(
                                    "Registered Members($approvedMembersCount)",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: currentWidgetNumber == 0
                                          ? Colors.black
                                          : Colors.blue,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    currentWidgetNumber = 1;
                                    setState(() {});
                                  },
                                  child: Text(
                                    "Pending Members($pendingMembersCount)",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: currentWidgetNumber == 1
                                          ? Colors.black
                                          : Colors.blue,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    currentWidgetNumber = 2;
                                    setState(() {});
                                  },
                                  child: Text(
                                    "Update Recorded Video",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: currentWidgetNumber == 2
                                          ? Colors.black
                                          : Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(),
                const SizedBox(
                  height: 10,
                ),
                widget.userBasicInfo.userType == "Admin" ||
                        widget.userBasicInfo.userType == "Moderator" ||
                        widget.event.publisherUid ==
                            widget.userBasicInfo.userUid
                    ? currentWidget()
                    : Container(),
              ],
            ),
    );
  }

  Widget currentWidget() {
    switch (currentWidgetNumber) {
      case 0:
        return registeredMembersWidget();
      case 1:
        return pendingMembersWidget();
      case 2:
        return updateRecordedVideo();
      default:
        return registeredMembersWidget();
    }
  }

  Widget registeredMembersWidget() {
    return ApprovedMembersCommunityPage(
      databaseReference: widget.eventDocumentReference,
      viewerInfo: widget.userBasicInfo,
      forCommunity: false,
    );
  }

  Widget pendingMembersWidget() {
    return PendingMembersCommunityPage(
      databaseReference: widget.eventDocumentReference,
      forCommunity: false,
      totalRegistration: int.parse(widget.event.totalRegistration),
      maximumRegistration: int.parse(widget.event.maximumRegistration),
      event: widget.event,
    );
  }

  Widget updateRecordedVideo() {
    return UpdateRecordedVideoLink(eventReference: widget.eventDocumentReference);
  }

  String getDate(String date, int position, bool isMonth) {
    if (isMonth) {
      int i = int.parse(date.split("-").toList()[position]);
      if (i == 1) {
        return "January";
      } else if (i == 2) {
        return "February";
      } else if (i == 3) {
        return "March";
      } else if (i == 4) {
        return "April";
      } else if (i == 5) {
        return "May";
      } else if (i == 6) {
        return "June";
      } else if (i == 7) {
        return "July";
      } else if (i == 8) {
        return "August";
      } else if (i == 9) {
        return "September";
      } else if (i == 10) {
        return "October";
      } else if (i == 11) {
        return "November";
      } else {
        return "December";
      }
    } else {
      return date.split("-").toList()[position];
    }
  }

  Future<void> onCancelRequest() async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection("Categories")
          .doc(widget.event.categoryKey)
          .collection("Communities")
          .doc(widget.event.communityKey)
          .collection("ApprovedEvents")
          .doc(widget.event.key)
          .collection("PendingMembers")
          .doc(widget.userBasicInfo.userUid)
          .delete();
      Fluttertoast.showToast(msg: "Request canceled Successfully...");
      setState(() {
        isLoading = false;
      });
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong...");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> onJoin() async {
    setState(() {
      isLoading = true;
    });
    try {
      int max = int.parse(widget.event.maximumRegistration);
      int total = int.parse(widget.event.totalRegistration);
      if (total < max || max == 0) {
        await FirebaseFirestore.instance
            .collection("Categories")
            .doc(widget.event.categoryKey)
            .collection("Communities")
            .doc(widget.event.communityKey)
            .collection("ApprovedEvents")
            .doc(widget.event.key)
            .collection("PendingMembers")
            .doc(widget.userBasicInfo.userUid)
            .set({
          "userUid": widget.userBasicInfo.userUid,
        });
        Fluttertoast.showToast(msg: "Joining Request Sent Successfully...");
        setState(() {
          isLoading = false;
        });
      } else {
        Fluttertoast.showToast(msg: "No seat available...");
        setState(() {
          isLoading = false;
        });
      }
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong...");
      setState(() {
        isLoading = false;
      });
    }
  }
}
