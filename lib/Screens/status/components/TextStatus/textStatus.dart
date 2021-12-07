//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TextStatus extends StatefulWidget {
  final String currentuserNo;
  final List<dynamic> phoneNumberVariants;
  const TextStatus(
      {Key? key,
      required this.currentuserNo,
      required this.phoneNumberVariants})
      : super(key: key);

  @override
  _TextStatusState createState() => _TextStatusState();
}

class _TextStatusState extends State<TextStatus> {
  TextEditingController _controller = new TextEditingController();
  Future<bool> onWillPopNEw() {
    return Future.value(false);
  }

  String getColorString() {
    Color color = colorsList[colorIndex];
    String colorString = color.toString(); // Color(0x12345678)
    String valueString =
        colorString.split('(0x')[1].split(')')[0]; // kind of hacky..
    return valueString;
  }

  List<Color> colorsList = [
    Colors.blueGrey[700]!,
    Colors.purple[700]!,
    Colors.blue[600]!,
    Colors.orange[500]!,
    Colors.cyan[700]!,
    Colors.pink[400]!,
    Colors.brown[600]!,
    Colors.red[400]!,
  ];
  int colorIndex = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPopNEw,
      child: Scaffold(
        backgroundColor: colorsList[colorIndex],
        body: Stack(
          children: [
            Center(
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(23, 23, 23, 10),
                child: TextField(
                  decoration: InputDecoration(border: InputBorder.none),
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.name,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(150),
                  ],
                  onChanged: (text) {
                    setState(() {});
                  },
                  maxLines: 7,
                  minLines: 1,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      height: 1.6,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
                right: 93,
                top: (MediaQuery.of(context).padding.top) + 23,
                child: IconButton(
                  onPressed: () {
                    if ((colorsList.length - 1) == colorIndex) {
                      colorIndex = 0;
                    } else {
                      colorIndex++;
                    }
                    if (mounted) setState(() {});
                  },
                  icon: Icon(Icons.palette_rounded,
                      size: 30, color: Colors.white),
                )),
            Positioned(
                right: 19,
                top: (MediaQuery.of(context).padding.top) + 23,
                child: IconButton(
                  onPressed: () {
                    _controller.text.trim();
                    if (_controller.text.isNotEmpty) {
                      final observer =
                          Provider.of<Observer>(context, listen: false);
                      FirebaseFirestore.instance
                          .collection(DbPaths.collectionnstatus)
                          .doc(widget.currentuserNo)
                          .set({
                        Dbkeys.statusITEMSLIST: FieldValue.arrayUnion([
                          {
                            Dbkeys.statusItemID:
                                DateTime.now().millisecondsSinceEpoch,
                            Dbkeys.statusItemTYPE: Dbkeys.statustypeTEXT,
                            Dbkeys.statusItemCAPTION: _controller.text,
                            Dbkeys.statusItemBGCOLOR: getColorString(),
                          }
                        ]),
                        Dbkeys.statusPUBLISHERPHONE: widget.currentuserNo,
                        Dbkeys.statusPUBLISHERPHONEVARIANTS:
                            widget.phoneNumberVariants,
                        Dbkeys.statusVIEWERLIST: [],
                        Dbkeys.statusVIEWERLISTWITHTIME: [],
                        Dbkeys.statusPUBLISHEDON: DateTime.now(),
                        Dbkeys.statusEXPIRININGON: DateTime.now().add(
                            Duration(hours: observer.statusDeleteAfterInHours)),
                      }, SetOptions(merge: true)).then((value) {
                        Navigator.of(context).pop();
                      });
                    }
                  },
                  icon: Icon(Icons.done,
                      size: 30,
                      color: _controller.text.isEmpty
                          ? Colors.white24
                          : Colors.white),
                )),
            Positioned(
                left: 19,
                top: (MediaQuery.of(context).padding.top) + 23,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close, size: 30, color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}
