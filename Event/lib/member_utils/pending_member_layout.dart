import 'package:eventqc/event_utils/event_util.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:flutter/material.dart';

class PendingMemberLayout extends StatefulWidget {
  final UserBasicInfo userBasicInfo;
  final void Function() onApprove;
  final void Function() onReject;
  final bool forCommunity;
  final Future<void> Function() onRefresh;
  const PendingMemberLayout(
      {Key? key,
      required this.userBasicInfo,
      required this.onApprove,
      required this.onReject,
      required this.onRefresh,
      required this.forCommunity})
      : super(key: key);

  @override
  State<PendingMemberLayout> createState() => _PendingMemberLayoutState();
}

class _PendingMemberLayoutState extends State<PendingMemberLayout> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: widget.userBasicInfo.profileImageUrl.isEmpty
                      ? CircleAvatar(
                          radius: 60,
                          backgroundImage: widget.userBasicInfo.gender == "Male"
                              ? const AssetImage(
                              'assets/male_profile_image.png')
                              : const AssetImage(
                              'assets/female_profile_image.png',),
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
                          radius: 60,
                          // child: ClipOval(
                          //   child: Image.network(
                          //     widget.userBasicInfo.profileImageUrl,
                          //     fit: BoxFit.fill,
                          //   ),
                          // ),
                          backgroundImage: NetworkImage(widget.userBasicInfo.profileImageUrl),
                        ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    "${widget.userBasicInfo.firstName} ${widget.userBasicInfo.lastName}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                widget.forCommunity ? Container() : const SizedBox(
                  height: 10,
                ),
                widget.forCommunity ? Container() : Center(
                  child: Text(
                    widget.userBasicInfo.email,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                widget.forCommunity ? Container() : const SizedBox(
                  height: 10,
                ),
                widget.forCommunity ? Container() : Center(
                  child: Text(
                    widget.userBasicInfo.phone,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                widget.forCommunity ? Container() : const SizedBox(
                  height: 10,
                ),
                widget.forCommunity ? Container() : Center(
                  child: Text(
                    widget.userBasicInfo.gender,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                widget.forCommunity ? Container() : const SizedBox(
                  height: 10,
                ),
                widget.forCommunity ? Container() : Center(
                  child: Text(
                    widget.userBasicInfo.dateOfBirth,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                TextButton(
                  onPressed: () {
                    widget.onApprove();
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
                        'Approve',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onReject();
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
                        'Reject',
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
        ),
      ),
    );
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
}
