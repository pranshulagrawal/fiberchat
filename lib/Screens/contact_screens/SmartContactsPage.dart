//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/call_history/callhistory.dart';
import 'package:fiberchat/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat/Screens/contact_screens/contacts.dart';
import 'package:fiberchat/Services/Providers/AvailableContactsProvider.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Screens/chat_screen/chat.dart';
import 'package:fiberchat/Screens/chat_screen/pre_chat.dart';
import 'package:fiberchat/Screens/contact_screens/AddunsavedContact.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Utils/chat_controller.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmartContactsPage extends StatefulWidget {
  final String currentUserNo;
  final DataModel model;
  final bool biometricEnabled;
  final SharedPreferences prefs;
  final Function onTapCreateGroup;
  const SmartContactsPage({
    Key? key,
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
    required this.onTapCreateGroup,
  }) : super(key: key);

  @override
  _SmartContactsPageState createState() => _SmartContactsPageState();
}

class _SmartContactsPageState extends State<SmartContactsPage> {
  Map<String?, String?>? contacts;
  Map<String?, String?>? _filtered = new Map<String, String>();

  final TextEditingController _filter = new TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setInitial(context);
    });
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  setInitial(BuildContext context) {
    final AvailableContactsProvider contactsProvider =
        Provider.of<AvailableContactsProvider>(context, listen: false);
    contactsProvider.setIsLoading(true);
    _appBarTitle = new Text(
      getTranslated(context, 'selectsinglecontact'),
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color:
            DESIGN_TYPE == Themetype.whatsapp ? fiberchatWhite : fiberchatBlack,
      ),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      setStateIfMounted(() {
        _filtered = contactsProvider.filtered;
      });

      contactsProvider.setIsLoading(false);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _filter.dispose();
  }

  Icon _searchIcon = new Icon(
    Icons.search,
    color: DESIGN_TYPE == Themetype.whatsapp ? fiberchatWhite : fiberchatBlack,
  );
  Widget _appBarTitle = Text('');

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
        scaffold: Fiberchat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Consumer<AvailableContactsProvider>(
                  builder: (context, availableContacts, _child) {
                // _filtered = availableContacts.filtered;
                return Scaffold(
                    backgroundColor: Color(0xfff2f2f2),
                    appBar: AppBar(
                      titleSpacing: 5,
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
                      title: _appBarTitle,
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.add_call,
                            color: DESIGN_TYPE == Themetype.whatsapp
                                ? fiberchatWhite
                                : fiberchatBlack,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(context,
                                new MaterialPageRoute(builder: (context) {
                              return new AddunsavedNumber(
                                  prefs: widget.prefs,
                                  model: widget.model,
                                  currentUserNo: widget.currentUserNo);
                            }));
                          },
                        ),
                        IconButton(
                          icon: _searchIcon,
                          onPressed: () {
                            Navigator.pushReplacement(context,
                                new MaterialPageRoute(builder: (context) {
                              return new Contacts(
                                prefs: widget.prefs,
                                model: widget.model,
                                currentUserNo: widget.currentUserNo,
                                biometricEnabled: widget.biometricEnabled,
                              );
                            }));
                          },
                        )
                      ],
                    ),
                    body:
                        //  availableContacts.joinedcontactsInSharePref.length ==
                        //             0 ||
                        availableContacts.searchingcontactsindatabase == true
                            ? loading()
                            : RefreshIndicator(
                                onRefresh: () {
                                  return availableContacts.fetchContacts(
                                      context,
                                      model,
                                      widget.currentUserNo,
                                      widget.prefs);
                                },
                                child: _filtered!.isEmpty
                                    ? ListView(children: [
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
                                                    color: fiberchatBlack,
                                                  )),
                                            ))
                                      ])
                                    : ListView(
                                        padding:
                                            EdgeInsets.only(bottom: 15, top: 0),
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        children: [
                                          ListTile(
                                            tileColor: Colors.white,
                                            leading: CircleAvatar(
                                                backgroundColor:
                                                    fiberchatLightGreen,
                                                radius: 22.5,
                                                child: Icon(
                                                  Icons.share_rounded,
                                                  color: Colors.white,
                                                )),
                                            title: Text(
                                              getTranslated(context, 'share'),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 22.0,
                                                    vertical: 11.0),
                                            onTap: () {
                                              Fiberchat.invite(context);
                                            },
                                          ),
                                          ListTile(
                                            tileColor: Colors.white,
                                            leading: CircleAvatar(
                                                backgroundColor:
                                                    fiberchatLightGreen,
                                                radius: 22.5,
                                                child: Icon(
                                                  Icons.group,
                                                  color: Colors.white,
                                                )),
                                            title: Text(
                                              getTranslated(
                                                  context, 'creategroup'),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 22.0,
                                                    vertical: 11.0),
                                            onTap: () {
                                              widget.onTapCreateGroup();
                                            },
                                          ),
                                          SizedBox(
                                            height: 14,
                                          ),
                                          availableContacts
                                                      .joinedUserPhoneStringAsInServer
                                                      .length ==
                                                  0
                                              ? SizedBox(
                                                  height: 0,
                                                )
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  padding: EdgeInsets.all(00),
                                                  itemCount: availableContacts
                                                      .joinedUserPhoneStringAsInServer
                                                      .length,
                                                  itemBuilder: (context, idx) {
                                                    JoinedUserModel user =
                                                        availableContacts
                                                            .joinedUserPhoneStringAsInServer
                                                            .elementAt(idx);
                                                    String phone = user.phone;
                                                    String name =
                                                        user.name ?? user.phone;
                                                    return FutureBuilder(
                                                      future: availableContacts
                                                          .getUserDoc(phone),
                                                      builder:
                                                          (BuildContext context,
                                                              AsyncSnapshot
                                                                  snapshot) {
                                                        if (snapshot.hasData &&
                                                            snapshot
                                                                .data.exists) {
                                                          return ListTile(
                                                            tileColor:
                                                                Colors.white,
                                                            leading: customCircleAvatar(
                                                                url: snapshot
                                                                        .data[
                                                                    Dbkeys
                                                                        .photoUrl],
                                                                radius: 22),
                                                            title: Text(
                                                                snapshot.data[
                                                                    Dbkeys
                                                                        .nickname],
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
                                                                        22.0,
                                                                    vertical:
                                                                        0.0),
                                                            onTap: () {
                                                              hidekeyboard(
                                                                  context);
                                                              dynamic wUser =
                                                                  model.userData[
                                                                      phone];
                                                              if (wUser !=
                                                                      null &&
                                                                  wUser[Dbkeys
                                                                          .chatStatus] !=
                                                                      null) {
                                                                if (model.currentUser![Dbkeys
                                                                            .locked] !=
                                                                        null &&
                                                                    model
                                                                        .currentUser![Dbkeys
                                                                            .locked]
                                                                        .contains(
                                                                            phone)) {
                                                                  ChatController.authenticate(
                                                                      model,
                                                                      getTranslated(
                                                                          context,
                                                                          'auth_neededchat'),
                                                                      prefs: widget
                                                                          .prefs,
                                                                      shouldPop:
                                                                          false,
                                                                      state: Navigator.of(
                                                                          context),
                                                                      type: Fiberchat.getAuthenticationType(
                                                                          widget
                                                                              .biometricEnabled,
                                                                          model),
                                                                      onSuccess:
                                                                          () {
                                                                    Navigator.pushAndRemoveUntil(
                                                                        context,
                                                                        new MaterialPageRoute(
                                                                            builder: (context) => new ChatScreen(
                                                                                isSharingIntentForwarded: false,
                                                                                prefs: widget.prefs,
                                                                                model: model,
                                                                                currentUserNo: widget.currentUserNo,
                                                                                peerNo: phone,
                                                                                unread: 0)),
                                                                        (Route r) => r.isFirst);
                                                                  });
                                                                } else {
                                                                  Navigator.pushReplacement(
                                                                      context,
                                                                      new MaterialPageRoute(
                                                                          builder: (context) => new ChatScreen(
                                                                              isSharingIntentForwarded: false,
                                                                              prefs: widget.prefs,
                                                                              model: model,
                                                                              currentUserNo: widget.currentUserNo,
                                                                              peerNo: phone,
                                                                              unread: 0)));
                                                                }
                                                              } else {
                                                                Navigator.pushReplacement(
                                                                    context,
                                                                    new MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                  return new PreChat(
                                                                      prefs: widget
                                                                          .prefs,
                                                                      model: widget
                                                                          .model,
                                                                      name:
                                                                          name,
                                                                      phone:
                                                                          phone,
                                                                      currentUserNo:
                                                                          widget
                                                                              .currentUserNo);
                                                                }));
                                                              }
                                                            },
                                                          );
                                                        }
                                                        return ListTile(
                                                          tileColor:
                                                              Colors.white,
                                                          leading:
                                                              customCircleAvatar(
                                                                  radius: 22),
                                                          title: Text(name,
                                                              style: TextStyle(
                                                                  color:
                                                                      fiberchatBlack)),
                                                          subtitle: Text(phone,
                                                              style: TextStyle(
                                                                  color:
                                                                      fiberchatGrey)),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          22.0,
                                                                      vertical:
                                                                          0.0),
                                                          onTap: () {
                                                            hidekeyboard(
                                                                context);
                                                            dynamic wUser =
                                                                model.userData[
                                                                    phone];
                                                            if (wUser != null &&
                                                                wUser[Dbkeys
                                                                        .chatStatus] !=
                                                                    null) {
                                                              if (model.currentUser![
                                                                          Dbkeys
                                                                              .locked] !=
                                                                      null &&
                                                                  model
                                                                      .currentUser![
                                                                          Dbkeys
                                                                              .locked]
                                                                      .contains(
                                                                          phone)) {
                                                                ChatController.authenticate(
                                                                    model,
                                                                    getTranslated(
                                                                        context,
                                                                        'auth_neededchat'),
                                                                    prefs: widget
                                                                        .prefs,
                                                                    shouldPop:
                                                                        false,
                                                                    state: Navigator.of(
                                                                        context),
                                                                    type: Fiberchat.getAuthenticationType(
                                                                        widget
                                                                            .biometricEnabled,
                                                                        model),
                                                                    onSuccess:
                                                                        () {
                                                                  Navigator.pushAndRemoveUntil(
                                                                      context,
                                                                      new MaterialPageRoute(
                                                                          builder: (context) => new ChatScreen(
                                                                              isSharingIntentForwarded: false,
                                                                              prefs: widget.prefs,
                                                                              model: model,
                                                                              currentUserNo: widget.currentUserNo,
                                                                              peerNo: phone,
                                                                              unread: 0)),
                                                                      (Route r) => r.isFirst);
                                                                });
                                                              } else {
                                                                Navigator.pushReplacement(
                                                                    context,
                                                                    new MaterialPageRoute(
                                                                        builder: (context) => new ChatScreen(
                                                                            isSharingIntentForwarded:
                                                                                false,
                                                                            prefs: widget
                                                                                .prefs,
                                                                            model:
                                                                                model,
                                                                            currentUserNo: widget
                                                                                .currentUserNo,
                                                                            peerNo:
                                                                                phone,
                                                                            unread:
                                                                                0)));
                                                              }
                                                            } else {
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  new MaterialPageRoute(
                                                                      builder:
                                                                          (context) {
                                                                return new PreChat(
                                                                    prefs: widget
                                                                        .prefs,
                                                                    model: widget
                                                                        .model,
                                                                    name: name,
                                                                    phone:
                                                                        phone,
                                                                    currentUserNo:
                                                                        widget
                                                                            .currentUserNo);
                                                              }));
                                                            }
                                                          },
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                18, 24, 18, 18),
                                            child: Text(
                                              getTranslated(context, 'invite'),
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.all(0),
                                            itemCount: _filtered!.length,
                                            itemBuilder: (context, idx) {
                                              MapEntry user = _filtered!.entries
                                                  .elementAt(idx);
                                              String phone = user.key;
                                              return availableContacts
                                                          .joinedcontactsInSharePref
                                                          .indexWhere(
                                                              (element) =>
                                                                  element
                                                                      .phone ==
                                                                  phone) >=
                                                      0
                                                  ? Container(
                                                      width: 0,
                                                    )
                                                  : Stack(
                                                      children: [
                                                        ListTile(
                                                          tileColor:
                                                              Colors.white,
                                                          leading: CircleAvatar(
                                                              backgroundColor:
                                                                  fiberchatgreen,
                                                              radius: 22.5,
                                                              child: Text(
                                                                Fiberchat
                                                                    .getInitials(
                                                                        user.value),
                                                                style: TextStyle(
                                                                    color:
                                                                        fiberchatWhite),
                                                              )),
                                                          title: Text(
                                                              user.value,
                                                              style: TextStyle(
                                                                  color:
                                                                      fiberchatBlack)),
                                                          subtitle: Text(phone,
                                                              style: TextStyle(
                                                                  color:
                                                                      fiberchatGrey)),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          22.0,
                                                                      vertical:
                                                                          0.0),
                                                          onTap: () {
                                                            hidekeyboard(
                                                                context);
                                                            Fiberchat.invite(
                                                                context);
                                                          },
                                                        ),
                                                        Positioned(
                                                          right: 19,
                                                          bottom: 19,
                                                          child: InkWell(
                                                              onTap: () {
                                                                hidekeyboard(
                                                                    context);
                                                                Fiberchat.invite(
                                                                    context);
                                                              },
                                                              child: Icon(
                                                                Icons
                                                                    .person_add_alt,
                                                                color:
                                                                    fiberchatgreen,
                                                              )),
                                                        )
                                                      ],
                                                    );
                                            },
                                          ),
                                        ],
                                      )));
              });
            }))));
  }

  loading() {
    return Stack(children: [
      Container(
        child: Center(
            child:
                // Column(
                //     mainAxisSize: MainAxisSize.min,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [Icon(Icons.search, size: 30)])
                CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(fiberchatBlue),
        )),
      )
    ]);
  }
}
