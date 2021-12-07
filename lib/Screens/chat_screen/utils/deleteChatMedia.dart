//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:firebase_storage/firebase_storage.dart';

getFileName(id, timestamp) {
  return "$id-$timestamp";
}

Future<bool?> deleteMsgMedia(
    Map<String, dynamic> realtimeDoc, String chatId) async {
  //return 'true' if media deleted successfully.
  try {
    if (realtimeDoc[Dbkeys.messageType] == MessageType.text.index) {
      // no media to delete since text--
      return true;
    }
    if (realtimeDoc[Dbkeys.messageType] == MessageType.contact.index) {
      // no media to delete since text--
      return true;
    }
    if (realtimeDoc[Dbkeys.messageType] == MessageType.location.index) {
      // no media to delete since text--
      return true;
    }
    if (realtimeDoc[Dbkeys.messageType] == MessageType.image.index) {
      await FirebaseStorage.instance
          .ref("+00_CHAT_MEDIA/$chatId/")
          .child(getFileName(
              realtimeDoc[Dbkeys.from], realtimeDoc[Dbkeys.timestamp]))
          .delete();
      return true;
    } else if (realtimeDoc[Dbkeys.messageType] == MessageType.doc.index) {
      await FirebaseStorage.instance
          .ref("+00_CHAT_MEDIA/$chatId/")
          .child(getFileName(
              realtimeDoc[Dbkeys.from], realtimeDoc[Dbkeys.timestamp]))
          .delete();
      return true;
    } else if (realtimeDoc[Dbkeys.messageType] == MessageType.audio.index) {
      await FirebaseStorage.instance
          .ref("+00_CHAT_MEDIA/$chatId/")
          .child(getFileName(
              realtimeDoc[Dbkeys.from], realtimeDoc[Dbkeys.timestamp]))
          .delete();
      return true;
    } else if (realtimeDoc[Dbkeys.messageType] == MessageType.video.index) {
      Reference reference1 = FirebaseStorage.instance
          .ref("+00_CHAT_MEDIA/$chatId/")
          .child(getFileName(
              realtimeDoc[Dbkeys.from], realtimeDoc[Dbkeys.timestamp]));
      Reference reference2 = FirebaseStorage.instance
          .ref("+00_CHAT_MEDIA/$chatId/")
          .child(getFileName(realtimeDoc[Dbkeys.from],
              '${realtimeDoc[Dbkeys.timestamp]}Thumbnail'));

      await reference1.delete();
      await reference2.delete();
      return true;
    }
  } catch (err) {
    if (err.toString().contains(Dbkeys.firebaseStorageNoObjectFound1) ||
        err.toString().contains(Dbkeys.firebaseStorageNoObjectFound2) ||
        err.toString().contains(Dbkeys.firebaseStorageNoObjectFound3) ||
        err.toString().contains(Dbkeys.firebaseStorageNoObjectFound4) ||
        err.toString().contains(Dbkeys.firebaseStorageNoObjectFound5) ||
        err.toString().contains(Dbkeys.firebaseStorageNoObjectFound6) ||
        err.toString().contains(Dbkeys.firebaseStorageNoObjectFound7) ||
        err.toString().contains(Dbkeys.firebaseStorageNoObjectFound8)) {
      print(
          'all possible errors due to media already deleted but thats ok as we dont need to delete.');
      return true;
    } else {
      return false;
    }
  }
}
