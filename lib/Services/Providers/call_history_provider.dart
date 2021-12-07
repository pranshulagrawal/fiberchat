//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreDataProviderCALLHISTORY extends ChangeNotifier {
  final _datalistSnapshot = <DocumentSnapshot>[];
  String _errorMessage = '';
  bool _hasNext = true;
  bool _isFetchingData = false;

  String get errorMessage => _errorMessage;

  bool get hasNext => _hasNext;
  clearall() {
    _datalistSnapshot.clear();
    _hasNext = false;
    _isFetchingData = false;
    recievedDocs.clear();
    notifyListeners();
  }

  deleteSingle(dynamic doc) {
    recievedDocs.removeWhere((element) => element['TIME'] == doc['TIME']);
    _datalistSnapshot..removeWhere((element) => element['TIME'] == doc['TIME']);
    notifyListeners();
  }

  List get recievedDocs => _datalistSnapshot.map((snap) {
        final recievedData = snap.data();

        return recievedData;
      }).toList();
  static Future<QuerySnapshot> getFirestoreCOLLECTIONData(int limit,
      {DocumentSnapshot? startAfter, String? dataType, Query? refdata}) async {
    // final refdata =

    if (startAfter == null) {
      return refdata!.get();
    } else {
      return refdata!.startAfterDocument(startAfter).get();
    }
  }

  Future fetchNextData(
      String? dataType, Query? refdataa, bool isAfterNewdocCreated) async {
    if (_isFetchingData) return;
    _hasNext = true;
    _errorMessage = '';
    _isFetchingData = true;

    try {
      final snap = isAfterNewdocCreated == true
          ? await getFirestoreCOLLECTIONData(10,
              // startAfter: null,
              refdata: refdataa)
          : await getFirestoreCOLLECTIONData(10,
              startAfter:
                  _datalistSnapshot.isNotEmpty ? _datalistSnapshot.last : null,
              refdata: refdataa);
      if (isAfterNewdocCreated == true) {
        _datalistSnapshot.clear();
        _datalistSnapshot.addAll(snap.docs);
      } else {
        _datalistSnapshot.addAll(snap.docs);
      }
      // notifyListeners();
      if (snap.docs.length < 10) _hasNext = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }

    _isFetchingData = false;
  }

  updateparticulardocinProvider({
    required String collection,
    String? document,
    String? compareKey,
    String? compareVal,
    GlobalKey? scaffoldkey,
    GlobalKey? keyloader,
    BuildContext? context,
  }) async {
    int index =
        _datalistSnapshot.indexWhere((prod) => prod[compareKey!] == compareVal);
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(document)
        .get()
        .then((value) {
      _datalistSnapshot.removeAt(index);
      _datalistSnapshot.insert(index, value);
      notifyListeners();
    });
  }

  deleteparticulardocinProvider({
    String? collection,
    String? document,
    String? compareKey,
    String? compareVal,
    GlobalKey? scaffoldkey,
    GlobalKey? keyloader,
    BuildContext? context,
  }) async {
    int index =
        _datalistSnapshot.indexWhere((prod) => prod[compareKey!] == compareVal);

    _datalistSnapshot.removeAt(index);
    notifyListeners();
  }
}
