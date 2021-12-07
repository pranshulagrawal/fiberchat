//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:flutter/foundation.dart';

class CurrentChatPeer with ChangeNotifier {
  String? peerid = '';
  String? groupChatId = '';

  setpeer({
    String? newpeerid,
    String? newgroupChatId,
  }) {
    peerid = newpeerid ?? peerid;
    groupChatId = newgroupChatId ?? groupChatId;
    notifyListeners();
  }
}
