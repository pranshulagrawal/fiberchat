//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageData {
  int? lastSeen;
  QuerySnapshot snapshot;
  MessageData({required this.snapshot, required this.lastSeen});
}
