//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/auth_screens/login.dart';
import 'package:fiberchat/Screens/call_history/callhistory.dart';
import 'package:fiberchat/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat/Services/Providers/AvailableContactsProvider.dart';
import 'package:fiberchat/Services/Providers/GroupChatProvider.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:fiberchat/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddContactsToGroup extends StatefulWidget {
  const AddContactsToGroup({
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
    required this.isAddingWhileCreatingGroup,
    this.groupID,
  });
  final String? groupID;
  final String? currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final bool biometricEnabled;
  final bool isAddingWhileCreatingGroup;

  @override
  _AddContactsToGroupState createState() => new _AddContactsToGroupState();
}

class _AddContactsToGroupState extends State<AddContactsToGroup>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  Map<String?, String?>? contacts;
  List<DocumentSnapshot> _selectedList = [];
  List<String> targetUserNotificationTokens = [];
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _filter = new TextEditingController();
  final TextEditingController groupname = new TextEditingController();
  final TextEditingController groupdesc = new TextEditingController();
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void dispose() {
    super.dispose();
    _filter.dispose();
  }

  loading() {
    return Stack(children: [
      Container(
        child: Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(fiberchatBlue),
        )),
      )
    ]);
  }

  bool iscreatinggroup = false;
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PickupLayout(
        scaffold: Fiberchat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model!,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Consumer<AvailableContactsProvider>(
                  builder: (context, contactsProvider, _child) => Consumer<
                          List<GroupModel>>(
                      builder: (context, groupList, _child) => Scaffold(
                          key: _scaffold,
                          backgroundColor: fiberchatWhite,
                          appBar: AppBar(
                            leading: IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                size: 24,
                                color: DESIGN_TYPE == Themetype.whatsapp
                                    ? fiberchatWhite
                                    : fiberchatBlack,
                              ),
                            ),
                            backgroundColor: DESIGN_TYPE == Themetype.whatsapp
                                ? fiberchatDeepGreen
                                : fiberchatWhite,
                            centerTitle: false,
                            // leadingWidth: 40,
                            title: _selectedList.length == 0
                                ? Text(
                                    getTranslated(
                                        this.context, 'selectcontacts'),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: DESIGN_TYPE == Themetype.whatsapp
                                          ? fiberchatWhite
                                          : fiberchatBlack,
                                    ),
                                    textAlign: TextAlign.left,
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        getTranslated(
                                            this.context, 'selectcontacts'),
                                        style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              DESIGN_TYPE == Themetype.whatsapp
                                                  ? fiberchatWhite
                                                  : fiberchatBlack,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        widget.isAddingWhileCreatingGroup ==
                                                true
                                            ? '${_selectedList.length} / ${contactsProvider.joinedUserPhoneStringAsInServer.length}'
                                            : '${_selectedList.length} ${getTranslated(this.context, 'selected')}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              DESIGN_TYPE == Themetype.whatsapp
                                                  ? fiberchatWhite
                                                  : fiberchatBlack,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                            actions: <Widget>[
                              _selectedList.length == 0
                                  ? SizedBox()
                                  : IconButton(
                                      icon: Icon(
                                        Icons.check,
                                        color: DESIGN_TYPE == Themetype.whatsapp
                                            ? fiberchatWhite
                                            : fiberchatBlack,
                                      ),
                                      onPressed:
                                          widget.isAddingWhileCreatingGroup ==
                                                  true
                                              ? () async {
                                                  groupdesc.clear();
                                                  groupname.clear();
                                                  showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      context: context,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        25.0)),
                                                      ),
                                                      builder: (BuildContext
                                                          context) {
                                                        // return your layout
                                                        var w = MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width;
                                                        return Padding(
                                                          padding: EdgeInsets.only(
                                                              bottom: MediaQuery
                                                                      .of(context)
                                                                  .viewInsets
                                                                  .bottom),
                                                          child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(16),
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  2.2,
                                                              child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .stretch,
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          12,
                                                                    ),
                                                                    SizedBox(
                                                                      height: 3,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              8),
                                                                      child:
                                                                          Text(
                                                                        getTranslated(
                                                                            this.context,
                                                                            'setgroup'),
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 16.5),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                              top: 10),
                                                                      padding: EdgeInsets
                                                                          .fromLTRB(
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                      // height: 63,
                                                                      height:
                                                                          83,
                                                                      width: w /
                                                                          1.24,
                                                                      child:
                                                                          InpuTextBox(
                                                                        controller:
                                                                            groupname,
                                                                        leftrightmargin:
                                                                            0,
                                                                        showIconboundary:
                                                                            false,
                                                                        boxcornerradius:
                                                                            5.5,
                                                                        boxheight:
                                                                            50,
                                                                        hinttext: getTranslated(
                                                                            this.context,
                                                                            'groupname'),
                                                                        prefixIconbutton:
                                                                            Icon(
                                                                          Icons
                                                                              .edit,
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.5),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                              top: 10),
                                                                      padding: EdgeInsets
                                                                          .fromLTRB(
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                      // height: 63,
                                                                      height:
                                                                          83,
                                                                      width: w /
                                                                          1.24,
                                                                      child:
                                                                          InpuTextBox(
                                                                        maxLines:
                                                                            1,
                                                                        controller:
                                                                            groupdesc,
                                                                        leftrightmargin:
                                                                            0,
                                                                        showIconboundary:
                                                                            false,
                                                                        boxcornerradius:
                                                                            5.5,
                                                                        boxheight:
                                                                            50,
                                                                        hinttext: getTranslated(
                                                                            this.context,
                                                                            'groupdesc'),
                                                                        prefixIconbutton:
                                                                            Icon(
                                                                          Icons
                                                                              .message,
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.5),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 6,
                                                                    ),
                                                                    myElevatedButton(
                                                                        color:
                                                                            fiberchatLightGreen,
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                              10,
                                                                              15,
                                                                              10,
                                                                              15),
                                                                          child:
                                                                              Text(
                                                                            getTranslated(this.context,
                                                                                'creategroup'),
                                                                            style:
                                                                                TextStyle(color: Colors.white, fontSize: 18),
                                                                          ),
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          Navigator.of(_scaffold.currentContext!)
                                                                              .pop();
                                                                          List<String>
                                                                              listusers =
                                                                              [];
                                                                          List<String>
                                                                              listmembers =
                                                                              [];
                                                                          _selectedList
                                                                              .forEach((element) {
                                                                            listusers.add(element[Dbkeys.phone]);
                                                                            listmembers.add(element[Dbkeys.phone]);
                                                                            if (element[Dbkeys.notificationTokens] !=
                                                                                null) {
                                                                              if (element[Dbkeys.notificationTokens].length > 0) {
                                                                                targetUserNotificationTokens.add(element[Dbkeys.notificationTokens].last);
                                                                              }
                                                                            }
                                                                          });
                                                                          listmembers
                                                                              .add(widget.currentUserNo!);
                                                                          if (widget.model!.currentUser![Dbkeys.notificationTokens].last !=
                                                                              null) {
                                                                        
                                                                            targetUserNotificationTokens.add(widget.model!.currentUser![Dbkeys.notificationTokens].last);
                                                                          }

                                                                          DateTime
                                                                              time =
                                                                              DateTime.now();
                                                                          DateTime
                                                                              time2 =
                                                                              DateTime.now().add(Duration(seconds: 1));
                                                                          String
                                                                              groupID =
                                                                              '${widget.currentUserNo!.toString()}--${time.millisecondsSinceEpoch.toString()}';
                                                                          Map<String, dynamic>
                                                                              groupdata =
                                                                              {
                                                                            Dbkeys.groupDESCRIPTION: groupdesc.text.isEmpty
                                                                                ? ''
                                                                                : groupdesc.text.trim(),
                                                                            Dbkeys.groupCREATEDON:
                                                                                time,
                                                                            Dbkeys.groupCREATEDBY:
                                                                                widget.currentUserNo,
                                                                            Dbkeys.groupNAME: groupname.text.isEmpty
                                                                                ? 'Unnamed Group'
                                                                                : groupname.text.trim(),
                                                                            Dbkeys.groupIDfiltered:
                                                                                groupID.replaceAll(RegExp('-'), '').substring(1, groupID.replaceAll(RegExp('-'), '').toString().length),
                                                                            Dbkeys.groupISTYPINGUSERID:
                                                                                '',
                                                                            Dbkeys.groupADMINLIST:
                                                                                [
                                                                              widget.currentUserNo
                                                                            ],
                                                                            Dbkeys.groupID:
                                                                                groupID,
                                                                            Dbkeys.groupPHOTOURL:
                                                                                null,
                                                                            Dbkeys.groupMEMBERSLIST:
                                                                                listmembers,
                                                                            Dbkeys.groupLATESTMESSAGETIME:
                                                                                time.millisecondsSinceEpoch,
                                                                            Dbkeys.groupTYPE:
                                                                                Dbkeys.groupTYPEallusersmessageallowed,
                                                                          };

                                                                          listmembers
                                                                              .forEach((element) {
                                                                            groupdata.putIfAbsent(element.toString(),
                                                                                () => time.millisecondsSinceEpoch);

                                                                            groupdata.putIfAbsent('$element-joinedOn',
                                                                                () => time.millisecondsSinceEpoch);
                                                                          });
                                                                          setStateIfMounted(
                                                                              () {
                                                                            iscreatinggroup =
                                                                                true;
                                                                          });
                                                                          await FirebaseFirestore
                                                                              .instance
                                                                              .collection(DbPaths.collectiongroups)
                                                                              .doc(widget.currentUserNo!.toString() + '--' + time.millisecondsSinceEpoch.toString())
                                                                              .set(groupdata)
                                                                              .then((value) async {
                                                                            await FirebaseFirestore.instance.collection(DbPaths.collectiongroups).doc(widget.currentUserNo!.toString() + '--' + time.millisecondsSinceEpoch.toString()).collection(DbPaths.collectiongroupChats).doc(time.millisecondsSinceEpoch.toString() + '--' + widget.currentUserNo!.toString()).set({
                                                                              Dbkeys.groupmsgCONTENT: '',
                                                                              Dbkeys.groupmsgLISToptional: listusers,
                                                                              Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
                                                                              Dbkeys.groupmsgSENDBY: widget.currentUserNo,
                                                                              Dbkeys.groupmsgISDELETED: false,
                                                                              Dbkeys.groupmsgTYPE: Dbkeys.groupmsgTYPEnotificationCreatedGroup,
                                                                            }).then((value) async {
                                                                              await FirebaseFirestore.instance.collection(DbPaths.collectiongroups).doc(widget.currentUserNo!.toString() + '--' + time.millisecondsSinceEpoch.toString()).collection(DbPaths.collectiongroupChats).doc(time2.millisecondsSinceEpoch.toString() + '--' + widget.currentUserNo!.toString()).set({
                                                                                Dbkeys.groupmsgCONTENT: '',
                                                                                Dbkeys.groupmsgLISToptional: listmembers,
                                                                                Dbkeys.groupmsgTIME: time2.millisecondsSinceEpoch,
                                                                                Dbkeys.groupmsgSENDBY: widget.currentUserNo,
                                                                                Dbkeys.groupmsgISDELETED: false,
                                                                                Dbkeys.groupmsgTYPE: Dbkeys.groupmsgTYPEnotificationAddedUser,
                                                                              }).then((val) async {
                                                                                await FirebaseFirestore.instance.collection(DbPaths.collectiontemptokensforunsubscribe).doc(groupID).set({
                                                                                  Dbkeys.groupIDfiltered: '${groupID.replaceAll(RegExp('-'), '').substring(1, groupID.replaceAll(RegExp('-'), '').toString().length)}',
                                                                                  Dbkeys.notificationTokens: targetUserNotificationTokens,
                                                                                  'type': 'subscribe'
                                                                                });
                                                                              }).then((value) async {
                                                                                Navigator.of(_scaffold.currentContext!).pop();
                                                                              }).catchError((err) {
                                                                                setStateIfMounted(() {
                                                                                  iscreatinggroup = false;
                                                                                });

                                                                                Fiberchat.toast('Error Creating group. $err');
                                                                                print('Error Creating group: $err');
                                                                              });
                                                                            });
                                                                          });
                                                                        }),
                                                                  ])),
                                                        );
                                                      });
                                                }
                                              : () async {
                                                  // List<String> listusers = [];
                                                  List<String> listmembers = [];
                                                  _selectedList
                                                      .forEach((element) {
                                                    // listusers.add(element[Dbkeys.phone]);
                                                    listmembers.add(
                                                        element[Dbkeys.phone]);
                                                    if (element[Dbkeys
                                                            .notificationTokens] !=
                                                        null) {
                                                      if (element[Dbkeys
                                                                  .notificationTokens]
                                                              .length >
                                                          0) {
                                                        targetUserNotificationTokens
                                                            .add(element[Dbkeys
                                                                    .notificationTokens]
                                                                .last);
                                                      }
                                                    }
                                                  });
                                                  DateTime time =
                                                      DateTime.now();

                                                  setStateIfMounted(() {
                                                    iscreatinggroup = true;
                                                  });

                                                  Map<String, dynamic> docmap =
                                                      {
                                                    Dbkeys.groupMEMBERSLIST:
                                                        FieldValue.arrayUnion(
                                                            listmembers)
                                                  };

                                                  _selectedList
                                                      .forEach((element) async {
                                                    docmap.putIfAbsent(
                                                        '${element[Dbkeys.phone]}-joinedOn',
                                                        () => time
                                                            .millisecondsSinceEpoch);
                                                    docmap.putIfAbsent(
                                                        '${element[Dbkeys.phone]}',
                                                        () => time
                                                            .millisecondsSinceEpoch);
                                                  });
                                                  setStateIfMounted(() {});
                                                  try {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(DbPaths
                                                            .collectiontemptokensforunsubscribe)
                                                        .doc(widget.groupID)
                                                        .delete();
                                                  } catch (err) {}
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(DbPaths
                                                          .collectiongroups)
                                                      .doc(widget.groupID)
                                                      .update(docmap)
                                                      .then((value) async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(DbPaths
                                                            .collectiongroups)
                                                        .doc(widget.groupID)
                                                        .collection(DbPaths
                                                            .collectiongroupChats)
                                                        .doc(widget.groupID)
                                                        .set({
                                                      Dbkeys.groupmsgCONTENT:
                                                          '',
                                                      Dbkeys.groupmsgLISToptional:
                                                          listmembers,
                                                      Dbkeys.groupmsgTIME: time
                                                          .millisecondsSinceEpoch,
                                                      Dbkeys.groupmsgSENDBY:
                                                          widget.currentUserNo,
                                                      Dbkeys.groupmsgISDELETED:
                                                          false,
                                                      Dbkeys.groupmsgTYPE: Dbkeys
                                                          .groupmsgTYPEnotificationAddedUser,
                                                    }).then((v) async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(DbPaths
                                                              .collectiontemptokensforunsubscribe)
                                                          .doc(widget.groupID)
                                                          .set({
                                                        Dbkeys.groupIDfiltered:
                                                            '${widget.groupID!.replaceAll(RegExp('-'), '').substring(1, widget.groupID!.replaceAll(RegExp('-'), '').toString().length)}',
                                                        Dbkeys.notificationTokens:
                                                            targetUserNotificationTokens,
                                                        'type': 'subscribe'
                                                      });
                                                    }).then((value) async {
                                                      Navigator.of(context)
                                                          .pop();
                                                    }).catchError((err) {
                                                      setStateIfMounted(() {
                                                        iscreatinggroup = false;
                                                      });

                                                      Fiberchat.toast(getTranslated(
                                                          this.context,
                                                          'errorcreatinggroup'));
                                                    });
                                                  });
                                                },
                                    )
                            ],
                          ),
                          bottomSheet: _selectedList.length == 0
                              ? SizedBox(
                                  height: 0,
                                  width: 0,
                                )
                              : Container(
                                  padding: EdgeInsets.only(top: 6),
                                  width: MediaQuery.of(context).size.width,
                                  height: 94,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _selectedList.reversed
                                          .toList()
                                          .length,
                                      itemBuilder: (context, int i) {
                                        return Stack(
                                          children: [
                                            Container(
                                              width: 90,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      11, 10, 12, 10),
                                              child: Column(
                                                children: [
                                                  customCircleAvatar(
                                                      url: _selectedList
                                                              .reversed
                                                              .toList()[i]
                                                          [Dbkeys.photoUrl],
                                                      radius: 20),
                                                  SizedBox(
                                                    height: 7,
                                                  ),
                                                  Text(
                                                    _selectedList.reversed
                                                            .toList()[i]
                                                        [Dbkeys.nickname],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              right: 17,
                                              top: 5,
                                              child: new InkWell(
                                                onTap: () {
                                                  setStateIfMounted(() {
                                                    _selectedList.remove(
                                                        _selectedList.reversed
                                                            .toList()[i]);
                                                  });
                                                },
                                                child: new Container(
                                                  width: 20.0,
                                                  height: 20.0,
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  decoration: new BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.black,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 14,
                                                    color: Colors.white,
                                                  ),
                                                ), //............
                                              ),
                                            )
                                          ],
                                        );
                                      }),
                                ),
                          body: RefreshIndicator(
                              onRefresh: () {
                                return contactsProvider.fetchContacts(context,
                                    model, widget.currentUserNo!, widget.prefs);
                              },
                              child: contactsProvider
                                              .searchingcontactsindatabase ==
                                          true ||
                                      iscreatinggroup == true
                                  ? loading()
                                  : contactsProvider
                                              .joinedUserPhoneStringAsInServer
                                              .length ==
                                          0
                                      ? ListView(shrinkWrap: true, children: [
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  top: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      2.5),
                                              child: Center(
                                                child: Text(
                                                    getTranslated(context,
                                                        'nosearchresult'),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: fiberchatGrey)),
                                              ))
                                        ])
                                      : Padding(
                                          padding: EdgeInsets.only(
                                              bottom: _selectedList.length == 0
                                                  ? 0
                                                  : 80),
                                          child: ListView.builder(
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            padding: EdgeInsets.all(10),
                                            itemCount: contactsProvider
                                                .joinedUserPhoneStringAsInServer
                                                .length,
                                            itemBuilder: (context, idx) {
                                              String phone = contactsProvider
                                                  .joinedUserPhoneStringAsInServer[
                                                      idx]
                                                  .phone;
                                              Widget? alreadyAddedUser = widget
                                                          .isAddingWhileCreatingGroup ==
                                                      true
                                                  ? null
                                                  : groupList
                                                          .lastWhere((element) =>
                                                              element.docmap[
                                                                  Dbkeys
                                                                      .groupID] ==
                                                              widget.groupID)
                                                          .docmap[Dbkeys
                                                              .groupMEMBERSLIST]
                                                          .contains(phone)
                                                      ? SizedBox()
                                                      : null;
                                              return alreadyAddedUser ??
                                                  FutureBuilder(
                                                      future: contactsProvider
                                                          .getUserDoc(phone),
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<
                                                                  DocumentSnapshot>
                                                              snapshot) {
                                                        if (snapshot.hasData &&
                                                            snapshot
                                                                .data!.exists) {
                                                          DocumentSnapshot
                                                              user =
                                                              snapshot.data!;
                                                          return Column(
                                                            children: [
                                                              ListTile(
                                                                leading:
                                                                    customCircleAvatar(
                                                                  url: user[Dbkeys
                                                                      .photoUrl],
                                                                  radius: 22.5,
                                                                ),
                                                                trailing:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color:
                                                                            fiberchatGrey,
                                                                        width:
                                                                            1),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                  ),
                                                                  child: _selectedList.lastIndexWhere((element) =>
                                                                              element[Dbkeys.phone] ==
                                                                              phone) >=
                                                                          0
                                                                      ? Icon(
                                                                          Icons
                                                                              .check,
                                                                          size:
                                                                              19.0,
                                                                          color:
                                                                              fiberchatLightGreen,
                                                                        )
                                                                      : Icon(
                                                                          null,
                                                                          size:
                                                                              19.0,
                                                                        ),
                                                                ),
                                                                title: Text(
                                                                    user[Dbkeys
                                                                            .nickname] ??
                                                                        '',
                                                                    style: TextStyle(
                                                                        color:
                                                                            fiberchatBlack)),
                                                                subtitle: Text(
                                                                    phone,
                                                                    style: TextStyle(
                                                                        color:
                                                                            fiberchatGrey)),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10.0,
                                                                        vertical:
                                                                            0.0),
                                                                onTap: () {
                                                                  setStateIfMounted(
                                                                      () {
                                                                    if (_selectedList.lastIndexWhere((element) =>
                                                                            element[Dbkeys.phone] ==
                                                                            phone) >=
                                                                        0) {
                                                                      _selectedList
                                                                          .remove(
                                                                              snapshot.data!);
                                                                      setStateIfMounted(
                                                                          () {});
                                                                    } else {
                                                                      _selectedList.add(
                                                                          snapshot
                                                                              .data!);
                                                                      setStateIfMounted(
                                                                          () {});
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              Divider()
                                                            ],
                                                          );
                                                        }
                                                        return SizedBox();
                                                      });
                                            },
                                          ),
                                        )))));
            }))));
  }
}
