import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:eventqc/event_utils/event_util.dart';
import 'package:eventqc/user_utils/user_basic_info_util.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as system_paths;
import 'package:scroll_date_picker/scroll_date_picker.dart';

import '../community_utils/community_util.dart';

class CreateEventPage extends StatefulWidget {
  final List<Community> communitiesList;
  final UserBasicInfo userBasicInfo;
  final String userUid;
  const CreateEventPage(
      {Key? key, required this.communitiesList, required this.userBasicInfo, required this.userUid})
      : super(key: key);

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  XFile? _pickedFile;
  CroppedFile? _croppedFile;
  String imageUrl = "";

  String publishDate = "";
  String eventDate = "";

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController maximumRegistrationController =
      TextEditingController();
  final TextEditingController registrationFeeController =
      TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController publicContactNumberController =
      TextEditingController();
  final TextEditingController liveLinkController = TextEditingController();
  final TextEditingController recordedLinkController = TextEditingController();
  final TextEditingController communityController = TextEditingController();

  bool titleValidate = false;
  bool communityValidate = false;
  bool descriptionValidate = false;
  bool maximumRegistrationValidate = false;
  bool registrationFeeValidate = false;
  bool locationValidate = false;
  bool publicContactNumberValidate = false;
  bool liveLinkValidate = false;
  bool recordedLinkValidate = false;

  String title = "";
  String description = "";
  String maximumRegistration = "";
  String registrationFee = "";
  String location = "";
  String publicContactNumber = "";
  String liveLink = "";
  String recordedLink = "";
  Community? selectedCommunity;

  String? selectedEventType;
  String? selectedEventFormat;

  bool hideDropdown = false;

  DateTime _selectedDate = DateTime.now();

  String eventStartTimeString = "";
  String eventEndTimeString = "";

  final eventStartTimeController = TextEditingController();
  final eventEndTimeController = TextEditingController();

  bool eventStartTimeValidate = false;
  bool eventEndTimeValidate = false;

  bool isProcessing = false;
  String timeStamp = "";

  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();

  _selectStartTime(BuildContext context) async {
    TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedStartTime,
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: "Select Event Start Time",
    );
    if (timeOfDay != null) {
      selectedStartTime = timeOfDay;
      int hour = timeOfDay.hour;
      int minute = timeOfDay.minute;
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
      eventStartTimeString = "$hourString:$minuteString $meridian";
      eventStartTimeController.text = eventStartTimeString;
      setState(() {});
    }
  }

  String getTimeFormat12h(TimeOfDay timeOfDay) {
    int hour = timeOfDay.hour;
    int minute = timeOfDay.minute;
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
    String timeString = "$hourString:$minuteString $meridian";
    return timeString;
  }

  _selectEndTime(BuildContext context) async {
    TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedEndTime,
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: "Select Event End Time",
    );
    if (timeOfDay != null) {
      selectedEndTime = timeOfDay;
      int hour = timeOfDay.hour;
      int minute = timeOfDay.minute;
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
      eventEndTimeString = "$hourString:$minuteString $meridian";
      eventEndTimeController.text = eventEndTimeString;
      setState(() {});
    }
  }

  List<Community> communityFilterList = [];

  Future<void> filterCommunityByName(String? string) async {
    if (string == null || string.isEmpty) {
      communityFilterList = [];
    } else {
      communityFilterList = widget.communitiesList
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
    communityController.addListener(() {
      filterCommunityByName(communityController.text);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Create an event"),
      //   centerTitle: true,
      // ),
      body: isProcessing ? const Center(child: CircularProgressIndicator(),) : ListView(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SizedBox(
              width: (MediaQuery.of(context).size.width) - 20,
              child: TextFormField(
                keyboardType: TextInputType.text,
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Event Title",
                  hintText: "Enter event title",
                  errorText: titleValidate ? "This field can't be empty" : null,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SizedBox(
              width: (MediaQuery.of(context).size.width) - 20,
              child: TextFormField(
                keyboardType: TextInputType.text,
                controller: communityController,
                decoration: InputDecoration(
                  labelText: "Community Name",
                  hintText: "Enter community name",
                  errorText:
                      communityValidate ? "This field can't be empty" : null,
                ),
              ),
            ),
          ),
          communityFilterList.isEmpty || hideDropdown == true
              ? Container()
              : SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
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
                                  communityController.text =
                                      communityFilterList[index].name;
                                  hideDropdown = true;
                                  FocusScope.of(context).unfocus();
                                  setState(() {});
                                },
                                child: ListTile(
                                  title: Text(
                                    communityFilterList[index].name,
                                    textAlign: TextAlign.start,
                                  ),
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                    NetworkImage(communityFilterList[index].coverImageUrl),
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
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SizedBox(
              width: (MediaQuery.of(context).size.width) - 20,
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: maximumRegistrationController,
                decoration: InputDecoration(
                  labelText: "Maximum Registration Allowed",
                  hintText: "Enter 0 for unlimited",
                  errorText: maximumRegistrationValidate
                      ? "This field can't be empty"
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SizedBox(
              width: (MediaQuery.of(context).size.width) - 20,
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                controller: descriptionController,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: "Description",
                  hintText: "Describe the event",
                  errorText:
                      descriptionValidate ? "This field can't be empty" : null,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SizedBox(
              width: (MediaQuery.of(context).size.width) - 20,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                controller: publicContactNumberController,
                decoration: InputDecoration(
                  labelText: "Contact Number",
                  hintText: "Enter contact number for this event",
                  errorText: publicContactNumberValidate
                      ? "This field can't be empty"
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SizedBox(
              width: (MediaQuery.of(context).size.width) - 20,
              child: TextFormField(
                keyboardType: TextInputType.text,
                controller: locationController,
                decoration: InputDecoration(
                  labelText: "Event Location",
                  hintText: "Enter event location",
                  errorText:
                      locationValidate ? "This field can't be empty" : null,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text(
              "What's your event type?",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Select your event type.",
              style: TextStyle(
                color: Color(0xff707071),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              setState(() {
                selectedEventType = "FREE";
              });
            },
            child: ListTile(
              title: const Text("FREE"),
              trailing: Radio(
                value: "FREE",
                groupValue: selectedEventType,
                onChanged: (String? value) {
                  setState(() {
                    selectedEventType = value;
                    registrationFeeController.text = "";
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
                selectedEventType = "PAID";
              });
            },
            child: ListTile(
              title: const Text("PAID"),
              trailing: Radio(
                value: "PAID",
                groupValue: selectedEventType,
                onChanged: (String? value) {
                  setState(() {
                    selectedEventType = value;
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
          selectedEventType != "PAID"
              ? Container()
              : const SizedBox(
                  height: 20,
                ),
          selectedEventType != "PAID"
              ? Container()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width) - 20,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: registrationFeeController,
                      decoration: InputDecoration(
                        labelText: "Registration Fee",
                        hintText: "Enter registration fee",
                        prefixText: "TK",
                        errorText: registrationFeeValidate
                            ? "This field can't be empty"
                            : null,
                      ),
                    ),
                  ),
                ),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text(
              "How you're going to organize?",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Select your event format.",
              style: TextStyle(
                color: Color(0xff707071),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              setState(() {
                selectedEventFormat = "OFFLINE";
              });
            },
            child: ListTile(
              title: const Text("OFFLINE"),
              trailing: Radio(
                value: "OFFLINE",
                groupValue: selectedEventFormat,
                onChanged: (String? value) {
                  setState(() {
                    selectedEventFormat = value;
                    liveLinkController.text = "";
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
                selectedEventFormat = "ONLINE";
              });
            },
            child: ListTile(
              title: const Text("ONLINE"),
              trailing: Radio(
                value: "ONLINE",
                groupValue: selectedEventFormat,
                onChanged: (String? value) {
                  setState(() {
                    selectedEventFormat = value;
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
          selectedEventFormat != "ONLINE"
              ? Container()
              : const SizedBox(
                  height: 20,
                ),
          selectedEventFormat != "ONLINE"
              ? Container()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width) - 20,
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: liveLinkController,
                      decoration: InputDecoration(
                        labelText: "Live Event Link",
                        hintText: "Enter live event link",
                        errorText: liveLinkValidate
                            ? "This field can't be empty"
                            : null,
                      ),
                    ),
                  ),
                ),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text(
              "What's the date of your?",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Select your event date.",
              style: TextStyle(
                color: Color(0xff707071),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 100,
            child: ScrollDatePicker(
              selectedDate: _selectedDate,
              maximumDate: DateTime(
                DateTime.now().year + 1,
                DateTime.now().month,
                DateTime.now().day,
              ),
              minimumDate: DateTime.now(),
              // locale: DatePickerLocale.enUS,
              onDateTimeChanged: (DateTime value) {
                setState(() {
                  _selectedDate = value;
                });
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              eventStartTimePicker(),
              eventEndTimePicker(),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          _imageSelector(),
          const SizedBox(
            height: 20,
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                titleValidate = true;
                setState(() {});
              } else if (communityController.text.trim().isEmpty) {
                communityValidate = true;
                titleValidate = false;
                setState(() {});
              } else if (maximumRegistrationController.text.trim().isEmpty) {
                maximumRegistrationValidate = true;
                titleValidate = false;
                communityValidate = false;
                setState(() {});
              } else if (descriptionController.text.trim().isEmpty) {
                descriptionValidate = true;
                titleValidate = false;
                communityValidate = false;
                maximumRegistrationValidate = false;
                setState(() {});
              } else if (publicContactNumberController.text.trim().isEmpty) {
                publicContactNumberValidate = true;
                descriptionValidate = false;
                titleValidate = false;
                communityValidate = false;
                maximumRegistrationValidate = false;
                setState(() {});
              } else if (locationController.text.trim().isEmpty) {
                locationValidate = true;
                publicContactNumberValidate = false;
                descriptionValidate = false;
                titleValidate = false;
                communityValidate = false;
                maximumRegistrationValidate = false;
                setState(() {});
              } else if (selectedEventType == null) {
                Fluttertoast.showToast(msg: "Select your event type");
                locationValidate = false;
                publicContactNumberValidate = false;
                descriptionValidate = false;
                titleValidate = false;
                communityValidate = false;
                maximumRegistrationValidate = false;
                setState(() {});
              } else if (selectedEventType == "PAID" &&
                  registrationFeeController.text.trim().isEmpty) {
                registrationFeeValidate = true;
                locationValidate = false;
                publicContactNumberValidate = false;
                descriptionValidate = false;
                titleValidate = false;
                communityValidate = false;
                maximumRegistrationValidate = false;
                setState(() {});
              } else if (selectedEventFormat == null) {
                Fluttertoast.showToast(msg: "Select your event format");
                registrationFeeValidate = false;
                locationValidate = false;
                publicContactNumberValidate = false;
                descriptionValidate = false;
                titleValidate = false;
                communityValidate = false;
                maximumRegistrationValidate = false;
                setState(() {});
              } else if (selectedEventFormat == "ONLINE" &&
                  liveLinkController.text.trim().isEmpty) {
                liveLinkValidate = true;
                registrationFeeValidate = false;
                locationValidate = false;
                publicContactNumberValidate = false;
                descriptionValidate = false;
                titleValidate = false;
                communityValidate = false;
                maximumRegistrationValidate = false;
                setState(() {});
              } else if (eventStartTimeController.text.trim().isEmpty) {
                eventStartTimeValidate = true;
                liveLinkValidate = false;
                registrationFeeValidate = false;
                locationValidate = false;
                publicContactNumberValidate = false;
                descriptionValidate = false;
                titleValidate = false;
                communityValidate = false;
                maximumRegistrationValidate = false;
                setState(() {});
              } else if (eventEndTimeController.text.trim().isEmpty) {
                eventEndTimeValidate = true;
                eventStartTimeValidate = false;
                liveLinkValidate = false;
                registrationFeeValidate = false;
                locationValidate = false;
                publicContactNumberValidate = false;
                descriptionValidate = false;
                titleValidate = false;
                communityValidate = false;
                maximumRegistrationValidate = false;
                setState(() {});
              } else if (_pickedFile == null) {
                Fluttertoast.showToast(msg: "Upload a cover image");
                eventEndTimeValidate = false;
                eventStartTimeValidate = false;
                liveLinkValidate = false;
                registrationFeeValidate = false;
                locationValidate = false;
                publicContactNumberValidate = false;
                descriptionValidate = false;
                titleValidate = false;
                communityValidate = false;
                maximumRegistrationValidate = false;
                setState(() {});
              } else {
                eventEndTimeValidate = false;
                eventStartTimeValidate = false;
                liveLinkValidate = false;
                registrationFeeValidate = false;
                locationValidate = false;
                publicContactNumberValidate = false;
                descriptionValidate = false;
                titleValidate = false;
                communityValidate = false;
                maximumRegistrationValidate = false;
                if (selectCommunity(communityController.text.trim())) {
                  DateTime now = DateTime.now();
                  setState(() {
                    isProcessing = true;
                    timeStamp =
                        "${now.hour}${now.minute}${now.second}${now.day}${now.month}${now.year}";
                    publishDate = "${now.day}-${now.month}-${now.year}/${getTimeFormat12h(TimeOfDay.now())}";
                    eventDate = "${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}";
                  });
                  if (_croppedFile != null) {
                    uploadDataFromCropped();
                  } else {
                    uploadDataFromPicked();
                  }
                } else {
                  Fluttertoast.showToast(msg: "Enter a valid community name");
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
                  'Publish',
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
    );
  }

  String baseName(path) {
    int pos = path.lastIndexOf("/") + 1;
    return path.substring(pos);
  }

  bool selectCommunity(String communityName) {
    if (widget.communitiesList
        .where((element) => element.name == communityName)
        .toList()
        .isEmpty) {
      Fluttertoast.showToast(msg: "Community not found...");
      setState(() {
        selectedCommunity = null;
      });
      return false;
    } else {
      setState(() {
        selectedCommunity = widget.communitiesList
            .where((element) => element.name == communityName)
            .toList()[0];
      });
      return true;
    }
  }

  Future<void> uploadDataFromPicked() async {
    Fluttertoast.showToast(
        msg: "Please wait...", toastLength: Toast.LENGTH_LONG);
    UploadTask? uploadImage() {
      try {
        final imageRef = FirebaseStorage.instance.ref(
            "Image/${selectedCommunity!.category}/${selectedCommunity!.name}/$timeStamp${baseName(_pickedFile!.path)}");

        return imageRef.putFile(File(_pickedFile!.path));
      } on FirebaseException catch (e) {
        setState(() {
          isProcessing = false;
        });
        return null;
      }
    }

    final snapshot = await uploadImage()!.whenComplete(() {});
    imageUrl = await snapshot.ref.getDownloadURL().whenComplete(() {
      setState(() {});
    });
    addEventInDatabase();
  }

  Future<void> uploadDataFromCropped() async {
    Fluttertoast.showToast(
        msg: "Please wait...", toastLength: Toast.LENGTH_LONG);
    Uint8List bytes = await _croppedFile!.readAsBytes();
    final appDir = await system_paths.getTemporaryDirectory();
    File file = File('${appDir.path}/$timeStamp.jpg');
    await file.writeAsBytes(bytes);

    UploadTask? uploadImage() {
      try {
        final imageRef = FirebaseStorage.instance.ref(
            "Image/${selectedCommunity!.category}/${selectedCommunity!.name}/$timeStamp${baseName(_pickedFile!.path)}");

        return imageRef.putFile(file);
      } on FirebaseException catch (e) {
        setState(() {
          isProcessing = false;
        });
        return null;
      }
    }

    final snapshot = await uploadImage()!.whenComplete(() {});
    imageUrl = await snapshot.ref.getDownloadURL().whenComplete(() {
      setState(() {});
    });
    addEventInDatabase();
  }

  Future<void> addEventInDatabase() async {
    String key = FirebaseFirestore.instance.collection("Categories").doc().id;
    Event event = Event(
        key,
        selectedCommunity!.key,
        selectedCommunity!.name,
        titleController.text.trim(),
        imageUrl,
        selectedEventType!,
        selectedEventFormat!,
        publishDate.trim(),
        eventDate.trim(),
        eventStartTimeString.trim(),
        eventEndTimeString.trim(),
        descriptionController.text.trim(),
        maximumRegistrationController.text.trim(),
        locationController.text.trim(),
        widget.userUid,
        "${widget.userBasicInfo.firstName} ${widget.userBasicInfo.lastName}",
        widget.userBasicInfo.phone.trim(),
        publicContactNumberController.text.trim(),
        registrationFeeController.text.trim(),
        "0",
        liveLinkController.text.trim(),
        "",
        selectedCommunity!.categoryKey,
        selectedCommunity!.category,);

    try {
      await FirebaseFirestore.instance.collection("Categories").doc(
          selectedCommunity!.categoryKey).collection("Communities").doc(
          selectedCommunity!.key)
          .collection("PendingEvents").doc(key)
          .set(event.toJson())
          .whenComplete(() {
        clearAllValue();
        setState(() {
          Fluttertoast.showToast(msg: "Event added successfully...\nSomeone will review your event soon...");
          isProcessing = false;
        });
      });
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong...\nPlease try again...");
      setState(() {
        isProcessing = false;
      });
    }
  }

  void clearAllValue() {
    setState(() {
      titleController.text = "";
      communityController.text = "";
      maximumRegistrationController.text = "";
      descriptionController.text = "";
      publicContactNumberController.text = "";
      locationController.text = "";
      selectedEventType = null;
      registrationFeeController.text = "";
      selectedEventFormat = null;
      liveLinkController.text = "";
      _selectedDate = DateTime.now();
      eventStartTimeController.text = "";
      eventEndTimeController.text = "";
      _pickedFile = null;
      _croppedFile = null;
      isProcessing = false;
      timeStamp = "";
      imageUrl = "";
      selectedCommunity = null;
      publishDate = "";
      eventDate = "";
      eventStartTimeString = "";
      eventEndTimeString = "";
    });
  }

  Widget _imageSelector() {
    if (_croppedFile != null || _pickedFile != null) {
      return _imageCard();
    } else {
      return _uploaderCard();
    }
  }

  Widget _imageCard() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            elevation: 4.0,
            child: _image(),
          ),
          const SizedBox(height: 24.0),
          _menu(),
        ],
      ),
    );
  }

  Widget _image() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_croppedFile != null) {
      final path = _croppedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: kIsWeb
            ? AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  path,
                  fit: BoxFit.fill,
                ),
              )
            : AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(
                  File(path),
                  fit: BoxFit.fill,
                )),
      );
    } else if (_pickedFile != null) {
      final path = _pickedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: kIsWeb
            ? AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  path,
                  fit: BoxFit.fill,
                ))
            : AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(
                  File(path),
                  fit: BoxFit.fill,
                )),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _menu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "delete",
          onPressed: () {
            _clear();
          },
          backgroundColor: Colors.black,
          tooltip: 'Delete',
          child: const Icon(Icons.delete),
        ),
        // if (_croppedFile == null)
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: FloatingActionButton(
            heroTag: "edit",
            onPressed: () {
              _cropImage();
            },
            backgroundColor: Colors.black,
            tooltip: 'Edit',
            child: const Icon(Icons.edit),
          ),
        )
      ],
    );
  }

  Widget _uploaderCard() {
    return Center(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SizedBox(
          width: kIsWeb ? 380.0 : 320.0,
          height: 300.0,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DottedBorder(
                    radius: const Radius.circular(12.0),
                    borderType: BorderType.RRect,
                    dashPattern: const [8, 4],
                    color: Theme.of(context).highlightColor.withOpacity(0.4),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            color: Theme.of(context).highlightColor,
                            size: 80.0,
                          ),
                          const SizedBox(height: 24.0),
                          Text(
                            'Upload a cover image',
                            style: kIsWeb
                                ? Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                        color: Theme.of(context).highlightColor)
                                : Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                        color:
                                            Theme.of(context).highlightColor),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ElevatedButton(
                  onPressed: () {
                    _uploadImage();
                  },
                  child: const Text('Upload'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cropImage() async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        compressQuality: 100,
        // uiSettings: [
        //   AndroidUiSettings(
        //       toolbarTitle: 'Cropper',
        //       toolbarColor: Colors.deepOrange,
        //       toolbarWidgetColor: Colors.white,
        //       initAspectRatio: CropAspectRatioPreset.ratio16x9,
        //       lockAspectRatio: true),
        //   IOSUiSettings(
        //     title: 'Cropper',
        //   ),
        // ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
      _cropImage();
    }
  }

  void _clear() {
    setState(() {
      _pickedFile = null;
      _croppedFile = null;
    });
  }

  Widget eventStartTimePicker() {
    return SizedBox(
      width: (MediaQuery.of(context).size.width / 2) - 20,
      child: Center(
        child: TextFormField(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            _selectStartTime(context);
          },
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            // labelText: "Select event start time",
            errorText: eventStartTimeValidate ? "Value can't be empty" : null,
            hintText: "Event start time",
          ),
          controller: eventStartTimeController,
        ),
      ),
    );
  }

  Widget eventEndTimePicker() {
    // SizedBox(
    //   width: (MediaQuery.of(context).size.width / 2) - 20,
    //   child: TextFormField(
    //     keyboardType: TextInputType.text,
    //     controller: firstNameController,
    //     decoration: InputDecoration(
    //       labelText: "First Name",
    //       hintText: "Enter first name",
    //       errorText: firstNameValidate ? "Enter your first name" : null,
    //     ),
    //   ),
    // ),
    return SizedBox(
      width: (MediaQuery.of(context).size.width / 2) - 20,
      child: Center(
        child: TextFormField(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            _selectEndTime(context);
          },
          decoration: InputDecoration(
            // labelText: "Select event end time",
            errorText: eventEndTimeValidate ? "Value can't be empty" : null,
            hintText: "Event end time",
          ),
          textAlign: TextAlign.center,
          controller: eventEndTimeController,
        ),
      ),
    );
  }
}
