//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:device_info/device_info.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/optional_constants.dart';
import 'package:fiberchat/Screens/homepage/homepage.dart';
import 'package:fiberchat/Screens/privacypolicy&TnC/PdfViewFromCachedUrl.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Utils/phonenumberVariantsGenerator.dart';
import 'package:fiberchat/widgets/PhoneField/intl_phone_field.dart';
import 'package:fiberchat/widgets/PhoneField/phone_number.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Services/localization/language.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiberchat/Models/E2EE/e2ee.dart' as e2ee;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fiberchat/Utils/unawaited.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen(
      {Key? key,
      this.title,
      required this.issecutitysetupdone,
      required this.isaccountapprovalbyadminneeded,
      required this.accountApprovalMessage,
      required this.prefs,
      required this.isblocknewlogins})
      : super(key: key);

  final String? title;
  final bool issecutitysetupdone;
  final bool? isblocknewlogins;
  final bool? isaccountapprovalbyadminneeded;
  final String? accountApprovalMessage;
  final SharedPreferences prefs;
  @override
  LoginScreenState createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String _code = "";
  final _phoneNo = TextEditingController();
  // final _smsCode = TextEditingController();
  final _name = TextEditingController();
  String? phoneCode = DEFAULT_COUNTTRYCODE_NUMBER;
  final storage = new FlutterSecureStorage();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  int _currentStep = 0;

  String? verificationId;
  bool isLoading = false;
  bool isLoading2 = true;
  bool isverficationsent = false;
  dynamic isLoggedIn = false;
  User? currentUser;
  String? deviceid;
  var mapDeviceInfo = {};
  @override
  void initState() {
    super.initState();
    setdeviceinfo();
    seletedlanguage = Language.languageList()
        .where((element) => element.languageCode == 'en')
        .toList()[0];
  }

  setdeviceinfo() async {
    if (Platform.isAndroid == true) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      setState(() {
        deviceid = androidInfo.id + androidInfo.androidId;
        mapDeviceInfo = {
          Dbkeys.deviceInfoMODEL: androidInfo.model,
          Dbkeys.deviceInfoOS: 'android',
          Dbkeys.deviceInfoISPHYSICAL: androidInfo.isPhysicalDevice,
          Dbkeys.deviceInfoDEVICEID: androidInfo.id,
          Dbkeys.deviceInfoOSID: androidInfo.androidId,
          Dbkeys.deviceInfoOSVERSION: androidInfo.version.baseOS,
          Dbkeys.deviceInfoMANUFACTURER: androidInfo.manufacturer,
          Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
        };
      });
    } else if (Platform.isIOS == true) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      setState(() {
        deviceid = iosInfo.systemName + iosInfo.model + iosInfo.systemVersion;
        mapDeviceInfo = {
          Dbkeys.deviceInfoMODEL: iosInfo.model,
          Dbkeys.deviceInfoOS: 'ios',
          Dbkeys.deviceInfoISPHYSICAL: iosInfo.isPhysicalDevice,
          Dbkeys.deviceInfoDEVICEID: iosInfo.identifierForVendor,
          Dbkeys.deviceInfoOSID: iosInfo.name,
          Dbkeys.deviceInfoOSVERSION: iosInfo.name,
          Dbkeys.deviceInfoMANUFACTURER: iosInfo.name,
          Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
        };
      });
    }
  }

  Future<void> verifyPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      handleSignIn(authCredential: phoneAuthCredential);
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setState(() {
        isLoading = false;
        isLoading2 = true;
        _currentStep = 0;
        _phoneNo.clear();

        _code = '';
        isverficationsent = false;
      });
      print(
          'Authentication failed -ERROR: ${authException.message}. Try again later.');

      Fiberchat.toast('Authentication failed - ${authException.message}');
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      setState(() {
        isLoading = false;
        isLoading2 = false;
        isverficationsent = true;
      });

      this.verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      setState(() {
        isLoading = false;
        isLoading2 = false;
        isverficationsent = false;
      });

      this.verificationId = verificationId;
    };

    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: (phoneCode! + _phoneNo.text).trim(),
        timeout: const Duration(seconds: 30),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  subscribeToNotification(String currentUserNo, bool isFreshNewAccount) async {
    await FirebaseMessaging.instance
        .subscribeToTopic(
            '${currentUserNo.replaceFirst(new RegExp(r'\+'), '')}')
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });
    await FirebaseMessaging.instance
        .subscribeToTopic(Dbkeys.topicUSERS)
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });
    await FirebaseMessaging.instance
        .subscribeToTopic(Platform.isAndroid
            ? Dbkeys.topicUSERSandroid
            : Platform.isIOS
                ? Dbkeys.topicUSERSios
                : Dbkeys.topicUSERSweb)
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });

    if (isFreshNewAccount == false) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectiongroups)
          .where(Dbkeys.groupMEMBERSLIST, arrayContains: currentUserNo)
          .get()
          .then((query) async {
        if (query.docs.length > 0) {
          query.docs.forEach((doc) async {
            await FirebaseMessaging.instance
                .subscribeToTopic(
                    "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                .catchError((err) {
              print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
            });
          });
        }
      });
    }
  }

  Future<Null> handleSignIn({AuthCredential? authCredential}) async {
    if (isLoading == false) {
      this.setState(() {
        isLoading = true;
      });
    }

    var phoneNo = (phoneCode! + _phoneNo.text).trim();

    AuthCredential credential;
    if (authCredential == null)
      credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: _code,
      );
    else
      credential = authCredential;
    UserCredential firebaseUser;

    firebaseUser = await firebaseAuth
        .signInWithCredential(credential)
        .catchError((err) async {
      if (err == null) {
      } else {
        if (err.toString().contains('return a value') ||
            err.toString().contains('null') ||
            err == null ||
            err.toString().contains('return') ||
            err.toString().contains('closure') ||
            err.toString().contains('Closure') ||
            err.toString().contains('arguments')) {
        } else {
          Fiberchat.toast(getTranslated(this.context, 'makesureotp'));
          if (mounted)
            setState(() {
              _currentStep = 0;
              _phoneNo.clear();
              _code = '';
              isLoading = false;
              isLoading2 = false;
            });
        }
      }
    });

    // ignore: unnecessary_null_comparison
    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .where(Dbkeys.id, isEqualTo: firebaseUser.user!.uid)
          .get();
      final List documents = result.docs;
      final pair = await e2ee.X25519().generateKeyPair();

      if (documents.isEmpty) {
        await storage.write(
            key: Dbkeys.privateKey, value: pair.secretKey.toBase64());
        // Update data to server if new user
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(phoneNo)
            .set({
          Dbkeys.publicKey: pair.publicKey.toBase64(),
          Dbkeys.privateKey: pair.secretKey.toBase64(),
          Dbkeys.countryCode: phoneCode,
          Dbkeys.nickname: _name.text.trim(),
          Dbkeys.photoUrl: firebaseUser.user!.photoURL ?? '',
          Dbkeys.id: firebaseUser.user!.uid,
          Dbkeys.phone: phoneNo,
          Dbkeys.phoneRaw: _phoneNo.text,
          Dbkeys.authenticationType: AuthenticationType.passcode.index,
          Dbkeys.aboutMe: '',
          //---Additional fields added for Admin app compatible----
          Dbkeys.accountstatus: widget.isaccountapprovalbyadminneeded == true
              ? Dbkeys.sTATUSpending
              : Dbkeys.sTATUSallowed,
          Dbkeys.actionmessage: widget.accountApprovalMessage,
          Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
          Dbkeys.joinedOn: DateTime.now().millisecondsSinceEpoch,
          Dbkeys.searchKey: _name.text.trim().substring(0, 1).toUpperCase(),
          Dbkeys.videoCallMade: 0,
          Dbkeys.videoCallRecieved: 0,
          Dbkeys.audioCallMade: 0,
          Dbkeys.groupsCreated: 0,
          Dbkeys.blockeduserslist: [],
          Dbkeys.audioCallRecieved: 0,
          Dbkeys.mssgSent: 0,
          Dbkeys.deviceDetails: mapDeviceInfo,
          Dbkeys.currentDeviceID: deviceid,
          Dbkeys.phonenumbervariants: phoneNumberVariantsList(
              countrycode: phoneCode, phonenumber: _phoneNo.text)
        }, SetOptions(merge: true));
        currentUser = firebaseUser.user;
        await FirebaseFirestore.instance
            .collection(DbPaths.collectiondashboard)
            .doc(DbPaths.docuserscount)
            .set(
                widget.isaccountapprovalbyadminneeded == false
                    ? {
                        Dbkeys.totalapprovedusers: FieldValue.increment(1),
                      }
                    : {
                        Dbkeys.totalpendingusers: FieldValue.increment(1),
                      },
                SetOptions(merge: true));

        await FirebaseFirestore.instance
            .collection(DbPaths.collectioncountrywiseData)
            .doc(phoneCode)
            .set({
          Dbkeys.totalusers: FieldValue.increment(1),
        }, SetOptions(merge: true));

        await FirebaseFirestore.instance
            .collection(DbPaths.collectionnotifications)
            .doc(DbPaths.adminnotifications)
            .update({
          Dbkeys.nOTIFICATIONxxaction: 'PUSH',
          Dbkeys.nOTIFICATIONxxdesc: widget.isaccountapprovalbyadminneeded ==
                  true
              ? '${_name.text.trim()} has Joined $Appname. APPROVE the user account. You can view the user profile from All Users List.'
              : '${_name.text.trim()} has Joined $Appname. You can view the user profile from All Users List.',
          Dbkeys.nOTIFICATIONxxtitle: 'New User Joined',
          Dbkeys.nOTIFICATIONxximageurl: null,
          Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
          'list': FieldValue.arrayUnion([
            {
              Dbkeys.docid: DateTime.now().millisecondsSinceEpoch.toString(),
              Dbkeys.nOTIFICATIONxxdesc: widget
                          .isaccountapprovalbyadminneeded ==
                      true
                  ? '${_name.text.trim()} has Joined $Appname. APPROVE the user account. You can view the user profile from All Users List.'
                  : '${_name.text.trim()} has Joined $Appname. You can view the user profile from All Users List.',
              Dbkeys.nOTIFICATIONxxtitle: 'New User Joined',
              Dbkeys.nOTIFICATIONxximageurl: null,
              Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
              Dbkeys.nOTIFICATIONxxauthor: currentUser!.uid + 'XXX' + 'userapp',
            }
          ])
        });

        // Write data to local
        await widget.prefs.setString(Dbkeys.id, currentUser!.uid);
        await widget.prefs.setString(Dbkeys.nickname, _name.text.trim());
        await widget.prefs
            .setString(Dbkeys.photoUrl, currentUser!.photoURL ?? '');
        await widget.prefs.setString(Dbkeys.phone, phoneNo);
        await widget.prefs.setString(Dbkeys.countryCode, phoneCode!);
        String? fcmToken = await FirebaseMessaging.instance.getToken();

        await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(phoneNo)
            .set({
          Dbkeys.notificationTokens: [fcmToken]
        }, SetOptions(merge: true));
        unawaited(widget.prefs.setBool(Dbkeys.isTokenGenerated, true));

        // unawaited(Navigator.pushReplacement(
        //     this.context,
        //     MaterialPageRoute(
        //         builder: (context) => Security(
        //               phoneNo,
        //               prefs: widget.prefs,
        //               setPasscode: true,
        //               onSuccess: (newContext) async {
        unawaited(Navigator.pushReplacement(
            this.context,
            MaterialPageRoute(
                builder: (newContext) => Homepage(
                      currentUserNo: phoneNo,
                      isSecuritySetupDone: true,
                      prefs: widget.prefs,
                    ))));
        await widget.prefs.setString(Dbkeys.isSecuritySetupDone, phoneNo);
        await subscribeToNotification(documents[0][Dbkeys.phone], true);

        //   },
        //   title: getTranslated(this.context, 'authh'),
        // ))));
      } else {
        await storage.write(
            key: Dbkeys.privateKey, value: documents[0][Dbkeys.privateKey]);
        String? fcmToken = await FirebaseMessaging.instance.getToken();

        // await FirebaseFirestore.instance
        //     .collection(DbPaths.collectionusers)
        //     .doc(currentUserNo)
        //     .set({
        //   Dbkeys.notificationTokens: [fcmToken],
        //   Dbkeys.deviceDetails: mapDeviceInfo,
        //   Dbkeys.currentDeviceID: deviceid,
        //   // Dbkeys.phonenumbervariants: phoneNumberVariantsList(
        //   //     countrycode: userDoc[Dbkeys.countryCode],
        //   //     phonenumber: userDoc[Dbkeys.phoneRaw])
        // }, SetOptions(merge: true));
        // unawaited(widget.prefs.setBool(Dbkeys.isTokenGenerated, true));
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(phoneNo)
            .update(
              !documents[0].data().containsKey(Dbkeys.deviceDetails)
                  ? {
                      Dbkeys.authenticationType:
                          AuthenticationType.passcode.index,
                      Dbkeys.accountstatus:
                          widget.isaccountapprovalbyadminneeded == true
                              ? Dbkeys.sTATUSpending
                              : Dbkeys.sTATUSallowed,
                      Dbkeys.actionmessage: widget.accountApprovalMessage,
                      Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
                      Dbkeys.joinedOn:
                          documents[0].data()![Dbkeys.lastSeen] != true
                              ? documents[0].data()![Dbkeys.lastSeen]
                              : DateTime.now().millisecondsSinceEpoch,
                      Dbkeys.nickname: _name.text.trim(),
                      Dbkeys.searchKey:
                          _name.text.trim().substring(0, 1).toUpperCase(),
                      Dbkeys.videoCallMade: 0,
                      Dbkeys.videoCallRecieved: 0,
                      Dbkeys.audioCallMade: 0,
                      Dbkeys.audioCallRecieved: 0,
                      Dbkeys.mssgSent: 0,
                      Dbkeys.deviceDetails: mapDeviceInfo,
                      Dbkeys.currentDeviceID: deviceid,
                      Dbkeys.phonenumbervariants: phoneNumberVariantsList(
                          countrycode: documents[0][Dbkeys.countryCode],
                          phonenumber: documents[0][Dbkeys.phoneRaw]),
                      Dbkeys.notificationTokens: [fcmToken],
                    }
                  : {
                      Dbkeys.searchKey:
                          _name.text.trim().substring(0, 1).toUpperCase(),
                      Dbkeys.nickname: _name.text.trim(),
                      Dbkeys.authenticationType:
                          AuthenticationType.passcode.index,
                      Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
                      Dbkeys.deviceDetails: mapDeviceInfo,
                      Dbkeys.currentDeviceID: deviceid,
                      Dbkeys.phonenumbervariants: phoneNumberVariantsList(
                          countrycode: documents[0][Dbkeys.countryCode],
                          phonenumber: documents[0][Dbkeys.phoneRaw]),
                      Dbkeys.notificationTokens: [fcmToken],
                    },
            );
        // Write data to local
        await widget.prefs.setString(Dbkeys.id, documents[0][Dbkeys.id]);
        await widget.prefs.setString(Dbkeys.nickname, _name.text.trim());
        await widget.prefs
            .setString(Dbkeys.photoUrl, documents[0][Dbkeys.photoUrl] ?? '');
        await widget.prefs
            .setString(Dbkeys.aboutMe, documents[0][Dbkeys.aboutMe] ?? '');
        await widget.prefs.setString(Dbkeys.phone, documents[0][Dbkeys.phone]);

        if (widget.issecutitysetupdone == false ||
            // ignore: unnecessary_null_comparison
            widget.issecutitysetupdone == null) {
          // unawaited(Navigator.pushReplacement(
          //     this.context,
          //     MaterialPageRoute(
          // builder: (context) => Security(
          //               phoneNo,
          //               prefs: widget.prefs,
          //               setPasscode: true,
          //               onSuccess: (newContext) async {
          unawaited(Navigator.pushReplacement(
              this.context,
              MaterialPageRoute(
                  builder: (newContext) => Homepage(
                        currentUserNo: phoneNo,
                        isSecuritySetupDone: true,
                        prefs: widget.prefs,
                      ))));
          await widget.prefs.setString(Dbkeys.isSecuritySetupDone, phoneNo);
          await subscribeToNotification(phoneNo, false);

          //   },
          //   title: getTranslated(this.context, 'authh'),
          // ))));
        } else {
          unawaited(Navigator.pushReplacement(this.context,
              new MaterialPageRoute(builder: (context) => FiberchatWrapper())));
          Fiberchat.toast(getTranslated(this.context, 'welcomeback'));
          await subscribeToNotification(documents[0][Dbkeys.phone], false);
        }
      }
    } else {
      Fiberchat.toast(getTranslated(this.context, 'failedlogin'));
    }
  }

  // void _changeLanguage(Language language) async {
  //   Locale _locale = await setLocale(language.languageCode);
  //   FiberchatWrapper.setLocale(this.context, _locale);
  //   setState(() {
  //     seletedlanguage = language;
  //   });

  //   await widget.prefs.setBool('islanguageselected', true);
  // }

  Language? seletedlanguage;
  customclippath(double w, double h) {
    return ClipPath(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: MediaQuery.of(this.context).padding.top),
        height: 400,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: DESIGN_TYPE == Themetype.whatsapp
                  ? [
                      fiberchatgreen,
                      fiberchatDeepGreen,
                    ]
                  : [
                      fiberchatWhite,
                      fiberchatWhite,
                    ]),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: Platform.isIOS ? 0 : 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [],
              ),
            ),
            SizedBox(
              height: w > h ? 0 : 15,
            ),
            w < h
                ? Image.asset(
                    AppLogoPath,
                    width: w / 1.3,
                  )
                : Image.asset(
                    AppLogoPath,
                    height: h / 6,
                  ),
            SizedBox(
              height: 0,
            ),
          ],
        ),
      ),
    );
  }

  // final _enterNumberFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(this.context).size.width;
    var h = MediaQuery.of(this.context).size.height;
    final observer = Provider.of<Observer>(this.context, listen: true);
    return Fiberchat.getNTPWrappedWidget(Scaffold(
      backgroundColor: DESIGN_TYPE == Themetype.whatsapp
          ? fiberchatDeepGreen
          : fiberchatWhite,
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              customclippath(w, h),
              _currentStep == 0
                  ? Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 3.0,
                                color: DESIGN_TYPE == Themetype.whatsapp
                                    ? fiberchatDeepGreen.withOpacity(0.3)
                                    : fiberchatBlack.withOpacity(0.1),
                                spreadRadius: 1.0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          margin: EdgeInsets.fromLTRB(
                              15,
                              MediaQuery.of(this.context).size.height / 2.50,
                              16,
                              0),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 13,
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                // height: 63,
                                height: 83,
                                width: w / 1.24,
                                child: InpuTextBox(
                                  inputFormatter: [
                                    LengthLimitingTextInputFormatter(25),
                                  ],
                                  controller: _name,
                                  leftrightmargin: 0,
                                  showIconboundary: false,
                                  boxcornerradius: 5.5,
                                  boxheight: 50,
                                  hinttext:
                                      getTranslated(this.context, 'name_hint'),
                                  prefixIconbutton: Icon(
                                    Icons.person,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 0),
                                // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                // height: 63,
                                height: 63,
                                width: w / 1.24,
                                child: Form(
                                  // key: _enterNumberFormKey,
                                  child: MobileInputWithOutline(
                                    buttonhintTextColor: fiberchatGrey,
                                    borderColor: fiberchatGrey.withOpacity(0.2),
                                    controller: _phoneNo,
                                    initialCountryCode:
                                        DEFAULT_COUNTTRYCODE_ISO,
                                    onSaved: (phone) {
                                      setState(() {
                                        phoneCode = phone!.countryCode;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(17),
                                child: Text(
                                  getTranslated(this.context, 'sendsmscode'),
                                  // 'Send a SMS Code to verify your number',
                                  textAlign: TextAlign.center,
                                  // style: TextStyle(color: Mycolors.black),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(17, 22, 17, 5),
                                child: isLoading == true
                                    ? Center(
                                        child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    fiberchatLightGreen)),
                                      )
                                    : MySimpleButton(
                                        spacing: 0.3,
                                        height: 57,
                                        buttoncolor:
                                            DESIGN_TYPE == Themetype.whatsapp
                                                ? fiberchatLightGreen
                                                : fiberchatLightGreen,
                                        buttontext: getTranslated(
                                            this.context, 'sendverf'),
                                        onpressed: widget.isblocknewlogins ==
                                                true
                                            ? () {
                                                Fiberchat.toast(
                                                  getTranslated(this.context,
                                                      'logindisabled'),
                                                );
                                              }
                                            : () {
                                                setState(() {});
                                                RegExp e164 = new RegExp(
                                                    r'^\+[1-9]\d{1,14}$');
                                                if (_name.text
                                                    .trim()
                                                    .isNotEmpty) {
                                                  String _phone = _phoneNo.text
                                                      .toString()
                                                      .trim();
                                                  if (_phone.isNotEmpty &&
                                                      e164.hasMatch(phoneCode! +
                                                          _phone)) {
                                                    if (_phone
                                                        .startsWith('0')) {
                                                      setState(() {
                                                        _phone =
                                                            _phone.substring(1);
                                                        _phoneNo.text = _phone;
                                                      });
                                                      setState(() {
                                                        isLoading = true;
                                                        _currentStep = 1;
                                                      });
                                                      verifyPhoneNumber();
                                                    } else {
                                                      setState(() {
                                                        isLoading = true;
                                                        _currentStep = 1;
                                                      });
                                                      verifyPhoneNumber();
                                                    }
                                                  } else {
                                                    Fiberchat.toast(
                                                      getTranslated(
                                                          this.context,
                                                          'entervalidmob'),
                                                    );
                                                  }
                                                } else {
                                                  Fiberchat.toast(getTranslated(
                                                      this.context, 'nameem'));
                                                }
                                              },
                                      ),
                              ),

                              //
                              SizedBox(
                                height: 18,
                              ),
                            ],
                          ),
                        ),
                        observer.privacypolicyType == 'file'
                            ? InkWell(
                                onTap: () {
                                  if (ConnectWithAdminApp == false) {
                                    launch(PRIVACY_POLICY_URL);
                                  } else {
                                    final observer = Provider.of<Observer>(
                                        this.context,
                                        listen: false);

                                    if (observer.privacypolicy == null) {
                                      launch(PRIVACY_POLICY_URL);
                                    } else {
                                      launch(observer.privacypolicy!);
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  width: w * 0.95,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                '${getTranslated(this.context, 'agree')} \n',
                                            style: TextStyle(
                                                color: DESIGN_TYPE ==
                                                        Themetype.whatsapp
                                                    ? fiberchatWhite
                                                        .withOpacity(0.8)
                                                    : fiberchatBlack
                                                        .withOpacity(0.8),
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14.0,
                                                height: 1.7)),
                                        TextSpan(
                                          text: getTranslated(
                                              this.context, 'tnc'),
                                          style: TextStyle(
                                              height: 1.7,
                                              color: fiberchatLightGreen,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14.8),
                                        ),
                                        TextSpan(
                                            text: '  ○  ',
                                            style: TextStyle(
                                                height: 1.7,
                                                color: DESIGN_TYPE ==
                                                        Themetype.whatsapp
                                                    ? fiberchatWhite
                                                        .withOpacity(0.79)
                                                    : fiberchatBlack
                                                        .withOpacity(0.79),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 11.8)),
                                        TextSpan(
                                          text:
                                              getTranslated(this.context, 'pp'),
                                          style: TextStyle(
                                              height: 1.7,
                                              color: fiberchatLightGreen,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14.8),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.all(20),
                                width: w * 0.95,
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              '${getTranslated(this.context, 'agree')} \n',
                                          style: TextStyle(
                                              color: DESIGN_TYPE ==
                                                      Themetype.whatsapp
                                                  ? fiberchatWhite
                                                      .withOpacity(0.8)
                                                  : fiberchatBlack
                                                      .withOpacity(0.8),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14.0,
                                              height: 1.7)),
                                      TextSpan(
                                          text: getTranslated(
                                              this.context, 'tnc'),
                                          style: TextStyle(
                                              height: 1.7,
                                              color: fiberchatLightGreen,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14.8),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              if (ConnectWithAdminApp ==
                                                  false) {
                                                launch(TERMS_CONDITION_URL);
                                              } else {
                                                final observer =
                                                    Provider.of<Observer>(
                                                        this.context,
                                                        listen: false);
                                                if (observer.tncType == 'url') {
                                                  if (observer.tnc == null) {
                                                    launch(TERMS_CONDITION_URL);
                                                  } else {
                                                    launch(observer.tnc!);
                                                  }
                                                } else if (observer.tncType ==
                                                    'file') {
                                                  Navigator.push(
                                                      this.context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            PDFViewerCachedFromUrl(
                                                          title: getTranslated(
                                                              this.context,
                                                              'tnc'),
                                                          url: observer.tnc,
                                                          isregistered: false,
                                                        ),
                                                      ));
                                                }
                                              }
                                            }),
                                      TextSpan(
                                          text: '  ○  ',
                                          style: TextStyle(
                                              height: 1.7,
                                              color: DESIGN_TYPE ==
                                                      Themetype.whatsapp
                                                  ? fiberchatWhite
                                                      .withOpacity(0.79)
                                                  : fiberchatBlack
                                                      .withOpacity(0.79),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 11.8)),
                                      TextSpan(
                                          text:
                                              getTranslated(this.context, 'pp'),
                                          style: TextStyle(
                                              height: 1.7,
                                              color: fiberchatLightGreen,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14.8),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              if (ConnectWithAdminApp ==
                                                  false) {
                                                launch(PRIVACY_POLICY_URL);
                                              } else {
                                                if (observer
                                                        .privacypolicyType ==
                                                    'url') {
                                                  if (observer.privacypolicy ==
                                                      null) {
                                                    launch(PRIVACY_POLICY_URL);
                                                  } else {
                                                    launch(observer
                                                        .privacypolicy!);
                                                  }
                                                } else if (observer
                                                        .privacypolicyType ==
                                                    'file') {
                                                  Navigator.push(
                                                      this.context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            PDFViewerCachedFromUrl(
                                                          title: getTranslated(
                                                              this.context,
                                                              'pp'),
                                                          url: observer
                                                              .privacypolicy,
                                                          isregistered: false,
                                                        ),
                                                      ));
                                                }
                                              }
                                            }),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 3.0,
                            color: DESIGN_TYPE == Themetype.whatsapp
                                ? fiberchatgreen.withOpacity(0.3)
                                : fiberchatBlack.withOpacity(0.1),
                            spreadRadius: 1.0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.fromLTRB(
                          15,
                          MediaQuery.of(this.context).size.height / 2.50,
                          16,
                          0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 13,
                          ),

                          Container(
                            margin: EdgeInsets.all(25),
                            // height: 70,
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: PinFieldAutoFill(
                                codeLength: 6,
                                decoration: UnderlineDecoration(
                                  bgColorBuilder: FixedColorBuilder(
                                      fiberchatGrey.withOpacity(0.1)),
                                  textStyle: TextStyle(
                                      fontSize: 22,
                                      color: fiberchatBlack,
                                      fontWeight: FontWeight.bold),
                                  colorBuilder: FixedColorBuilder(
                                      fiberchatGrey.withOpacity(0.1)),
                                ),
                                currentCode: _code,
                                onCodeSubmitted: (code) {
                                  setState(() {
                                    _code = code;
                                  });
                                  if (code.length == 6) {
                                    setState(() {
                                      isLoading2 = true;
                                    });
                                    handleSignIn();
                                  } else {
                                    Fiberchat.toast(getTranslated(
                                        this.context, 'correctotp'));
                                  }
                                },
                                onCodeChanged: (code) {
                                  if (code!.length == 6) {
                                    FocusScope.of(this.context)
                                        .requestFocus(FocusNode());
                                    setState(() {
                                      _code = code;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.all(17),
                            child: Text(
                              isverficationsent == false
                                  ? getTranslated(
                                          this.context, 'sending_code') +
                                      ' $phoneCode-${_phoneNo.text}'
                                  : getTranslated(
                                          this.context, 'enter_verfcode') +
                                      ' $phoneCode-${_phoneNo.text}',
                              textAlign: TextAlign.center,
                              style: TextStyle(height: 1.5),

                              // style: TextStyle(color: Mycolors.black),
                            ),
                          ),
                          isLoading2 == true
                              ? Center(
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          fiberchatLightGreen)),
                                )
                              : Padding(
                                  padding: EdgeInsets.fromLTRB(17, 22, 17, 5),
                                  child: MySimpleButton(
                                    height: 57,
                                    buttoncolor:
                                        DESIGN_TYPE == Themetype.whatsapp
                                            ? fiberchatLightGreen
                                            : fiberchatLightGreen,
                                    buttontext: getTranslated(
                                        this.context, 'verify_otp'),
                                    onpressed: () {
                                      if (_code.length == 6) {
                                        setState(() {
                                          isLoading2 = true;
                                        });
                                        handleSignIn();
                                      } else
                                        Fiberchat.toast(getTranslated(
                                            this.context, 'correctotp'));
                                    },
                                  ),
                                ),
                          isLoading2 == true
                              ? SizedBox(
                                  height: 20,
                                )
                              : InkWell(
                                  onTap: () {
                                    setState(() {
                                      isLoading = false;
                                      _currentStep = 0;
                                      _phoneNo.clear();
                                      _code = '';
                                    });
                                  },
                                  child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(13, 22, 13, 8),
                                      child: Center(
                                        child: Text(
                                          getTranslated(this.context, 'Back'),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15),
                                        ),
                                      )),
                                ),
                          //
                          SizedBox(
                            height: 18,
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ],
      )),
    ));
  }
}

//___CONSTRUCTORS----

class MySimpleButton extends StatefulWidget {
  final Color? buttoncolor;
  final Color? buttontextcolor;
  final Color? shadowcolor;
  final String? buttontext;
  final double? width;
  final double? height;
  final double? spacing;
  final double? borderradius;
  final Function? onpressed;

  MySimpleButton(
      {this.buttontext,
      this.buttoncolor,
      this.height,
      this.spacing,
      this.borderradius,
      this.width,
      this.buttontextcolor,
      // this.icon,
      this.onpressed,
      // this.forcewidget,
      this.shadowcolor});
  @override
  _MySimpleButtonState createState() => _MySimpleButtonState();
}

class _MySimpleButtonState extends State<MySimpleButton> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(this.context).size.width;
    return GestureDetector(
        onTap: widget.onpressed as void Function()?,
        child: Container(
          alignment: Alignment.center,
          width: widget.width ?? w - 40,
          height: widget.height ?? 50,
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Text(
            widget.buttontext ?? getTranslated(this.context, 'submit'),
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: widget.spacing ?? 2,
              fontSize: 15,
              color: widget.buttontextcolor ?? Colors.white,
            ),
          ),
          decoration: BoxDecoration(
              color: widget.buttoncolor ?? Colors.primaries as Color?,
              //gradient: LinearGradient(colors: [bgColor, whiteColor]),
              boxShadow: [
                BoxShadow(
                    color: widget.shadowcolor ?? Colors.transparent,
                    blurRadius: 10,
                    spreadRadius: 2)
              ],
              border: Border.all(
                color: widget.buttoncolor ?? fiberchatgreen,
              ),
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.borderradius ?? 5))),
        ));
  }
}

class MobileInputWithOutline extends StatefulWidget {
  final String? initialCountryCode;
  final String? hintText;
  final double? height;
  final double? width;
  final TextEditingController? controller;
  final Color? borderColor;
  final Color? buttonTextColor;
  final Color? buttonhintTextColor;
  final TextStyle? hintStyle;
  final String? buttonText;
  final Function(PhoneNumber? phone)? onSaved;

  MobileInputWithOutline(
      {this.height,
      this.width,
      this.borderColor,
      this.buttonhintTextColor,
      this.hintStyle,
      this.buttonTextColor,
      this.onSaved,
      this.hintText,
      this.controller,
      this.initialCountryCode,
      this.buttonText});
  @override
  _MobileInputWithOutlineState createState() => _MobileInputWithOutlineState();
}

class _MobileInputWithOutlineState extends State<MobileInputWithOutline> {
  BoxDecoration boxDecoration(
      {double radius = 5,
      Color bgColor = Colors.white,
      var showShadow = false}) {
    return BoxDecoration(
        color: bgColor,
        boxShadow: showShadow
            ? [
                BoxShadow(
                    color: fiberchatgreen, blurRadius: 10, spreadRadius: 2)
              ]
            : [BoxShadow(color: Colors.transparent)],
        border:
            Border.all(color: widget.borderColor ?? Colors.grey, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(radius)));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsetsDirectional.only(bottom: 7, top: 5),
          height: widget.height ?? 50,
          width: widget.width ?? MediaQuery.of(this.context).size.width,
          decoration: boxDecoration(),
          child: IntlPhoneField(
              dropDownArrowColor:
                  widget.buttonhintTextColor ?? Colors.grey[300],
              textAlign: TextAlign.left,
              initialCountryCode: widget.initialCountryCode,
              controller: widget.controller,
              style: TextStyle(
                  height: 1.35,
                  letterSpacing: 1,
                  fontSize: 16.0,
                  color: widget.buttonTextColor ?? Colors.black87,
                  fontWeight: FontWeight.bold),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(3, 15, 8, 0),
                  hintText: widget.hintText ??
                      getTranslated(this.context, 'enter_mobilenumber'),
                  hintStyle: widget.hintStyle ??
                      TextStyle(
                          letterSpacing: 1,
                          height: 0.0,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w400,
                          color: widget.buttonhintTextColor ?? fiberchatGrey),
                  fillColor: Colors.white,
                  filled: true,
                  border: new OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    borderSide: BorderSide.none,
                  )),
              onChanged: (phone) {
                widget.onSaved!(phone);
              },
              validator: (v) {
                return null;
              },
              onSaved: widget.onSaved),
        ),
        // Positioned(
        //     left: 110,
        //     child: Container(
        //       width: 1.5,
        //       height: widget.height ?? 48,
        //       color: widget.borderColor ?? Colors.grey,
        //     ))
      ],
    );
  }
}

class InpuTextBox extends StatefulWidget {
  final Color? boxbcgcolor;
  final Color? boxbordercolor;
  final double? boxcornerradius;
  final double? fontsize;
  final double? boxwidth;
  final double? boxborderwidth;
  final double? boxheight;
  final EdgeInsets? forcedmargin;
  final double? letterspacing;
  final double? leftrightmargin;
  final TextEditingController? controller;
  final Function(String val)? validator;
  final Function(String? val)? onSaved;
  final Function(String val)? onchanged;
  final TextInputType? keyboardtype;
  final TextCapitalization? textCapitalization;

  final String? title;
  final String? subtitle;
  final String? hinttext;
  final String? placeholder;
  final int? maxLines;
  final int? minLines;
  final int? maxcharacters;
  final bool? isboldinput;
  final bool? obscuretext;
  final bool? autovalidate;
  final bool? disabled;
  final bool? showIconboundary;
  final Widget? sufficIconbutton;
  final List<TextInputFormatter>? inputFormatter;
  final Widget? prefixIconbutton;

  InpuTextBox(
      {this.controller,
      this.boxbordercolor,
      this.boxheight,
      this.fontsize,
      this.leftrightmargin,
      this.letterspacing,
      this.forcedmargin,
      this.boxwidth,
      this.boxcornerradius,
      this.boxbcgcolor,
      this.hinttext,
      this.boxborderwidth,
      this.onSaved,
      this.textCapitalization,
      this.onchanged,
      this.placeholder,
      this.showIconboundary,
      this.subtitle,
      this.disabled,
      this.keyboardtype,
      this.inputFormatter,
      this.validator,
      this.title,
      this.maxLines,
      this.autovalidate,
      this.prefixIconbutton,
      this.maxcharacters,
      this.isboldinput,
      this.obscuretext,
      this.sufficIconbutton,
      this.minLines});
  @override
  _InpuTextBoxState createState() => _InpuTextBoxState();
}

class _InpuTextBoxState extends State<InpuTextBox> {
  bool isobscuretext = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      isobscuretext = widget.obscuretext ?? false;
    });
  }

  changeobscure() {
    setState(() {
      isobscuretext = !isobscuretext;
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(this.context).size.width;
    return Align(
      child: Container(
        margin: EdgeInsets.fromLTRB(
            widget.leftrightmargin ?? 8, 5, widget.leftrightmargin ?? 8, 5),
        width: widget.boxwidth ?? w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // color: Colors.white,
              height: widget.boxheight ?? 50,
              // decoration: BoxDecoration(
              //     color: widget.boxbcgcolor ?? Colors.white,
              //     border: Border.all(
              //         color:
              //             widget.boxbordercolor ?? Mycolors.grey.withOpacity(0.2),
              //         style: BorderStyle.solid,
              //         width: 1.8),
              //     borderRadius: BorderRadius.all(
              //         Radius.circular(widget.boxcornerradius ?? 5))),
              child: TextFormField(
                minLines: widget.minLines ?? null,
                maxLines: widget.maxLines ?? 1,
                controller: widget.controller ?? null,
                obscureText: isobscuretext,
                onSaved: widget.onSaved ?? (val) {},
                readOnly: widget.disabled ?? false,
                onChanged: widget.onchanged ?? (val) {},
                maxLength: widget.maxcharacters ?? null,
                validator:
                    widget.validator as String? Function(String?)? ?? null,
                keyboardType: widget.keyboardtype ?? null,
                autovalidateMode: widget.autovalidate == true
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                inputFormatters: widget.inputFormatter ?? [],
                textCapitalization:
                    widget.textCapitalization ?? TextCapitalization.sentences,
                style: TextStyle(
                  letterSpacing: widget.letterspacing ?? null,
                  fontSize: widget.fontsize ?? 15,
                  fontWeight: widget.isboldinput == true
                      ? FontWeight.w600
                      : FontWeight.w400,
                  // fontFamily:
                  //     widget.isboldinput == true ? 'NotoBold' : 'NotoRegular',
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                    prefixIcon: widget.prefixIconbutton != null
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                    width: widget.boxborderwidth ?? 1.5,
                                    color: widget.showIconboundary == true ||
                                            widget.showIconboundary == null
                                        ? Colors.grey.withOpacity(0.3)
                                        : Colors.transparent),
                              ),
                              // color: Colors.white,
                            ),
                            margin: EdgeInsets.only(
                                left: 2, right: 5, top: 2, bottom: 2),
                            // height: 45,
                            alignment: Alignment.center,
                            width: 50,
                            child: widget.prefixIconbutton != null
                                ? widget.prefixIconbutton
                                : null)
                        : null,
                    suffixIcon: widget.sufficIconbutton != null ||
                            widget.obscuretext == true
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                    width: widget.boxborderwidth ?? 1.5,
                                    color: widget.showIconboundary == true ||
                                            widget.showIconboundary == null
                                        ? Colors.grey.withOpacity(0.3)
                                        : Colors.transparent),
                              ),
                              // color: Colors.white,
                            ),
                            margin: EdgeInsets.only(
                                left: 2, right: 5, top: 2, bottom: 2),
                            // height: 45,
                            alignment: Alignment.center,
                            width: 50,
                            child: widget.sufficIconbutton != null
                                ? widget.sufficIconbutton
                                : widget.obscuretext == true
                                    ? IconButton(
                                        icon: Icon(
                                            isobscuretext == true
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: Colors.blueGrey),
                                        onPressed: () {
                                          changeobscure();
                                        })
                                    : null)
                        : null,
                    filled: true,
                    fillColor: widget.boxbcgcolor ?? Colors.white,
                    enabledBorder: OutlineInputBorder(
                      // width: 0.0 produces a thin "hairline" border
                      borderRadius:
                          BorderRadius.circular(widget.boxcornerradius ?? 1),
                      borderSide: BorderSide(
                          color: widget.boxbordercolor ??
                              Colors.grey.withOpacity(0.2),
                          width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // width: 0.0 produces a thin "hairline" border
                      borderRadius:
                          BorderRadius.circular(widget.boxcornerradius ?? 1),
                      borderSide: BorderSide(color: fiberchatgreen, width: 1.5),
                    ),
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.boxcornerradius ?? 1),
                        borderSide: BorderSide(color: Colors.grey)),
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    // labelText: 'Password',
                    hintText: widget.hinttext ?? '',
                    // fillColor: widget.boxbcgcolor ?? Colors.white,

                    hintStyle: TextStyle(
                        letterSpacing: widget.letterspacing ?? 1.5,
                        color: fiberchatGrey,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w400)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
