//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Services/Providers/StatusProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Utils/open_settings.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvailableContactsProvider with ChangeNotifier {
  final TextEditingController _filter = new TextEditingController();
  Map<String?, String?>? contacts;
  Map<String?, String?>? filtered = new Map<String, String>();
  // late String _query;

  bool searchingcontactsindatabase = true;
  List availableContactslastTime = [];
  List contactsAvailableInPhone = [];
  List<JoinedUserModel> joinedcontactsInSharePref = [];
  List<JoinedUserModel> joinedUserPhoneStringAsInServer = [];
  List<dynamic> phoneNumberVariants = [];
  fetchContacts(BuildContext context, DataModel? model, String currentuserphone,
      SharedPreferences prefs,
      {List<dynamic>? currentuserphoneNumberVariants}) async {
    if (currentuserphoneNumberVariants != null) {
      phoneNumberVariants = currentuserphoneNumberVariants;
    }
    await getContacts(context, model).then((value) async {
      final List<JoinedUserModel> decodedPhoneStrings = prefs
                      .getString('availablePhoneString') ==
                  null ||
              prefs.getString('availablePhoneString') == ''
          ? []
          : JoinedUserModel.decode(prefs.getString('availablePhoneString')!);
      final List<JoinedUserModel> decodedPhoneAndNameStrings =
          prefs.getString('availablePhoneAndNameString') == null ||
                  prefs.getString('availablePhoneAndNameString') == ''
              ? []
              : JoinedUserModel.decode(
                  prefs.getString('availablePhoneAndNameString')!);
      joinedcontactsInSharePref = decodedPhoneStrings;
      joinedUserPhoneStringAsInServer = decodedPhoneAndNameStrings;

      await searchAvailableContactsInDatabase(
        context,
        currentuserphone,
        prefs,
      );

      notifyListeners();
    });
  }

  setIsLoading(bool val) {
    searchingcontactsindatabase = val;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _filter.dispose();
  }

  Future<Map<String?, String?>> getContacts(
      BuildContext context, DataModel? model,
      {bool refresh = false}) async {
    Completer<Map<String?, String?>> completer =
        new Completer<Map<String?, String?>>();

    LocalStorage storage = LocalStorage(Dbkeys.cachedContacts);

    Map<String?, String?> _cachedContacts = {};

    completer.future.then((c) {
      c.removeWhere((key, val) => _isHidden(key, model));

      this.contacts = this.filtered = c;
    });

    Fiberchat.checkAndRequestPermission(Permission.contacts).then((res) {
      if (res) {
        storage.ready.then((ready) async {
          if (ready) {
            String? getNormalizedNumber(String? number) {
              if (number == null) return null;
              return number.replaceAll(new RegExp('[^0-9+]'), '');
            }

            ContactsService.getContacts(withThumbnails: false)
                .then((Iterable<Contact> contacts) async {
              contacts.where((c) => c.phones!.isNotEmpty).forEach((Contact p) {
                if (p.displayName != null && p.phones!.isNotEmpty) {
                  List<String?> numbers = p.phones!
                      .map((number) {
                        String? _phone = getNormalizedNumber(number.value);

                        return _phone;
                      })
                      .toList()
                      .where((s) => s != null)
                      .toList();

                  numbers.forEach((number) {
                    _cachedContacts[number] = p.displayName;
                  });
                }
              });

              completer.complete(_cachedContacts);
            });
          }
          // }
        });
      } else {
        Fiberchat.showRationale(getTranslated(context, 'perm_contact'));
        Navigator.pushReplacement(context,
            new MaterialPageRoute(builder: (context) => OpenSettings()));
      }
    }).catchError((onError) {
      Fiberchat.showRationale('Error occured: $onError');
    });
    notifyListeners();
    return completer.future;
  }

  String? getNormalizedNumber(String number) {
    if (number.isEmpty) {
      return null;
    }

    return number.replaceAll(new RegExp('[^0-9+]'), '');
  }

  _isHidden(String? phoneNo, DataModel? model) {
    Map<String, dynamic> _currentUser = model!.currentUser!;
    return _currentUser[Dbkeys.hidden] != null &&
        _currentUser[Dbkeys.hidden].contains(phoneNo);
  }

  // List<DocumentSnapshot<dynamic>> contactsAvailable = [];
  searchAvailableContactsInDatabase(
    BuildContext context,
    String currentuserphone,
    SharedPreferences existingPrefs,
  ) async {
    if (searchingcontactsindatabase == false &&
            contactsAvailableInPhone.length == filtered!.length ||
        filtered!.length < 1) {
      searchingcontactsindatabase = false;
      notifyListeners();
      // print(
      //     'SKIPPED SEARCHING - AS ${filtered!.entries.length} CONTACTS ALREADY CHECKED IN DATABASE, ${joinedUserPhoneStringAsInServer.length} EXISTS');
    } else {
      // print(
      //     'STARTED SEARCHING : ${filtered!.entries.length} CONTACTS  IN DATABASE');
      // contactsAvailable.clear();

      filtered!.forEach((key, value) async {
        contactsAvailableInPhone.add(key);
        if ((joinedcontactsInSharePref
                    .indexWhere((element) => element.phone == key) <
                0) &&
            (!phoneNumberVariants.contains(key))) {
          if (!availableContactslastTime.contains(key)) {
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .where(Dbkeys.phonenumbervariants, arrayContains: key)
                .get()
                .then((docs) async {
              if (docs.docs.length > 0) {
                // print('FOUND CONTACT $key');

                if (docs.docs[0].data().containsKey(Dbkeys.joinedOn)) {
                  if (joinedUserPhoneStringAsInServer.indexWhere((element) =>
                              element.phone == docs.docs[0][Dbkeys.phone]) <
                          0 &&
                      docs.docs[0][Dbkeys.phone] != currentuserphone) {
                    docs.docs[0]
                        .data()[Dbkeys.phonenumbervariants]
                        .toList()
                        .forEach((phone) async {
                      joinedcontactsInSharePref
                          .add(JoinedUserModel(phone: phone ?? ''));

                      final String encodedavailablePhoneString =
                          JoinedUserModel.encode(joinedcontactsInSharePref);
                      await existingPrefs.setString(
                          'availablePhoneString', encodedavailablePhoneString);
                    });
                    joinedUserPhoneStringAsInServer.add(JoinedUserModel(
                        phone: docs.docs[0].data()[Dbkeys.phone] ?? '',
                        name: value ?? docs.docs[0].data()[Dbkeys.phone]));

                    final String encodedjoinedUserPhoneStringAsInServer =
                        JoinedUserModel.encode(joinedUserPhoneStringAsInServer);
                    await existingPrefs.setString('availablePhoneAndNameString',
                        encodedjoinedUserPhoneStringAsInServer);
                    int i = joinedUserPhoneStringAsInServer.indexWhere(
                        (element) => element.phone == currentuserphone);
                    if (i >= 0) {
                      joinedUserPhoneStringAsInServer..removeAt(i);
                      joinedcontactsInSharePref.removeAt(i);
                    }
                  }

                  if (key == filtered!.entries.last.key) {
                    searchingcontactsindatabase = false;
                    if (joinedUserPhoneStringAsInServer.length > 8 &&
                        joinedUserPhoneStringAsInServer.length < 10) {
                      searchingcontactsindatabase = false;
                      // print(
                      //     'SEARCH COMPLETED , ${joinedUserPhoneStringAsInServer.length}CONTACTS EXISTS IN DATABASE');
                      final StatusProvider statusProvider =
                          Provider.of<StatusProvider>(context, listen: false);
                      await statusProvider.searchContactStatus(
                          currentuserphone, joinedUserPhoneStringAsInServer);
                    }
                  }
                } else {
                  if (key == filtered!.entries.last.key) {
                    searchingcontactsindatabase = false;

                    notifyListeners();
                    // print(
                    //     'SEARCH COMPLETED , ${joinedUserPhoneStringAsInServer.length}CONTACTS EXISTS IN DATABASE');
                    final StatusProvider statusProvider =
                        Provider.of<StatusProvider>(context, listen: false);
                    await statusProvider.searchContactStatus(
                        currentuserphone, joinedUserPhoneStringAsInServer);
                  }
                }
              } else {
                if (key == filtered!.entries.last.key) {
                  searchingcontactsindatabase = false;
                  // print(
                  //     'SEARCH COMPLETED , ${joinedUserPhoneStringAsInServer.length} CONTACTS EXISTS IN DATABASE');
                  notifyListeners();
                  final StatusProvider statusProvider =
                      Provider.of<StatusProvider>(context, listen: false);
                  await statusProvider.searchContactStatus(
                      currentuserphone, joinedUserPhoneStringAsInServer);
                } else if (filtered!.length == 0) {
                  searchingcontactsindatabase = false;
                  // print(
                  //     'SEARCH COMPLETED , ${joinedUserPhoneStringAsInServer.length} CONTACTS EXISTS IN DATABASE');
                  notifyListeners();
                  final StatusProvider statusProvider =
                      Provider.of<StatusProvider>(context, listen: false);
                  await statusProvider.searchContactStatus(
                      currentuserphone, joinedUserPhoneStringAsInServer);
                }
              }
            });
          } else {
            if (key == filtered!.entries.last.key) {
              searchingcontactsindatabase = false;
              // print(
              //     'SEARCH COMPLETED , ${joinedUserPhoneStringAsInServer.length} CONTACTS EXISTS IN DATABASE');
              notifyListeners();
              final StatusProvider statusProvider =
                  Provider.of<StatusProvider>(context, listen: false);
              await statusProvider.searchContactStatus(
                  currentuserphone, joinedUserPhoneStringAsInServer);
            }
          }
        } else {
          // print('NO NEED TO SEARCH $key, ALREADY SEARCHED & EXISTS');
          if (key == filtered!.entries.last.key) {
            searchingcontactsindatabase = false;
            // print(
            //     'SEARCH COMPLETED , ${joinedUserPhoneStringAsInServer.length} CONTACTS EXISTS IN DATABASE');
            notifyListeners();
            final StatusProvider statusProvider =
                Provider.of<StatusProvider>(context, listen: false);
            await statusProvider.searchContactStatus(
                currentuserphone, joinedUserPhoneStringAsInServer);
          }
        }
      });
    }
  }

  List<DocumentSnapshot> storedUserDoc = [];

  Future<DocumentSnapshot> getUserDoc(String phone) async {
    if (storedUserDoc.indexWhere((element) => element[Dbkeys.phone] == phone) >=
        0) {
      return storedUserDoc[storedUserDoc
          .indexWhere((element) => element[Dbkeys.phone] == phone)];
    } else {
      var doc = await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(phone)
          .get();
      storedUserDoc.add(doc);

      return doc;
    }
  }
}

class JoinedUserModel {
  final String phone;
  final String? name;

  JoinedUserModel({
    required this.phone,
    this.name,
  });

  factory JoinedUserModel.fromJson(Map<String, dynamic> jsonData) {
    return JoinedUserModel(
      phone: jsonData['phone'],
      name: jsonData['name'],
    );
  }

  static Map<String, dynamic> toMap(JoinedUserModel contact) => {
        'phone': contact.phone,
        'name': contact.name,
      };

  static String encode(List<JoinedUserModel> contacts) => json.encode(
        contacts
            .map<Map<String, dynamic>>(
                (contact) => JoinedUserModel.toMap(contact))
            .toList(),
      );

  static List<JoinedUserModel> decode(String contacts) =>
      (json.decode(contacts) as List<dynamic>)
          .map<JoinedUserModel>((item) => JoinedUserModel.fromJson(item))
          .toList();
}
