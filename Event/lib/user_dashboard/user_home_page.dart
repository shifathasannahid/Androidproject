import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventqc/community_utils/community_util.dart';
import 'package:eventqc/event_utils/event_util.dart';
import 'package:eventqc/user_dashboard/community_page.dart';
import 'package:eventqc/user_dashboard/create_community_page.dart';
import 'package:eventqc/user_dashboard/create_event_page.dart';
import 'package:eventqc/user_dashboard/my_community_home_page.dart';
import 'package:eventqc/user_dashboard/event_layout_home_page.dart';
import 'package:eventqc/user_dashboard/my_profile_page_home.dart';
import 'package:eventqc/user_dashboard/quiz_page.dart';
import 'package:eventqc/user_dashboard/users_list_page.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key}) : super(key: key);

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  bool disableEmailSend = false;
  int selectedIndex = 0;
  int heartRemains = 0;

  getQuizHeartCount(){
    FirebaseFirestore.instance.collection("Users").doc(userBasicInfo!.userUid).collection("QuizHearts").doc(userBasicInfo!.userUid).snapshots().listen((snapshot) {
      if(snapshot.exists){
        if(!mounted){
          return;
        }
        setState((){
          heartRemains = snapshot['heartRemains'];
        });
      }
      else{
        FirebaseFirestore.instance.collection("Users").doc(userBasicInfo!.userUid).collection("QuizHearts").doc(userBasicInfo!.userUid).set({
          "heartRemains" : 10,
          "lastDate" : null,
        });
      }
    });
  }

  Timer timer() {
    return Timer(const Duration(seconds: 60), timerWork);
  }

  Timer periodicTimer() {
    return Timer.periodic(const Duration(seconds: 2), (timer) {
      if (user!.emailVerified) {
        timer.cancel();
        setState(() {});
      }
    });
  }

  void timerWork() {
    disableEmailSend = false;
    setState(() {});
  }

  Future<void> sendEmailVerification() async {
    disableEmailSend = true;
    setState(() {});
    await user!.sendEmailVerification();
    Fluttertoast.showToast(msg: "Email verification sent...");
    timer();
  }

  Future<void> checkEmailVerification() async {
    if (user!.emailVerified) {
      setState(() {});
    } else {
      sendEmailVerification();
    }
  }

  UserBasicInfo? userBasicInfo;
  Future<void> getUserBasicInfo() async {
    if (user != null) {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(user!.uid)
          .collection("BasicInfo")
          .doc(user!.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          userBasicInfo = UserBasicInfo.fromJson(snapshot.data()!);
          if(!mounted){
            return;
          }
          setState(() {});
          getAllCommunities();
          getQuizHeartCount();
        }
      });
    }
  }

  List<Community> communitiesList = [];
  List<Community> myCommunitiesList = [];

  Future<void> getAllCommunities() async {
    communitiesList.clear();

    await FirebaseFirestore.instance
        .collection("Categories")
        .get()
        .then((snapshotCategory) {
      for (int i = 0; i < snapshotCategory.size; i++) {
        String categoryKey = snapshotCategory.docs[i].id;
        FirebaseFirestore.instance
            .collection("Categories")
            .doc(categoryKey)
            .collection("Communities")
            .get()
            .then((snapshot) {
          for (int index = 0; index < snapshot.size; index++) {
            Community community =
                Community.fromJson(snapshot.docs[index].data());
            communitiesList.add(community);
            setState(() {});
          }
        });
      }
    });
    getMyCommunities();
  }

  Future<void> getMyCommunities() async {
    myCommunitiesList.clear();

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userBasicInfo!.userUid)
        .collection("MyCommunities")
        .get()
        .then((snapshot) {
      for (int index = 0; index < snapshot.size; index++) {
        Community community = Community.fromJson(snapshot.docs[index].data());
        myCommunitiesList.add(community);
        setState(() {});
      }
    });
    getSuggestedCommunities();
  }

  List<Community> suggestedCommunityList = [];
  Future<void> getSuggestedCommunities() async {
    suggestedCommunityList.clear();
    List<String> keyList = [];
    List<String> containCommunityKeyList = [];
    for (Community community in myCommunitiesList) {
      if (!keyList.contains(community.categoryKey)) {
        keyList.add(community.categoryKey);
        setState(() {});
      }
      containCommunityKeyList.add(community.key);
    }

    for (String key in keyList) {
      FirebaseFirestore.instance
          .collection("Categories")
          .doc(key)
          .collection("Communities")
          .get()
          .then((snapshot) {
        for (int i = 0; i < snapshot.size; i++) {
          Community community = Community.fromJson(snapshot.docs[i].data());
          if (!containCommunityKeyList.contains(community.key)) {
            suggestedCommunityList.add(community);
            setState(() {});
          }
        }
      });
    }
    getEventsList();
  }

  List<Community> communityFilterList = [];
  bool hideDropdown = true;

  Future<void> filterCommunityByName(String? string) async {
    if (string == null || string.isEmpty) {
      communityFilterList = [];
    } else {
      communityFilterList = communitiesList
          .where((element) =>
              element.name.toUpperCase().startsWith(string.toUpperCase()))
          .toList();
    }
    setState(() {
      hideDropdown = false;
    });
  }

  @override
  void initState() {
    user = auth.currentUser;
    if (user != null) {
      checkEmailVerification();
    }

    Timer.periodic(const Duration(seconds: 2), (timer) async {
      await user!.reload();
      if (user!.emailVerified) {
        timer.cancel();
      }
    });

    getUserBasicInfo();

    searchController.addListener(() {
      filterCommunityByName(searchController.text);
    });
    super.initState();
  }

  bool showSearchBar = false;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: showExitAppPopup,
      child: Scaffold(
        appBar: appBarByIndex(),
        // AppBar(
        //   title: selectedIndex == 0
        //       ? Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             showSearchBar
        //                 ? Container()
        //                 : const Text(
        //                     "EventQc",
        //                   ),
        //             showSearchBar
        //                 ? SizedBox(
        //                     width: MediaQuery.of(context).size.width - 100,
        //                     child: TextFormField(
        //                       controller: searchController,
        //                       style: const TextStyle(
        //                         color: Colors.white,
        //                       ),
        //                       decoration: InputDecoration(
        //                         prefixIcon: const Icon(
        //                           Icons.search,
        //                           color: Colors.white,
        //                         ),
        //                         hintText: "Search community",
        //                         hintStyle: const TextStyle(
        //                           color: Colors.white,
        //                         ),
        //                         suffixIcon: InkWell(
        //                           onTap: () {
        //                             setState(() {
        //                               showSearchBar = false;
        //                               hideDropdown = true;
        //                               searchController.text = "";
        //                             });
        //                           },
        //                           child: const Icon(
        //                             Icons.close,
        //                             color: Colors.white,
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                   )
        //                 : InkWell(
        //                     onTap: () {
        //                       setState(() {
        //                         showSearchBar = true;
        //                       });
        //                     },
        //                     child: const Icon(Icons.search),
        //                   ),
        //           ],
        //         )
        //       : const Text("EventQc"),
        //   centerTitle: true,
        // ),
        drawer: userBasicInfo == null
            ? null
            : userBasicInfo!.userType == "Admin" ||
                    userBasicInfo!.userType == "Moderator"
                ? Drawer(
                    child: ListView(
                      children: [
                        UserAccountsDrawerHeader(
                          accountName: Text(
                              "${userBasicInfo!.firstName} ${userBasicInfo!.lastName}"),
                          accountEmail: Text(userBasicInfo!.email),
                          currentAccountPicture: userBasicInfo!
                                  .profileImageUrl.isEmpty
                              ? CircleAvatar(
                                  radius: 80,
                                  backgroundImage: userBasicInfo!.gender == "Male"
                                      ? const AssetImage(
                                          'assets/male_profile_image.png')
                                      : const AssetImage(
                                          'assets/female_profile_image.png'),
                                )
                              : CircleAvatar(
                                  radius: 80,
                                  backgroundImage: NetworkImage(
                                      userBasicInfo!.profileImageUrl),
                                ),

                          // currentAccountPicture: Center(
                          //   child: CachedNetworkImage(
                          //     imageUrl: tutor.personalDetails.profilePictureUrl,
                          //     height: 140,
                          //     width: 140,
                          //     placeholder: (context, url) => CircularProgressIndicator(),
                          //     errorWidget: (context, url, error) => Icon(Icons.error),
                          //   ),
                          //   // CircleAvatar(
                          //   //   radius: 80,
                          //   //   backgroundImage: NetworkImage(tutor.personalDetails.profilePictureUrl),
                          //   // ),
                          // ),,
                        ),
                        ListTile(
                          onTap: () {
                            Future.delayed(Duration.zero, () {
                              Navigator.pop(context);
                            });
                            Future.delayed(Duration.zero, () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateCommunityPage()));
                            });
                          },
                          title: const Text(
                            "Create Community",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const UsersListPage()));
                          },
                          title: const Text(
                            "Users",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
        body: userBasicInfo == null
            ? const Center(child: CircularProgressIndicator())
            : user!.emailVerified
                ? currentWidget()
                : verifyEmailPage(),
        bottomNavigationBar: userBasicInfo == null
            ? null
            : !user!.emailVerified
                ? Container()
                : BottomNavigationBar(
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(
                          Icons.home,
                          size: 30,
                          color: Colors.black,
                        ),
                        label: "",
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(
                          Icons.event_available_sharp,
                          size: 30,
                          color: Colors.black,
                        ),
                        label: "",
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(
                          Icons.control_point_sharp,
                          size: 35,
                          color: Colors.black,
                        ),
                        label: "",
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(
                          Icons.emoji_objects_outlined,
                          size: 30,
                          color: Colors.black,
                        ),
                        label: "",
                      ),
                      BottomNavigationBarItem(
                        icon: userBasicInfo!.profileImageUrl.isEmpty
                            ? CircleAvatar(
                                radius: 20,
                                backgroundImage: userBasicInfo!.gender == "Male"
                                    ? const AssetImage(
                                        'assets/male_profile_image.png')
                                    : const AssetImage(
                                        'assets/female_profile_image.png'),
                              )
                            : CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    NetworkImage(userBasicInfo!.profileImageUrl),
                              ),

                        // icon: Icon(
                        //   Icons.account_circle,
                        //   size: 30,
                        //   color: Colors.black,
                        // ),
                        label: "",
                      ),
                    ],
                    type: BottomNavigationBarType.fixed,
                    currentIndex: selectedIndex,
                    onTap: (int index) {
                      selectedIndex = index;
                      setState(() {});
                    },
                  ),
      ),
    );
  }

  Widget currentWidget() {
    switch (selectedIndex) {
      case 0:
        return homeWidget();
      case 1:
        return eventWidget();
      case 2:
        return createEventWidget();
      case 3:
        return quizWidget();
      case 4:
        return profileWidget();
      // case 5:
      //   return createCommunityWidget();
      // case 6:
      //   return usersListWidget();
      default:
        return homeWidget();
    }
  }

  // Widget usersListWidget(){
  //   return const Center(child: Text("Users List"),);
  // }

  // Widget createCommunityWidget(){
  //   return const Center(child: Text("Create Community"),);
  // }
  List<Event> recommendedEventsList = [];
  List<Event> allEventsList = [];
  List<Event> joinedEventsList = [];
  List<Event> todaysEventsList = [];
  List<Event> upcomingEventsList = [];

  Future<void> getEventsList() async {
    recommendedEventsList.clear();
    joinedEventsList.clear();
    allEventsList.clear();
    todaysEventsList.clear();
    upcomingEventsList.clear();
    List<String> keysList = [];
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userBasicInfo!.userUid)
        .collection("JoinedEvents")
        .get()
        .then((snapshot) {
      for (int index = 0; index < snapshot.size; index++) {

        keysList.add(snapshot.docs[index].id);
        setState(() {});
      }
    });

    for(Community community in myCommunitiesList){
      FirebaseFirestore.instance
          .collection("Categories")
          .doc(community.categoryKey)
          .collection("Communities")
          .doc(community.key)
          .collection("ApprovedEvents")
          .get().then((snapshot){
         for(int i = 0; i < snapshot.size; i++){
           Event event = Event.fromJson(snapshot.docs[i].data());
           int day = int.parse(event.startDate.split("-").toList()[0]);
           int month = int.parse(event.startDate.split("-").toList()[1]);
           int year = int.parse(event.startDate.split("-").toList()[2]);
           DateTime now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
           DateTime eventDate = DateTime(year,month,day);
           if(now.isAfter(eventDate)){
             if(keysList.contains(event.key)){
               joinedEventsList.add(event);
               setState((){
                 joinedEventsList.sort((a, b) {
                   bool isAam = a.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
                   bool isBam = b.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
                   int hourA = int.parse(a.startTime.split(":").toList()[0]);
                   int hourB = int.parse(b.startTime.split(":").toList()[0]);
                   if(!isAam){
                     hourA = hourA + 12;
                   }
                   if(!isBam){
                     hourB = hourB +12;
                   }
                   DateTime dateA = DateTime(int.parse(a.startDate.split("-").toList()[2]),int.parse(a.startDate.split("-").toList()[1]),int.parse(a.startDate.split("-").toList()[0]), hourA, int.parse(a.startTime.split(":").toList()[1].substring(0,2)));
                   DateTime dateB = DateTime(int.parse(b.startDate.split("-").toList()[2]),int.parse(b.startDate.split("-").toList()[1]),int.parse(b.startDate.split("-").toList()[0]), hourB, int.parse(b.startTime.split(":").toList()[1].substring(0,2)));
                   return dateA.compareTo(dateB);
                 });
               });
             }
           }
           else if(now.isBefore(eventDate)){
             upcomingEventsList.add(event);
             setState((){
               upcomingEventsList.sort((a, b) {
               bool isAam = a.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
               bool isBam = b.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
               int hourA = int.parse(a.startTime.split(":").toList()[0]);
               int hourB = int.parse(b.startTime.split(":").toList()[0]);
               if(!isAam){
               hourA = hourA + 12;
               }
               if(!isBam){
               hourB = hourB +12;
               }
               DateTime dateA = DateTime(int.parse(a.startDate.split("-").toList()[2]),int.parse(a.startDate.split("-").toList()[1]),int.parse(a.startDate.split("-").toList()[0]), hourA, int.parse(a.startTime.split(":").toList()[1].substring(0,2)));
               DateTime dateB = DateTime(int.parse(b.startDate.split("-").toList()[2]),int.parse(b.startDate.split("-").toList()[1]),int.parse(b.startDate.split("-").toList()[0]), hourB, int.parse(b.startTime.split(":").toList()[1].substring(0,2)));
               return dateA.compareTo(dateB);
               });
             });
             if(!keysList.contains(event.key)){
               recommendedEventsList.add(event);
               setState((){
                 recommendedEventsList.sort((a, b) {
                   bool isAam = a.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
                   bool isBam = b.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
                   int hourA = int.parse(a.startTime.split(":").toList()[0]);
                   int hourB = int.parse(b.startTime.split(":").toList()[0]);
                   if(!isAam){
                     hourA = hourA + 12;
                   }
                   if(!isBam){
                     hourB = hourB +12;
                   }
                   DateTime dateA = DateTime(int.parse(a.startDate.split("-").toList()[2]),int.parse(a.startDate.split("-").toList()[1]),int.parse(a.startDate.split("-").toList()[0]), hourA, int.parse(a.startTime.split(":").toList()[1].substring(0,2)));
                   DateTime dateB = DateTime(int.parse(b.startDate.split("-").toList()[2]),int.parse(b.startDate.split("-").toList()[1]),int.parse(b.startDate.split("-").toList()[0]), hourB, int.parse(b.startTime.split(":").toList()[1].substring(0,2)));
                   return dateA.compareTo(dateB);
                 });
               });
             }
             if(keysList.contains(event.key)){
               joinedEventsList.add(event);
               setState((){
                 joinedEventsList.sort((a, b) {
                   bool isAam = a.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
                   bool isBam = b.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
                   int hourA = int.parse(a.startTime.split(":").toList()[0]);
                   int hourB = int.parse(b.startTime.split(":").toList()[0]);
                   if(!isAam){
                     hourA = hourA + 12;
                   }
                   if(!isBam){
                     hourB = hourB +12;
                   }
                   DateTime dateA = DateTime(int.parse(a.startDate.split("-").toList()[2]),int.parse(a.startDate.split("-").toList()[1]),int.parse(a.startDate.split("-").toList()[0]), hourA, int.parse(a.startTime.split(":").toList()[1].substring(0,2)));
                   DateTime dateB = DateTime(int.parse(b.startDate.split("-").toList()[2]),int.parse(b.startDate.split("-").toList()[1]),int.parse(b.startDate.split("-").toList()[0]), hourB, int.parse(b.startTime.split(":").toList()[1].substring(0,2)));
                   return dateA.compareTo(dateB);
                 });
               });
             }
           }
           else{
             todaysEventsList.add(event);
             setState((){
               todaysEventsList.sort((a, b) {
                 bool isAam = a.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
                 bool isBam = b.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
                 int hourA = int.parse(a.startTime.split(":").toList()[0]);
                 int hourB = int.parse(b.startTime.split(":").toList()[0]);
                 if(!isAam){
                   hourA = hourA + 12;
                 }
                 if(!isBam){
                   hourB = hourB +12;
                 }
                 DateTime dateA = DateTime(int.parse(a.startDate.split("-").toList()[2]),int.parse(a.startDate.split("-").toList()[1]),int.parse(a.startDate.split("-").toList()[0]), hourA, int.parse(a.startTime.split(":").toList()[1].substring(0,2)));
                 DateTime dateB = DateTime(int.parse(b.startDate.split("-").toList()[2]),int.parse(b.startDate.split("-").toList()[1]),int.parse(b.startDate.split("-").toList()[0]), hourB, int.parse(b.startTime.split(":").toList()[1].substring(0,2)));
                 return dateA.compareTo(dateB);
               });
             });
             if(!keysList.contains(event.key)){
               recommendedEventsList.add(event);
               setState((){
                 recommendedEventsList.sort((a, b) {
                   bool isAam = a.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
                   bool isBam = b.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
                   int hourA = int.parse(a.startTime.split(":").toList()[0]);
                   int hourB = int.parse(b.startTime.split(":").toList()[0]);
                   if(!isAam){
                     hourA = hourA + 12;
                   }
                   if(!isBam){
                     hourB = hourB +12;
                   }
                   DateTime dateA = DateTime(int.parse(a.startDate.split("-").toList()[2]),int.parse(a.startDate.split("-").toList()[1]),int.parse(a.startDate.split("-").toList()[0]), hourA, int.parse(a.startTime.split(":").toList()[1].substring(0,2)));
                   DateTime dateB = DateTime(int.parse(b.startDate.split("-").toList()[2]),int.parse(b.startDate.split("-").toList()[1]),int.parse(b.startDate.split("-").toList()[0]), hourB, int.parse(b.startTime.split(":").toList()[1].substring(0,2)));
                   return dateA.compareTo(dateB);
                 });
               });
             }
             if(keysList.contains(event.key)){
               joinedEventsList.add(event);
               setState((){
                 joinedEventsList.sort((a, b) {
                   bool isAam = a.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
                   bool isBam = b.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
                   int hourA = int.parse(a.startTime.split(":").toList()[0]);
                   int hourB = int.parse(b.startTime.split(":").toList()[0]);
                   if(!isAam){
                     hourA = hourA + 12;
                   }
                   if(!isBam){
                     hourB = hourB +12;
                   }
                   DateTime dateA = DateTime(int.parse(a.startDate.split("-").toList()[2]),int.parse(a.startDate.split("-").toList()[1]),int.parse(a.startDate.split("-").toList()[0]), hourA, int.parse(a.startTime.split(":").toList()[1].substring(0,2)));
                   DateTime dateB = DateTime(int.parse(b.startDate.split("-").toList()[2]),int.parse(b.startDate.split("-").toList()[1]),int.parse(b.startDate.split("-").toList()[0]), hourB, int.parse(b.startTime.split(":").toList()[1].substring(0,2)));
                   return dateA.compareTo(dateB);
                 });
               });
             }

           }
           // if(!keysList.contains(event.key)){
           //   recommendedEventsList.add(event);
           //   setState((){
           //     recommendedEventsList.sort((a, b) {
           //       bool isAam = a.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
           //       bool isBam = b.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
           //       int hourA = int.parse(a.startTime.split(":").toList()[0]);
           //       int hourB = int.parse(b.startTime.split(":").toList()[0]);
           //       if(!isAam){
           //         hourA = hourA + 12;
           //       }
           //       if(!isBam){
           //         hourB = hourB +12;
           //       }
           //       DateTime dateA = DateTime(int.parse(a.startDate.split("-").toList()[2]),int.parse(a.startDate.split("-").toList()[1]),int.parse(a.startDate.split("-").toList()[0]), hourA, int.parse(a.startTime.split(":").toList()[1].substring(0,2)));
           //       DateTime dateB = DateTime(int.parse(b.startDate.split("-").toList()[2]),int.parse(b.startDate.split("-").toList()[1]),int.parse(b.startDate.split("-").toList()[0]), hourB, int.parse(b.startTime.split(":").toList()[1].substring(0,2)));
           //       return dateA.compareTo(dateB);
           //     });
           //   });
           // }
           // else{
           //   joinedEventsList.add(event);
           //   setState((){
           //     joinedEventsList.sort((a, b) {
           //       bool isAam = a.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
           //       bool isBam = b.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
           //       int hourA = int.parse(a.startTime.split(":").toList()[0]);
           //       int hourB = int.parse(b.startTime.split(":").toList()[0]);
           //       if(!isAam){
           //         hourA = hourA + 12;
           //       }
           //       if(!isBam){
           //         hourB = hourB +12;
           //       }
           //       DateTime dateA = DateTime(int.parse(a.startDate.split("-").toList()[2]),int.parse(a.startDate.split("-").toList()[1]),int.parse(a.startDate.split("-").toList()[0]), hourA, int.parse(a.startTime.split(":").toList()[1].substring(0,2)));
           //       DateTime dateB = DateTime(int.parse(b.startDate.split("-").toList()[2]),int.parse(b.startDate.split("-").toList()[1]),int.parse(b.startDate.split("-").toList()[0]), hourB, int.parse(b.startTime.split(":").toList()[1].substring(0,2)));
           //       return dateA.compareTo(dateB);
           //     });
           //   });
           // }

           allEventsList.add(event);
           setState((){
             allEventsList.sort((a, b) {
               bool isAam = a.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
               bool isBam = b.startTime.split(":").toList()[1].split(" ").toList()[1].trim() == "AM";
               int hourA = int.parse(a.startTime.split(":").toList()[0]);
               int hourB = int.parse(b.startTime.split(":").toList()[0]);
               if(!isAam){
                 hourA = hourA + 12;
               }
               if(!isBam){
                 hourB = hourB +12;
               }
               DateTime dateA = DateTime(int.parse(a.startDate.split("-").toList()[2]),int.parse(a.startDate.split("-").toList()[1]),int.parse(a.startDate.split("-").toList()[0]), hourA, int.parse(a.startTime.split(":").toList()[1].substring(0,2)));
               DateTime dateB = DateTime(int.parse(b.startDate.split("-").toList()[2]),int.parse(b.startDate.split("-").toList()[1]),int.parse(b.startDate.split("-").toList()[0]), hourB, int.parse(b.startTime.split(":").toList()[1].substring(0,2)));
               return dateA.compareTo(dateB);
             });
           });
         }
      });
    }
  }

  List<Event> getTodaysEvents(){
    return allEventsList.where((element) {
      int day = int.parse(element.startDate.split("-").toList()[0]);
      int month = int.parse(element.startDate.split("-").toList()[1]);
      int year = int.parse(element.startDate.split("-").toList()[2]);
      DateTime now = DateTime.now();
      if(now.year == year && now.month == month && now.day == day){
        return true;
      }
      else{
        return false;
      }
    }).toList();
  }

  List<Event> getUpcomingEvents(){
    return allEventsList.where((element) {
      int day = int.parse(element.startDate.split("-").toList()[0]);
      int month = int.parse(element.startDate.split("-").toList()[1]);
      int year = int.parse(element.startDate.split("-").toList()[2]);
      DateTime now = DateTime.now();
      if(now.year > year && now.month > month && now.day > day){
        return true;
      }
      else{
        return false;
      }
    }).toList();
  }

  Future<void> refreshHome() async {
    await getUserBasicInfo();
  }

  Widget homeWidget() {
    return RefreshIndicator(
        onRefresh: refreshHome,
        child: ListView(
          children: [
            communityFilterList.isEmpty || hideDropdown == true
                ? Container()
                : SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0, 10, 10),
                      child: Card(
                        elevation: 15,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: communityFilterList.length,
                          itemBuilder: (context, index) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CommunityPage(
                                              community:
                                                  communityFilterList[index],
                                              communityReference:
                                                  FirebaseFirestore.instance
                                                      .collection("Categories")
                                                      .doc(communityFilterList[
                                                              index]
                                                          .categoryKey)
                                                      .collection("Communities")
                                                      .doc(communityFilterList[
                                                              index]
                                                          .key),
                                              userBasicInfo: userBasicInfo!)),
                                    ).whenComplete(() {
                                      hideDropdown = true;
                                      FocusScope.of(context).unfocus();
                                      showSearchBar = false;
                                      searchController.text = "";
                                      setState(() {});
                                    });
                                  },
                                  child: ListTile(
                                    title: Text(
                                      communityFilterList[index].name,
                                      textAlign: TextAlign.start,
                                    ),
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                          communityFilterList[index]
                                              .coverImageUrl),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 1,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
            userBasicInfo!.userType == "Admin" ||
                    userBasicInfo!.userType == "Moderator"
                ? Card(
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              "All Communities",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                        ),
                        MyCommunityHomePage(
                          communityList: communitiesList,
                          userBasicInfo: userBasicInfo!,
                        ),
                      ],
                    ),
                  )
                : Container(),
            Card(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        "My Communities",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                  MyCommunityHomePage(
                    communityList: myCommunitiesList,
                    userBasicInfo: userBasicInfo!,
                  ),
                ],
              ),
            ),
            suggestedCommunityList.isEmpty
                ? Container()
                : Card(
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              "Suggested Communities",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                        ),
                        MyCommunityHomePage(
                          communityList: suggestedCommunityList,
                          userBasicInfo: userBasicInfo!,
                        ),
                      ],
                    ),
                  ),
            Card(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        "Recommended for you",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                  EventLayoutHomePage(
                    notFoundText: "You've no event recommendation.",
                      eventList: recommendedEventsList,
                      userBasicInfo: userBasicInfo!,
                      onRefresh: getEventsList),
                ],
              ),
            ),
          ],
        ));
  }

  Widget eventWidget() {
    return RefreshIndicator(
        onRefresh: refreshHome,
        child: ListView(
          children: [
            Card(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        "Today's events",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                  EventLayoutHomePage(
                    notFoundText: "There is no event today in your communities.",
                      eventList: todaysEventsList,
                      userBasicInfo: userBasicInfo!,
                      onRefresh: getEventsList),
                ],
              ),
            ),
            Card(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        "Upcoming events",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                  EventLayoutHomePage(
                    notFoundText: "There is no upcoming event available in your communities.",
                      eventList: upcomingEventsList,
                      userBasicInfo: userBasicInfo!,
                      onRefresh: getEventsList),
                ],
              ),
            ),
            Card(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        "Events you joined",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                  EventLayoutHomePage(
                    notFoundText: "You're not joined in any event.",
                      eventList: joinedEventsList.reversed.toList(),
                      userBasicInfo: userBasicInfo!,
                      onRefresh: getEventsList),
                ],
              ),
            ),


          ],
        ));
  }

  Widget createEventWidget() {
    return CreateEventPage(
      communitiesList: communitiesList,
      userBasicInfo: userBasicInfo!,
      userUid: user!.uid,
    );
  }

  Widget quizWidget() {
    return QuizPage(communityList: myCommunitiesList,userBasicInfo: userBasicInfo!,);
  }

  Widget profileWidget() {
    return MyProfilePageHome(userBasicInfo: userBasicInfo!, myCommunityList: myCommunitiesList,);
  }

  Widget verifyEmailPage() {
    return ListView(
      children: [
        const SizedBox(
          height: 20,
        ),
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                    text:
                        "An email verification link is sent to ${user!.email}\nPlease check your email and verify your account to continue.",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        disableEmailSend
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  onTap: sendEmailVerification,
                  leading: const Icon(Icons.send),
                  title: const Text(
                    "Send Email Again",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  AppBar appBarByIndex(){

    switch(selectedIndex){
      case 0:
        return homePageAppbar();
      case 1:
        return eventPageAppbar();
      case 2:
        return createEventPageAppbar();
      case 3:
        return quizPageAppbar();
      case 4:
        return profilePageAppbar();
      default:
        return homePageAppbar();
    }

  }

  AppBar homePageAppbar(){
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          showSearchBar
              ? Container()
              : const Text(
            "EventQc",
          ),
          showSearchBar
              ? SizedBox(
            width: MediaQuery.of(context).size.width - 100,
            child: TextFormField(
              controller: searchController,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                hintText: "Search community",
                hintStyle: const TextStyle(
                  color: Colors.white,
                ),
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      showSearchBar = false;
                      hideDropdown = true;
                      searchController.text = "";
                    });
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
              : InkWell(
            onTap: () {
              setState(() {
                showSearchBar = true;
              });
            },
            child: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
  AppBar eventPageAppbar(){
    return AppBar(
      title: const Text("Events"),
      centerTitle: true,
    );
  }
  AppBar createEventPageAppbar(){
    return  AppBar(
      title: const Text("Create an event"),
      centerTitle: true,
    );
  }
  AppBar quizPageAppbar(){
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Daily Quiz"),

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
    );
  }
  AppBar profilePageAppbar(){
    return AppBar(
      title: const Text("My Profile"),
      centerTitle: true,
    );
  }

  Future<bool> showExitAppPopup() async {
    return await showDialog( //show confirm dialogue
      //the return value will be from "Yes" or "No" options
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Are you sure?'),
        content: const Text("Do you want to close the app?"),
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
