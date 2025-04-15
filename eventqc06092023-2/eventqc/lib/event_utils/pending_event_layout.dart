import 'package:eventqc/event_utils/event_util.dart';
import 'package:flutter/material.dart';

class PendingEventLayout extends StatefulWidget {
  final Event event;
  final void Function() onApprove;
  final void Function() onReject;
  final Future<void> Function() onRefresh;
  const PendingEventLayout({Key? key, required this.event, required this.onApprove, required this.onReject, required this.onRefresh,}) : super(key: key);

  @override
  State<PendingEventLayout> createState() => _PendingEventLayoutState();
}

class _PendingEventLayoutState extends State<PendingEventLayout> {



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
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
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
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
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
                        color: widget.event.eventType == "PAID" ? Colors.red : const Color(0xfffd9f1b),
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
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 5,),
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
                  child:Text(
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
                  child:Text(
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
                  child:Text(
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
                  child:int.parse(widget.event.maximumRegistration) == 0?  Text(
                    "Registration: ${widget.event.totalRegistration}/∞",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ) : Text(
                    "Registration: ${widget.event.totalRegistration}/${widget.event.maximumRegistration}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                widget.event.eventType == "PAID"?  Padding(
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
                ) : Container(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                  child:Text(
                    "Event format: ${widget.event.eventFormat}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                widget.event.eventFormat == "ONLINE"?  Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                  child: Text(
                    "Live event link: ${widget.event.liveEventLink}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ) : Container(),
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
                  padding: const EdgeInsets.fromLTRB(20.0,0,20,20),
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
                  padding: const EdgeInsets.fromLTRB(20.0,0,20,20),
                  child: Text(
                    widget.event.description,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                TextButton(onPressed: (){
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
                TextButton(onPressed: (){
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

  String getDate(String date, int position, bool isMonth){
    if(isMonth){
      int i = int.parse(date.split("-").toList()[position]);
      if(i == 1){
        return "January";
      }
      else if( i == 2){

        return "February";
      }
      else if( i == 3){
        return "March";

      }
      else if( i == 4){

        return "April";

      }
      else if( i == 5){
        return "May";

      }
      else if( i == 6){
        return "June";

      }
      else if( i == 7){
        return "July";

      }
      else if( i == 8){
        return "August";

      }
      else if( i == 9){
        return "September";

      }
      else if( i == 10){
        return "October";

      }
      else if( i == 11){
        return "November";

      }
      else{
        return "December";
      }

    }
    else{
      return date.split("-").toList()[position];
    }
  }
}