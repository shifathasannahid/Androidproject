import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/event_utils/event_details_page.dart';
import 'package:eventqc/event_utils/event_util.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../event_utils/approved_events_layout.dart';

class ApprovedEventsCommunityPage extends StatefulWidget {
  final DocumentReference communityReference;
  final UserBasicInfo userBasicInfo;

  const ApprovedEventsCommunityPage({
    Key? key,
    required this.communityReference,
    required this.userBasicInfo,
  }) : super(key: key);

  @override
  State<ApprovedEventsCommunityPage> createState() =>
      _ApprovedEventsCommunityPageState();
}

class _ApprovedEventsCommunityPageState
    extends State<ApprovedEventsCommunityPage> {
  List<Event> approvedEventsList = [];
  bool isLoading = true;




  Future<void> getApprovedEventsList() async {
    approvedEventsList.clear();
    await widget.communityReference
        .collection("ApprovedEvents")
        .get()
        .then((snapshot) {
      for (int index = 0; index < snapshot.size; index++) {
        Event event = Event.fromJson(snapshot.docs[index].data());
        approvedEventsList.add(event);
        setState(() {});
      }
    });

    isLoading = false;
    approvedEventsList.sort((a, b) {
      DateTime dateA = DateTime(int.parse(a.startDate.split("-").toList()[2]),int.parse(a.startDate.split("-").toList()[1]),int.parse(a.startDate.split("-").toList()[0]), int.parse(a.startTime.split(":").toList()[0]), int.parse(a.startTime.split(":").toList()[1].substring(0,2)));
      DateTime dateB = DateTime(int.parse(b.startDate.split("-").toList()[2]),int.parse(b.startDate.split("-").toList()[1]),int.parse(b.startDate.split("-").toList()[0]), int.parse(b.startTime.split(":").toList()[0]), int.parse(b.startTime.split(":").toList()[1].substring(0,2)));
      return dateB.compareTo(dateA);
    });
    // approvedEventsList.sort((a, b) => a.startDate.split("-").toList()[2].compareTo(b.startDate.split("-").toList()[2]));
    // approvedEventsList.sort((a, b) => a.startDate.split("-").toList()[1].compareTo(b.startDate.split("-").toList()[1]));
    // approvedEventsList.sort((a, b) => a.startDate.split("-").toList()[0].compareTo(b.startDate.split("-").toList()[0]));
    setState(() {});
  }

  @override
  void initState() {
    getApprovedEventsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      children: [
        NotificationListener<OverscrollNotification>(
          onNotification: (notification) =>
              notification.metrics.axisDirection != AxisDirection.down,
          child: SizedBox(
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : approvedEventsList.isEmpty
                    ? const Center(
                        child: Text("No events available"),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: approvedEventsList.length,
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return NotificationListener<OverscrollNotification>(
                            onNotification: (notification) =>
                                notification.metrics.axisDirection !=
                                AxisDirection.right,
                            child: ApprovedEventLayout(
                              event: approvedEventsList[index],
                              onRefresh: () async {
                                getApprovedEventsList();
                              },
                              onCancelRequest: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                try {
                                  await widget.communityReference
                                        .collection("ApprovedEvents")
                                        .doc(approvedEventsList[index].key)
                                        .collection("PendingMembers")
                                        .doc(widget.userBasicInfo.userUid).delete();
                                    Fluttertoast.showToast(
                                        msg: "Request canceled Successfully...");
                                    setState(() {
                                      isLoading = false;
                                    });
                                } on FirebaseException catch (e) {
                                  Fluttertoast.showToast(
                                      msg: "Something went wrong...");
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                              onJoin: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                try {

                                  int max = int.parse(approvedEventsList[index].maximumRegistration);
                                  int total = int.parse(approvedEventsList[index].totalRegistration);
                                  if(total < max || max == 0){
                                    await widget.communityReference
                                        .collection("ApprovedEvents")
                                        .doc(approvedEventsList[index].key)
                                        .collection("PendingMembers")
                                        .doc(widget.userBasicInfo.userUid).set({
                                      "userUid" : widget.userBasicInfo.userUid,

                                    });
                                    Fluttertoast.showToast(
                                        msg: "Joining Request Sent Successfully...");
                                    setState(() {
                                      isLoading = false;
                                    });

                                  }
                                  else{
                                    Fluttertoast.showToast(msg: "No seat available...");
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                } on FirebaseException catch (e) {
                                  Fluttertoast.showToast(
                                      msg: "Something went wrong...");
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                              onDelete: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                try {
                                  await widget.communityReference
                                      .collection("ApprovedEvents")
                                      .doc(approvedEventsList[index].key)
                                      .delete();
                                  Fluttertoast.showToast(
                                      msg: "Event Deleted Successfully...");
                                  getApprovedEventsList();
                                } on FirebaseException catch (e) {
                                  Fluttertoast.showToast(
                                      msg: "Something went wrong...");
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                              onClick: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailsPage(event: approvedEventsList[index], eventDocumentReference: widget.communityReference
                                    .collection("ApprovedEvents")
                                    .doc(approvedEventsList[index].key), userBasicInfo: widget.userBasicInfo)));
                              },
                              userBasicInfo: widget.userBasicInfo,
                            ),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }
}
