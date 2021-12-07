//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/optional_constants.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:flutter/material.dart';

//---DON'T EDIT THESE LINES UNLESS YOU ARE SURE ABOUT THE CHANGES:
// Include all the fields for automatically setting up the very first database to set admin app compatability. This page isalso present in the admin
// app source code and will be automatically triggerred for very first app open of either of them.

String underconstructionmessage =
    'App under maintainance & will be right back.';
Future<bool> batchwrite() async {
  WriteBatch writeBatch = FirebaseFirestore.instance.batch();

//------Below Firestore Document for User app Settings ----------
  writeBatch.set(
      FirebaseFirestore.instance
          .collection(Dbkeys.appsettings)
          .doc(Dbkeys.userapp),
      {
        Dbkeys.istextmessageallowed: true,
        Dbkeys.iscallsallowed: true,
        Dbkeys.ismediamessageallowed: true,
        Dbkeys.isadmobshow: true,
        Dbkeys.isemulatorallowed: true,
        Dbkeys.privacypolicyTYPE: Dbkeys.url,
        Dbkeys.privacypolicy: null, //--- Privacy Policy URL-
        Dbkeys.tncTYPE: Dbkeys.url,
        Dbkeys.tnc: null, //---Terms & Conditions Url-
        Dbkeys.latestappversionandroid: '1.0.0',
        Dbkeys.newapplinkandroid: 'https://www.google.com/',
        Dbkeys.latestappversionios: '1.0.0',
        Dbkeys.newapplinkios: 'https://www.google.com/',
        Dbkeys.latestappversionweb: '1.0.0',
        Dbkeys.newapplinkweb: 'https://www.google.com/',
        Dbkeys.isappunderconstructionandroid: false,
        Dbkeys.isappunderconstructionios: false,
        Dbkeys.isappunderconstructionweb: false,
        Dbkeys.isblocknewlogins: false,
        Dbkeys.isaccountapprovalbyadminneeded: false,
        Dbkeys.accountapprovalmessage:
            'Your account is created successfully ! You can start using the account once the admin approves it.', //----
        Dbkeys.isshowerrorlog: false,
        Dbkeys.maintainancemessage: underconstructionmessage,
        //---------
        Dbkeys.isAllowCreatingGroups: IsAllowCreatingGroups,
        Dbkeys.isAllowCreatingBroadcasts: IsAllowCreatingBroadcasts,
        Dbkeys.isAllowCreatingStatus: IsAllowCreatingStatus,
        Dbkeys.is24hrsTimeformat: Is24hrsTimeformat,
        Dbkeys.isPercentProgressShowWhileUploading:
            IsPercentProgressShowWhileUploading,
        Dbkeys.isCallFeatureTotallyHide: IsCallFeatureTotallyHide,
        Dbkeys.groupMemberslimit: GroupMemberslimit,
        Dbkeys.broadcastMemberslimit: BroadcastMemberslimit,
        Dbkeys.statusDeleteAfterInHours: StatusDeleteAfterInHours,
        Dbkeys.feedbackEmail: FeedbackEmail,
        Dbkeys.isLogoutButtonShowInSettingsPage:
            IsLogoutButtonShowInSettingsPage,
        Dbkeys.maxFileSizeAllowedInMB: MaxFileSizeAllowedInMB,
        Dbkeys.maxNoOfFilesInMultiSharing: MaxNoOfFilesInMultiSharing,
        Dbkeys.maxNoOfContactsSelectForForward: MaxNoOfContactsSelectForForward,
        Dbkeys.appShareMessageStringAndroid: '',
        Dbkeys.appShareMessageStringiOS: '',
        Dbkeys.isCustomAppShareLink: false,
        Dbkeys.updateV7done: true,
      });

//-------Below Firestore Document for Admin Notifications ---------
  writeBatch.set(
      FirebaseFirestore.instance
          .collection(DbPaths.collectionnotifications)
          .doc(DbPaths.adminnotifications),
      {
        Dbkeys.nOTIFICATIONisunseen: true,
        Dbkeys.nOTIFICATIONxxtitle: '',
        Dbkeys.nOTIFICATIONxxdesc: '',
        Dbkeys.nOTIFICATIONxxaction: Dbkeys.nOTIFICATIONactionPUSH,
        Dbkeys.nOTIFICATIONxximageurl: '',
        Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
        Dbkeys.nOTIFICATIONxxpagecomparekey: Dbkeys.docid,
        Dbkeys.nOTIFICATIONxxpagecompareval: '',
        Dbkeys.nOTIFICATIONxxparentid: '',
        Dbkeys.nOTIFICATIONxxextrafield: '',
        Dbkeys.nOTIFICATIONxxpagetype:
            Dbkeys.nOTIFICATIONpagetypeSingleLISTinDOCSNAP,
        Dbkeys.nOTIFICATIONxxpageID: DbPaths.adminnotifications,
        //-----
        Dbkeys.nOTIFICATIONpagecollection1: DbPaths.collectionnotifications,
        Dbkeys.nOTIFICATIONpagedoc1: DbPaths.adminnotifications,
        Dbkeys.nOTIFICATIONpagecollection2: null,
        Dbkeys.nOTIFICATIONpagedoc2: null,
        Dbkeys.nOTIFICATIONtopic: Dbkeys.topicADMIN,
        Dbkeys.list: [],
      });
  //-------Below Firestore Document for Users Notifications ---------
  writeBatch.set(
      FirebaseFirestore.instance
          .collection(DbPaths.collectionnotifications)
          .doc(DbPaths.usersnotifications),
      {
        Dbkeys.nOTIFICATIONisunseen: true,
        Dbkeys.nOTIFICATIONxxtitle: '',
        Dbkeys.nOTIFICATIONxxdesc: '',
        Dbkeys.nOTIFICATIONxxaction: Dbkeys.nOTIFICATIONactionPUSH,
        Dbkeys.nOTIFICATIONxximageurl: '',
        Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
        Dbkeys.nOTIFICATIONxxpagecomparekey: Dbkeys.docid,
        Dbkeys.nOTIFICATIONxxpagecompareval: '',
        Dbkeys.nOTIFICATIONxxparentid: '',
        Dbkeys.nOTIFICATIONxxextrafield: '',
        Dbkeys.nOTIFICATIONxxpagetype:
            Dbkeys.nOTIFICATIONpagetypeSingleLISTinDOCSNAP,
        Dbkeys.nOTIFICATIONxxpageID: DbPaths.usersnotifications,
        //-----
        Dbkeys.nOTIFICATIONpagecollection1: DbPaths.collectionnotifications,
        Dbkeys.nOTIFICATIONpagedoc1: DbPaths.usersnotifications,
        Dbkeys.nOTIFICATIONpagecollection2: null,
        Dbkeys.nOTIFICATIONpagedoc2: null,
        Dbkeys.nOTIFICATIONtopic: Dbkeys.topicUSERS,
        Dbkeys.list: [],
      });
//-------Below Firestore Document for Activity History ---------
  writeBatch.set(
      FirebaseFirestore.instance
          .collection(DbPaths.collectionhistory)
          .doc(DbPaths.collectionhistory),
      {
        Dbkeys.nOTIFICATIONisunseen: true,
        Dbkeys.nOTIFICATIONxxtitle: '',
        Dbkeys.nOTIFICATIONxxdesc: '',
        Dbkeys.nOTIFICATIONxxaction: Dbkeys.nOTIFICATIONactionPUSH,
        Dbkeys.nOTIFICATIONxximageurl: '',
        Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
        Dbkeys.nOTIFICATIONxxpagecomparekey: Dbkeys.docid,
        Dbkeys.nOTIFICATIONxxpagecompareval: '',
        Dbkeys.nOTIFICATIONxxparentid: '',
        Dbkeys.nOTIFICATIONxxextrafield: '',
        Dbkeys.nOTIFICATIONxxpagetype:
            Dbkeys.nOTIFICATIONpagetypeSingleLISTinDOCSNAP,
        Dbkeys.nOTIFICATIONxxpageID: DbPaths.collectionhistory,
        //-----
        Dbkeys.nOTIFICATIONpagecollection1: DbPaths.collectionhistory,
        Dbkeys.nOTIFICATIONpagedoc1: DbPaths.collectionhistory,
        Dbkeys.nOTIFICATIONpagecollection2: '',
        Dbkeys.nOTIFICATIONpagedoc2: '',
        Dbkeys.nOTIFICATIONtopic: Dbkeys.topicADMIN,
        Dbkeys.list: [],
      });
//-------Below Firestore Document for user data counts ---------
  writeBatch.set(
      FirebaseFirestore.instance
          .collection(DbPaths.collectiondashboard)
          .doc(DbPaths.docuserscount),
      {
        Dbkeys.totalapprovedusers: 0,
        Dbkeys.totalblockedusers: 0,
        Dbkeys.totalpendingusers: 0,
        Dbkeys.totalvisitsANDROID: 0,
        Dbkeys.totalvisitsIOS: 0,
      });
//-------Below Firestore Document for chat data counts ---------
  writeBatch.set(
      FirebaseFirestore.instance
          .collection(DbPaths.collectiondashboard)
          .doc(DbPaths.docchatdata),
      {
        Dbkeys.audiocallsmade: 0,
        Dbkeys.videocallsmade: 0,
        Dbkeys.mediamessagessent: 0,
      });

// unless commit is called, nothing happens. So commit is called below---
  writeBatch.commit().catchError((err) {
    return err;
  });
  return true;
}

Future<bool> writeRequiredNewFieldsAllExistingUsers() async {
  await FirebaseFirestore.instance
      .collection(DbPaths.collectionusers)
      .get()
      .then((users) async {
    users.docs.forEach((doc) async {
      doc.reference.set({
        Dbkeys.searchKey: doc.data().containsKey(Dbkeys.nickname)
            ? doc.data()[Dbkeys.nickname].trim().substring(0, 1).toUpperCase()
            : 'U',
        Dbkeys.nickname: doc.data().containsKey(Dbkeys.nickname)
            ? doc.data()[Dbkeys.nickname]
            : 'User',
        Dbkeys.accountstatus: Dbkeys.sTATUSallowed,
        Dbkeys.actionmessage: 'Your account is Approved.',
        Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
        Dbkeys.lastSeen: DateTime.now().millisecondsSinceEpoch,
        Dbkeys.joinedOn: doc.data()[Dbkeys.lastSeen] == null
            ? DateTime.now().millisecondsSinceEpoch
            : doc.data()[Dbkeys.lastSeen] != true
                ? doc.data()[Dbkeys.lastSeen]
                : DateTime.now().millisecondsSinceEpoch,
        Dbkeys.groupsCreated: 0,
        Dbkeys.blockeduserslist: [],
        Dbkeys.videoCallMade: 0,
        Dbkeys.videoCallRecieved: 0,
        Dbkeys.audioCallMade: 0,
        Dbkeys.audioCallRecieved: 0,
        Dbkeys.mssgSent: 0,
        Dbkeys.deviceDetails: {},
        Dbkeys.currentDeviceID: '',
      }, SetOptions(merge: true));

      if (!doc.data().containsKey(Dbkeys.countryCode)) {
        doc.reference.delete();
      } else {
        FirebaseFirestore.instance
            .collection(DbPaths.collectiondashboard)
            .doc(DbPaths.docuserscount)
            .set({
          Dbkeys.totalapprovedusers: FieldValue.increment(1),
        }, SetOptions(merge: true));
      }

      if (!doc.data().containsKey(Dbkeys.countryCode)) {
      } else {
        FirebaseFirestore.instance
            .collection(DbPaths.collectioncountrywiseData)
            .doc(doc.data()[Dbkeys.countryCode])
            .set({
          Dbkeys.totalusers: FieldValue.increment(1),
        }, SetOptions(merge: true));
      }

      if (!doc.data().containsKey(Dbkeys.countryCode)) {
      } else {
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(doc.reference.id)
            .collection(DbPaths.collectionnotifications)
            .doc(DbPaths.collectionnotifications)
            .set({
          Dbkeys.nOTIFICATIONisunseen: true,
          Dbkeys.nOTIFICATIONxxtitle: '',
          Dbkeys.nOTIFICATIONxxdesc: '',
          Dbkeys.nOTIFICATIONxxaction: Dbkeys.nOTIFICATIONactionPUSH,
          Dbkeys.nOTIFICATIONxximageurl: '',
          Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
          Dbkeys.nOTIFICATIONxxpagecomparekey: Dbkeys.docid,
          Dbkeys.nOTIFICATIONxxpagecompareval: '',
          Dbkeys.nOTIFICATIONxxparentid: '',
          Dbkeys.nOTIFICATIONxxextrafield: '',
          Dbkeys.nOTIFICATIONxxpagetype:
              Dbkeys.nOTIFICATIONpagetypeSingleLISTinDOCSNAP,
          Dbkeys.nOTIFICATIONxxpageID: DbPaths.collectionusers,
          //-----
          Dbkeys.nOTIFICATIONpagecollection1: DbPaths.collectionusers,
          Dbkeys.nOTIFICATIONpagedoc1: doc.reference.id,
          Dbkeys.nOTIFICATIONpagecollection2: DbPaths.collectionnotifications,
          Dbkeys.nOTIFICATIONpagedoc2: DbPaths.collectionnotifications,
          Dbkeys.nOTIFICATIONtopic: Dbkeys.topicPARTICULARUSER,
          Dbkeys.list: [],
        });
      }
    });
    return true;
  }).catchError((err) {
    print('BRATCH WRITING FAILED WITH ERROR: ' + err);
    return false;
  });
  return true;
}

Map getTranslateNotificationStringsMap(BuildContext context) {
  Map map = {
    Dbkeys.notificationStringNewTextMessage: getTranslated(context, 'ntm'),
    Dbkeys.notificationStringNewImageMessage: getTranslated(context, 'nim'),
    Dbkeys.notificationStringNewVideoMessage: getTranslated(context, 'nvm'),
    Dbkeys.notificationStringNewAudioMessage: getTranslated(context, 'nam'),
    Dbkeys.notificationStringNewContactMessage: getTranslated(context, 'ncm'),
    Dbkeys.notificationStringNewDocumentMessage: getTranslated(context, 'ndm'),
    Dbkeys.notificationStringNewLocationMessage: getTranslated(context, 'nlm'),
    Dbkeys.notificationStringNewIncomingAudioCall:
        getTranslated(context, 'niac'),
    Dbkeys.notificationStringNewIncomingVideoCall:
        getTranslated(context, 'nivc'),
    Dbkeys.notificationStringCallEnded: getTranslated(context, 'ce'),
    Dbkeys.notificationStringMissedCall: getTranslated(context, 'mc'),
    Dbkeys.notificationStringAcceptOrRejectCall: getTranslated(context, 'aorc'),
    Dbkeys.notificationStringCallRejected: getTranslated(context, 'cr'),
  };
  return map;
}
