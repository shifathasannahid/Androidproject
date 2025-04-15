import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/event_utils/approved_events_layout.dart';
import 'package:eventqc/event_utils/event_util.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../event_utils/event_details_page.dart';

class EventLayoutHomePage extends StatefulWidget {
  final List<Event> eventList;
  final UserBasicInfo userBasicInfo;
  final Future<void> Function() onRefresh;
  final String notFoundText;
  const EventLayoutHomePage(
      {Key? key,
      required this.notFoundText,
      required this.eventList,
      required this.userBasicInfo,
      required this.onRefresh})
      : super(key: key);

  @override
  State<EventLayoutHomePage> createState() =>
      _EventLayoutHomePageState();
}

class _EventLayoutHomePageState extends State<EventLayoutHomePage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: MediaQuery.of(context).size.width,
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : widget.eventList.isEmpty
              ? Center(
                  child: Text(
                    widget.notFoundText,
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: widget.eventList.length,
                  scrollDirection: Axis.horizontal,
                  physics: const ScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ApprovedEventLayout(
                      event: widget.eventList[index],
                      onJoin: () async {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          int max = int.parse(
                              widget.eventList[index].maximumRegistration);
                          int total = int.parse(
                              widget.eventList[index].totalRegistration);
                          if (total < max || max == 0) {
                            await FirebaseFirestore.instance
                                .collection("Categories")
                                .doc(widget.eventList[index].categoryKey)
                                .collection("Communities")
                                .doc(widget.eventList[index].communityKey)
                                .collection("ApprovedEvents")
                                .doc(widget.eventList[index].key)
                                .collection("PendingMembers")
                                .doc(widget.userBasicInfo.userUid)
                                .set({
                              "userUid": widget.userBasicInfo.userUid,
                            });
                            Fluttertoast.showToast(
                                msg: "Joining Request Sent Successfully...");
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
                          await FirebaseFirestore.instance
                              .collection("Categories")
                              .doc(widget.eventList[index].categoryKey)
                              .collection("Communities")
                              .doc(widget.eventList[index].communityKey)
                              .collection("ApprovedEvents")
                              .doc(widget.eventList[index].key)
                              .delete();
                          Fluttertoast.showToast(
                              msg: "Event Deleted Successfully...");
                          widget.onRefresh();
                        } on FirebaseException catch (e) {
                          Fluttertoast.showToast(
                              msg: "Something went wrong...");
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      onRefresh: widget.onRefresh,
                      onClick: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EventDetailsPage(
                                    event: widget.eventList[index],
                                    eventDocumentReference: FirebaseFirestore
                                        .instance
                                        .collection("Categories")
                                        .doc(
                                            widget.eventList[index].categoryKey)
                                        .collection("Communities")
                                        .doc(widget
                                            .eventList[index].communityKey)
                                        .collection("ApprovedEvents")
                                        .doc(widget.eventList[index].key),
                                    userBasicInfo: widget.userBasicInfo)));
                      },
                      userBasicInfo: widget.userBasicInfo,
                      onCancelRequest: () async {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          await FirebaseFirestore.instance
                              .collection("Categories")
                              .doc(widget.eventList[index].categoryKey)
                              .collection("Communities")
                              .doc(widget.eventList[index].communityKey)
                              .collection("ApprovedEvents")
                              .doc(widget.eventList[index].key)
                              .collection("PendingMembers")
                              .doc(widget.userBasicInfo.userUid)
                              .delete();
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
                    );
                  },
                ),
    );
  }
}