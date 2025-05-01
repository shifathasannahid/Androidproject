import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/community_utils/community_util.dart';
import 'package:eventqc/community_utils/discussions_page.dart';
import 'package:eventqc/community_utils/events_page.dart';
import 'package:eventqc/community_utils/leaderboard_page.dart';
import 'package:eventqc/community_utils/members_page.dart';
import 'package:eventqc/community_utils/pending_events_page.dart';
import 'package:eventqc/community_utils/pending_members_page.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommunityPage extends StatefulWidget {
  final Community community;
  final DocumentReference communityReference;
  final UserBasicInfo userBasicInfo;
  const CommunityPage(
      {Key? key,
      required this.community,
      required this.communityReference,
      required this.userBasicInfo})
      : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  int currentWidgetNumber = 0;
  int pendingEventsCount = 0;
  int activeEventsCount = 0;
  int pendingMembersCount = 0;
  int approvedMembersCount = 0;
  bool isLoading = false;
  final ScrollController scrollController = ScrollController();

  Future<void> getPendingMembersCount() async {
    widget.communityReference
        .collection("PendingMembers")
        .snapshots()
        .listen((event) {
          if(!mounted){
            return;
          }
      setState(() {
        pendingMembersCount = event.size;
      });
    });
  }

  Future<void> getApprovedMembersCount() async {
    widget.communityReference
        .collection("ApprovedMembers")
        .snapshots()
        .listen((event) {
      setState(() {
        approvedMembersCount = event.size;
      });
    });
  }

  Future<void> getPendingEventCount() async {
    widget.communityReference
        .collection("PendingEvents")
        .snapshots()
        .listen((event) {
          if(mounted){
            setState(() {
              pendingEventsCount = event.size;
            });
          }

    });
  }

  Future<void> getActiveEventCount() async {
    widget.communityReference
        .collection("ApprovedEvents")
        .snapshots()
        .listen((event) {
      setState(() {
        activeEventsCount = event.size;
      });
    });
  }

  bool isJoined = false;
  bool requestSent = false;

  Future<void> getJoinedMember() async {
    widget.communityReference
        .collection("ApprovedMembers")
        .doc(widget.userBasicInfo.userUid)
        .snapshots()
        .listen((snapshot) {
          if(mounted){
            setState(() {
              isJoined = snapshot.exists;
            });
          }

    });
  }

  Future<void> getSentRequest() async {
    widget.communityReference
        .collection("PendingMembers")
        .doc(widget.userBasicInfo.userUid)
        .snapshots()
        .listen((snapshot) {
          if(mounted){
            setState(() {
              requestSent = snapshot.exists;
            });
          }

    });
  }
  bool isModerator = false;
  Future<void> getModeratorInfo() async {
    widget.communityReference
        .collection("Moderators")
        .doc(widget.userBasicInfo.userUid)
        .snapshots()
        .listen((event) {
          if(mounted){
            setState(() {
              isModerator = event.exists;
            });
          }

    });
  }

  @override
  void initState() {
    getJoinedMember();
    getSentRequest();
    getPendingEventCount();
    getActiveEventCount();
    getPendingMembersCount();
    getApprovedMembersCount();
    getModeratorInfo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.community.name),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
        controller: scrollController,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.cyanAccent,
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      widget.community.coverImageUrl,
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
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    widget.community.description,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Members: $approvedMembersCount\nCreated on: ${getDate(
                      widget.community.creationDate,
                      0,
                      false,
                    )} ${getDate(widget.community.creationDate, 1, true)}, ${getDate(widget.community.creationDate, 2, false)}",
                    style: Theme.of(context).textTheme.titleMedium,
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
                isJoined ||
                        widget.userBasicInfo.userType == "Admin" ||
                        widget.userBasicInfo.userType == "Moderator" || isModerator
                    ? Center(
                      child: SingleChildScrollView(
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
                                      "Discussions",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: currentWidgetNumber == 0
                                            ? Colors.black
                                            : Colors.blue,
                                      ),
                                    ),
                                  ),
                                  widget.userBasicInfo.userType == "Admin" ||
                                          widget.userBasicInfo.userType ==
                                              "Moderator" || isModerator
                                      ? const SizedBox(
                                          width: 20,
                                        )
                                      : Container(),
                                  widget.userBasicInfo.userType == "Admin" ||
                                          widget.userBasicInfo.userType ==
                                              "Moderator" || isModerator
                                      ? InkWell(
                                          onTap: () {
                                            currentWidgetNumber = 1;
                                            setState(() {});
                                          },
                                          child: Text(
                                            "Pending Events($pendingEventsCount)",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: currentWidgetNumber == 1
                                                  ? Colors.black
                                                  : Colors.blue,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      currentWidgetNumber = 2;
                                      setState(() {});
                                    },
                                    child: Text(
                                      "Events($activeEventsCount)",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: currentWidgetNumber == 2
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
                                      currentWidgetNumber = 3;
                                      setState((){

                                      });
                                    },
                                    child: Text(
                                      "Leaderboard",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: currentWidgetNumber==3 ? Colors.black : Colors.blue,
                                      ),
                                    ),
                                  ),
                                  widget.userBasicInfo.userType == "Admin" ||
                                          widget.userBasicInfo.userType ==
                                              "Moderator" || isModerator
                                      ? const SizedBox(
                                          width: 20,
                                        )
                                      : Container(),
                                  widget.userBasicInfo.userType == "Admin" ||
                                          widget.userBasicInfo.userType ==
                                              "Moderator" || isModerator
                                      ? InkWell(
                                          onTap: () {
                                            currentWidgetNumber = 4;
                                            setState(() {});
                                          },
                                          child: Text(
                                            "Pending Members($pendingMembersCount)",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: currentWidgetNumber == 4
                                                  ? Colors.black
                                                  : Colors.blue,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      currentWidgetNumber = 5;
                                      setState(() {});
                                    },
                                    child: Text(
                                      "Members($approvedMembersCount)",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: currentWidgetNumber == 5
                                            ? Colors.black
                                            : Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    )
                    : Container(),
                const SizedBox(
                  height: 10,
                ),
                isJoined ||
                        widget.userBasicInfo.userType == "Admin" ||
                        widget.userBasicInfo.userType == "Moderator"
                    ? currentWidget()
                    : Container(),
              ],
            ),
    );
  }

  Widget currentWidget() {
    switch (currentWidgetNumber) {
      case 0:
        return discussionsWidget();
      case 1:
        return pendingEventsWidget();
      case 2:
        return eventsWidget();
      case 3:
        return leaderboardWidget();
      case 4:
        return pendingMembersWidget();
      case 5:
        return membersWidget();
      default:
        return discussionsWidget();
    }
  }

  Widget discussionsWidget() {
    return DiscussionsCommunityPage(community: widget.community, viewerBasicInfo: widget.userBasicInfo, communityReference: widget.communityReference, isModerator: isModerator, scrollController:  scrollController,);

  }

  Widget pendingEventsWidget() {
    return PendingEventsCommunityPage(
        communityReference: widget.communityReference);
  }

  Widget eventsWidget() {
    return ApprovedEventsCommunityPage(
      communityReference: widget.communityReference,
      userBasicInfo: widget.userBasicInfo,
    );
  }

  Widget leaderboardWidget() {
    return LeaderboardCommunityPage(membersReference: widget.communityReference.collection("ApprovedMembers"), communityUid: widget.community.key, community: widget.community,);
  }

  Widget pendingMembersWidget() {
    return PendingMembersCommunityPage(databaseReference: widget.communityReference, forCommunity: true, community: widget.community,);
  }

  Widget membersWidget() {
    return ApprovedMembersCommunityPage(databaseReference: widget.communityReference, viewerInfo: widget.userBasicInfo, forCommunity: true, community: widget.community,);
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
      await widget.communityReference
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
      await widget.communityReference
          .collection("PendingMembers")
          .doc(widget.userBasicInfo.userUid)
          .set({
        "userUid": widget.userBasicInfo.userUid,
      });
      Fluttertoast.showToast(msg: "Joining Request Sent Successfully...");
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
}
