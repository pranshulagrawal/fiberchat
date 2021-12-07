//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:core';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/auth_screens/login.dart';
import 'package:fiberchat/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat/Services/Admob/admob.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Screens/chat_screen/chat.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:fiberchat/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddunsavedNumber extends StatefulWidget {
  final String? currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  const AddunsavedNumber(
      {required this.currentUserNo, required this.model, required this.prefs});

  @override
  _AddunsavedNumberState createState() => _AddunsavedNumberState();
}

class _AddunsavedNumberState extends State<AddunsavedNumber> {
  bool? isLoading, isUser = true;
  bool istyping = true;
  final BannerAd myBanner = BannerAd(
    adUnitId: getBannerAdUnitId()!,
    size: AdSize.mediumRectangle,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  AdWidget? adWidget;
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      final observer = Provider.of<Observer>(this.context, listen: false);
      if (IsBannerAdShow == true && observer.isadmobshow == true) {
        myBanner.load();
        adWidget = AdWidget(ad: myBanner);
        setState(() {});
      }
    });
  }

  getUser(String searchphone) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(searchphone)
        .get()
        .then((user) {
      if (user.exists &&
          user.data()!.containsKey(Dbkeys.phone) &&
          user.data()!.containsKey(Dbkeys.phoneRaw) &&
          user.data()!.containsKey(Dbkeys.countryCode)) {
        setState(() {
          isLoading = false;
          istyping = false;
          isUser = user.exists;

          if (isUser!) {
            // var peer = user;
            widget.model!.addUser(user);
            Navigator.pushReplacement(
                context,
                new MaterialPageRoute(
                    builder: (context) => new ChatScreen(
                        isSharingIntentForwarded: false,
                        prefs: widget.prefs,
                        unread: 0,
                        currentUserNo: widget.currentUserNo,
                        model: widget.model!,
                        peerNo: searchphone)));
          }
        });
      } else {
        setState(() {
          isLoading = false;
          isUser = false;
          istyping = false;
        });
      }
    }).catchError((err) {});
  }

  final _phoneNo = TextEditingController();

  String? phoneCode = DEFAULT_COUNTTRYCODE_NUMBER;
  Widget buildWidget() {
    final observer = Provider.of<Observer>(context, listen: false);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(17, 52, 17, 8),
          child: Container(
            margin: EdgeInsets.only(top: 0),

            // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            // height: 63,
            height: 63,
            // width: w / 1.18,
            child: Form(
              // key: _enterNumberFormKey,
              child: MobileInputWithOutline(
                buttonhintTextColor: fiberchatGrey,
                borderColor: fiberchatGrey.withOpacity(0.2),
                controller: _phoneNo,
                initialCountryCode: DEFAULT_COUNTTRYCODE_ISO,
                onSaved: (phone) {
                  setState(() {
                    phoneCode = phone!.countryCode;
                    istyping = true;
                  });
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(13, 22, 13, 8),
          child: isLoading == true
              ? Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(fiberchatLightGreen)),
                )
              : MySimpleButton(
                  buttoncolor: fiberchatLightGreen.withOpacity(0.99),
                  buttontext: getTranslated(context, 'searchuser'),
                  onpressed: () {
                    RegExp e164 = new RegExp(r'^\+[1-9]\d{1,14}$');

                    String _phone = _phoneNo.text.toString().trim();
                    if ((_phone.isNotEmpty &&
                            e164.hasMatch(phoneCode! + _phone)) &&
                        widget.currentUserNo != phoneCode! + _phone) {
                      setState(() {
                        isLoading = true;
                      });

                      getUser(phoneCode! + _phone);
                    } else {
                      Fiberchat.toast(
                          widget.currentUserNo != phoneCode! + _phone
                              ? getTranslated(context, 'validnum')
                              : getTranslated(context, 'validnum'));
                    }
                  },
                ),
        ),
        SizedBox(
          height: 20.0,
        ),
        IsBannerAdShow == true &&
                observer.isadmobshow == true &&
                adWidget != null
            ? Container(
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(
                  bottom: 5.0,
                  top: 2,
                ),
                child: adWidget!)
            : SizedBox(
                height: 0,
              ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();

    if (IsBannerAdShow == true) {
      myBanner.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
        scaffold: Fiberchat.getNTPWrappedWidget(Scaffold(
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
          title: Text(
            getTranslated(
              context,
              'chatws',
            ),
            style: TextStyle(
              fontSize: 17,
              color: DESIGN_TYPE == Themetype.whatsapp
                  ? fiberchatWhite
                  : fiberchatBlack,
            ),
          )),
      body: Stack(children: <Widget>[
        Container(
            child: Center(
          child: !isUser!
              ? istyping == true
                  ? SizedBox()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          SizedBox(
                            height: 140,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Text(
                                phoneCode! +
                                    '-' +
                                    _phoneNo.text.trim() +
                                    ' ' +
                                    getTranslated(context, 'notexist') +
                                    Appname,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: fiberchatBlack,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20.0)),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          myElevatedButton(
                            color: fiberchatBlue,
                            child: Text(
                              getTranslated(context, 'invite'),
                              style: TextStyle(color: fiberchatWhite),
                            ),
                            onPressed: () {
                              Fiberchat.invite(context);
                            },
                          ),
                        ])
              : Container(),
        )),
        // Loading
        buildWidget()
      ]),
      backgroundColor: fiberchatWhite,
    )));
  }
}
