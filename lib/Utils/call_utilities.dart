//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:math';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:fiberchat/Screens/calling_screen/audio_call.dart';
import 'package:fiberchat/Screens/calling_screen/video_call.dart';
import 'package:flutter/material.dart';
import 'package:fiberchat/Models/call.dart';
import 'package:fiberchat/Models/call_methods.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial(
      {String? fromUID,
      String? fromFullname,
      String? fromDp,
      String? toFullname,
      String? toDp,
      String? toUID,
      bool? isvideocall,
      required String? currentuseruid,
      context}) async {
    int timeepoch = DateTime.now().millisecondsSinceEpoch;
    Call call = Call(
        timeepoch: timeepoch,
        callerId: fromUID,
        callerName: fromFullname,
        callerPic: fromDp,
        receiverId: toUID,
        receiverName: toFullname,
        receiverPic: toDp,
        channelId: Random().nextInt(1000).toString(),
        isvideocall: isvideocall);
    ClientRole _role = ClientRole.Broadcaster;
    bool callMade = await callMethods.makeCall(
        call: call, isvideocall: isvideocall, timeepoch: timeepoch);

    call.hasDialled = true;
    if (isvideocall == false) {
      if (callMade) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioCall(
              currentuseruid: currentuseruid,
              call: call,
              channelName: call.channelId,
              role: _role,
            ),
          ),
        );
      }
    } else {
      if (callMade) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCall(
              currentuseruid: currentuseruid,
              call: call,
              channelName: call.channelId,
              role: _role,
            ),
          ),
        );
      }
    }
  }
}
