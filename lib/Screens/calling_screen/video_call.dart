//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/homepage/homepage.dart';
import 'package:fiberchat/Services/Providers/call_history_provider.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Models/call.dart';
import 'package:fiberchat/Utils/call_utilities.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart' as audioPlayers;
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

class VideoCall extends StatefulWidget {
  final String? channelName;
  final String? currentuseruid;

  final Call call;
  final ClientRole? role;
  const VideoCall(
      {Key? key,
      required this.call,
      required this.currentuseruid,
      this.channelName,
      this.role})
      : super(key: key);

  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  late RtcEngine _engine;
  bool isspeaker = true;
  bool isalreadyendedcall = false;
  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    streamController!.done;
    streamController!.close();
    timerSubscription!.cancel();

    super.dispose();
  }

  double screenHeight = 0.0;
  double screenWidth = 0.0;
  Stream<DocumentSnapshot>? stream;
  @override
  void initState() {
    super.initState();
    // initialize agora sdk

    initialize();
    stream = FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.currentuseruid == widget.call.callerId
            ? widget.call.receiverId
            : widget.call.callerId)
        .collection(DbPaths.collectioncallhistory)
        .doc(widget.call.timeepoch.toString())
        .snapshots();
    startTimerNow();
  }

  String? mp3Uri;
  late audioPlayers.AudioPlayer player;
  AudioCache audioCache = AudioCache();
  Future<Null> _playCallingTone() async {
    player = await audioCache.loop('sounds/callingtone.mp3', volume: 3);

    setState(() {});
  }

  void _stopCallingSound() async {
    player.stop();
  }

  Future<void> initialize() async {
    if (Agora_APP_IDD.isEmpty) {
      setState(() {
        _infoStrings.add(
          'Agora_APP_IDD missing, please provide your Agora_APP_IDD in app_constant.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();

    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(height: 1920, width: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(Agora_TOKEN, widget.channelName!, null, 0);
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(Agora_APP_IDD);
    await _engine.enableVideo();
    await _engine.setEnableSpeakerphone(isspeaker);
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      if (widget.call.callerId == widget.currentuseruid) {
        _playCallingTone();
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.callerId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'TYPE': 'OUTGOING',
          'ISVIDEOCALL': widget.call.isvideocall,
          'PEER': widget.call.receiverId,
          'TIME': widget.call.timeepoch,
          'DP': widget.call.receiverPic,
          'ISMUTED': false,
          'TARGET': widget.call.receiverId,
          'ISJOINEDEVER': false,
          'STATUS': 'calling',
          'STARTED': null,
          'ENDED': null,
          'CALLERNAME': widget.call.callerName,
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.receiverId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'TYPE': 'INCOMING',
          'ISVIDEOCALL': widget.call.isvideocall,
          'PEER': widget.call.callerId,
          'TIME': widget.call.timeepoch,
          'DP': widget.call.callerPic,
          'ISMUTED': false,
          'TARGET': widget.call.receiverId,
          'ISJOINEDEVER': true,
          'STATUS': 'missedcall',
          'STARTED': null,
          'ENDED': null,
          'CALLERNAME': widget.call.callerName,
        }, SetOptions(merge: true));
      }
      Wakelock.enable();
      flutterLocalNotificationsPlugin.cancelAll();
    }, leaveChannel: (stats) {
      _stopCallingSound();
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
      if (isalreadyendedcall == false) {
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.callerId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STATUS': 'ended',
          'ENDED': DateTime.now(),
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.receiverId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STATUS': 'ended',
          'ENDED': DateTime.now(),
        }, SetOptions(merge: true));
        //----------
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.receiverId)
            .collection('recent')
            .doc('callended')
            .set({
          'id': widget.call.receiverId,
          'ENDED': DateTime.now().millisecondsSinceEpoch,
          'CALLERNAME': widget.call.callerName,
        }, SetOptions(merge: true));
      }
      Wakelock.disable();
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
      if (widget.currentuseruid == widget.call.callerId) {
        _stopCallingSound();
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.callerId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STARTED': DateTime.now(),
          'STATUS': 'pickedup',
          'ISJOINEDEVER': true,
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.receiverId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STARTED': DateTime.now(),
          'STATUS': 'pickedup',
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.callerId)
            .set({
          Dbkeys.videoCallMade: FieldValue.increment(1),
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.receiverId)
            .set({
          Dbkeys.videoCallRecieved: FieldValue.increment(1),
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.collectiondashboard)
            .doc(DbPaths.docchatdata)
            .set({
          Dbkeys.videocallsmade: FieldValue.increment(1),
        }, SetOptions(merge: true));
      }
      Wakelock.enable();
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
      _stopCallingSound();
      if (isalreadyendedcall == false) {
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.callerId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STATUS': 'ended',
          'ENDED': DateTime.now(),
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.receiverId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STATUS': 'ended',
          'ENDED': DateTime.now(),
        }, SetOptions(merge: true));
        //----------
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.receiverId)
            .collection('recent')
            .doc('callended')
            .set({
          'id': widget.call.receiverId,
          'ENDED': DateTime.now().millisecondsSinceEpoch,
          'CALLERNAME': widget.call.callerName,
        }, SetOptions(merge: true));
      }
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  void _onToggleSpeaker() {
    setState(() {
      isspeaker = !isspeaker;
    });
    _engine.setEnableSpeakerphone(isspeaker);
  }

  Widget _toolbar(
    bool isshowspeaker,
    String? status,
  ) {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          isshowspeaker == true
              ? SizedBox(
                  width: 65.67,
                  child: RawMaterialButton(
                    onPressed: _onToggleSpeaker,
                    child: Icon(
                      isspeaker
                          ? Icons.volume_mute_rounded
                          : Icons.volume_off_sharp,
                      color: isspeaker ? Colors.white : Colors.blueAccent,
                      size: 22.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: isspeaker ? Colors.blueAccent : Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ))
              : SizedBox(height: 0, width: 65.67),
          status != 'ended' && status != 'rejected'
              ? SizedBox(
                  width: 65.67,
                  child: RawMaterialButton(
                    onPressed: _onToggleMute,
                    child: Icon(
                      muted ? Icons.mic_off : Icons.mic,
                      color: muted ? Colors.white : Colors.blueAccent,
                      size: 22.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: muted ? Colors.blueAccent : Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ))
              : SizedBox(height: 42, width: 65.67),
          SizedBox(
            width: 65.67,
            child: RawMaterialButton(
              onPressed: () async {
                setState(() {
                  isalreadyendedcall =
                      status == 'ended' || status == 'rejected' ? true : false;
                });

                _onCallEnd(context);
              },
              child: Icon(
                status == 'ended' || status == 'rejected'
                    ? Icons.close
                    : Icons.call,
                color: Colors.white,
                size: 35.0,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: status == 'ended' || status == 'rejected'
                  ? Colors.black
                  : Colors.redAccent,
              padding: const EdgeInsets.all(15.0),
            ),
          ),
          status == 'ended' || status == 'rejected'
              ? SizedBox(
                  width: 65.67,
                )
              : SizedBox(
                  width: 65.67,
                  child: RawMaterialButton(
                    onPressed: _onSwitchCamera,
                    child: Icon(
                      Icons.switch_camera,
                      color: Colors.blueAccent,
                      size: 20.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ),
                ),
          status == 'pickedup'
              ? SizedBox(
                  width: 65.67,
                  child: RawMaterialButton(
                    onPressed: () {
                      isuserenlarged = !isuserenlarged;
                      setState(() {});
                    },
                    child: Icon(
                      Icons.open_in_full_outlined,
                      color: Colors.black87,
                      size: 15.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ),
                )
              : SizedBox(
                  width: 65.67,
                )
        ],
      ),
    );
  }

  bool isuserenlarged = false;
  onetooneview(double h, double w, bool iscallended, bool userenlarged) {
    final views = _getRenderViews();

    if (iscallended == true) {
      return Container(
        color:
            DESIGN_TYPE == Themetype.whatsapp ? fiberchatgreen : fiberchatWhite,
        height: h,
        width: w,
        child: Center(
            child: Icon(
          Icons.videocam_off,
          size: 120,
          color: DESIGN_TYPE == Themetype.whatsapp
              ? fiberchatWhite.withOpacity(0.38)
              : fiberchatBlack.withOpacity(0.38),
        )),
      );
    } else if (userenlarged == false) {
      switch (views.length) {
        case 1:
          return Container(
              child: Column(
            children: <Widget>[_videoView(views[0])],
          ));

        case 2:
          return Container(
              child: Column(
            children: <Widget>[_videoView(views[1])],
          ));

        default:
          return Container(
            child: Center(child: Text('Max 2. participants allowed')),
          );
      }
    } else if (userenlarged == true) {
      switch (views.length) {
        case 1:
          return Container(
              child: Column(
            children: <Widget>[_videoView(views[0])],
          ));

        case 2:
          return Container(
              child: Column(
            children: <Widget>[_videoView(views[0])],
          ));

        default:
          return Container(
            child: Center(child: Text('Max 2. participants allowed')),
          );
      }
    }
  }

  Widget _panel({BuildContext? context, bool? ispeermuted, String? status}) {
    if (status == 'rejected') {
      _stopCallingSound();
    }
    return Container(
      // padding: const EdgeInsets.symmetric(vertical: 28),
      alignment: Alignment.bottomCenter,
      child: Container(
        // height: 73,
        margin: const EdgeInsets.symmetric(vertical: 138),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            status == 'pickedup' && ispeermuted == true
                ? Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getTranslated(context!, 'muted'),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87),
                        )),
                  )
                : SizedBox(
                    height: 0,
                    width: 0,
                  ),
            status == 'calling' || status == 'ringing' || status == 'missedcall'
                ? Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getTranslated(
                              context!,
                              widget.call.receiverId == widget.currentuseruid
                                  ? 'connecting'
                                  : 'calling'),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87),
                        )),
                  )
                : SizedBox(
                    height: 0,
                    width: 0,
                  ),
            status == 'nonetwork'
                ? Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getTranslated(context!, 'connecting'),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black87),
                        )),
                  )
                : SizedBox(
                    height: 0,
                    width: 0,
                  ),
            status == 'ended'
                ? Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: DESIGN_TYPE == Themetype.whatsapp
                              ? fiberchatWhite
                              : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getTranslated(context!, 'callended'),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: DESIGN_TYPE == Themetype.whatsapp
                                  ? Colors.red
                                  : fiberchatWhite),
                        )),
                  )
                : SizedBox(
                    height: 0,
                    width: 0,
                  ),
            status == 'rejected'
                ? Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getTranslated(context!, 'callrejected'),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.red[500]),
                        )),
                  )
                : SizedBox(
                    height: 0,
                    width: 0,
                  ),
          ],
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) async {
    final FirestoreDataProviderCALLHISTORY firestoreDataProviderCALLHISTORY =
        Provider.of<FirestoreDataProviderCALLHISTORY>(context, listen: false);
    _stopCallingSound();
    await CallUtils.callMethods.endCall(call: widget.call);
    DateTime now = DateTime.now();
    if (isalreadyendedcall == false) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.call.callerId)
          .collection(DbPaths.collectioncallhistory)
          .doc(widget.call.timeepoch.toString())
          .set({'STATUS': 'ended', 'ENDED': now}, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.call.receiverId)
          .collection(DbPaths.collectioncallhistory)
          .doc(widget.call.timeepoch.toString())
          .set({'STATUS': 'ended', 'ENDED': now}, SetOptions(merge: true));
      //----------
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.call.receiverId)
          .collection('recent')
          .doc('callended')
          .set({
        'id': widget.call.receiverId,
        'ENDED': DateTime.now().millisecondsSinceEpoch,
        'CALLERNAME': widget.call.callerName,
      }, SetOptions(merge: true));
    }
    Wakelock.disable();

    firestoreDataProviderCALLHISTORY.fetchNextData(
        'CALLHISTORY',
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.currentuseruid)
            .collection(DbPaths.collectioncallhistory)
            .orderBy('TIME', descending: true)
            .limit(14),
        true);
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _stopCallingSound();
    _engine.muteLocalAudioStream(muted);
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.currentuseruid)
        .collection(DbPaths.collectioncallhistory)
        .doc(widget.call.timeepoch.toString())
        .set({'ISMUTED': muted}, SetOptions(merge: true));
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  Future<bool> onWillPopNEw() {
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: onWillPopNEw,
      child: Scaffold(
          // appBar: AppBar(
          //   title: Text('Flutter Video Call Demo'),
          //   centerTitle: true,
          // ),
          backgroundColor: Colors.black,
          body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: stream as Stream<DocumentSnapshot<Map<String, dynamic>>>?,
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.data() == null || snapshot.data == null) {
                  return Center(
                    child: Stack(
                      children: <Widget>[
                        // _viewRows(),
                        onetooneview(
                            screenHeight, screenWidth, false, isuserenlarged),

                        _toolbar(false, 'calling'),
                        _panel(
                            status: 'calling',
                            ispeermuted: false,
                            context: context),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Stack(
                      children: <Widget>[
                        // _viewRows(),
                        onetooneview(
                            screenHeight,
                            screenWidth,
                            snapshot.data!.data()!["STATUS"] == 'ended'
                                ? true
                                : false,
                            isuserenlarged),

                        _toolbar(
                            snapshot.data!.data()!["STATUS"] == 'pickedup'
                                ? true
                                : false,
                            snapshot.data!.data()!["STATUS"]),

                        snapshot.data!.data()!["STATUS"] == 'pickedup' &&
                                _getRenderViews().length > 1
                            ? Positioned(
                                bottom: screenWidth > screenHeight ? 40 : 120,
                                right: screenWidth > screenHeight ? 20 : 10,
                                child: Container(
                                  height: screenWidth > screenHeight
                                      ? screenWidth / 4.7
                                      : screenHeight / 4.7,
                                  width: screenWidth > screenHeight
                                      ? (screenWidth / 4.7) / 1.7
                                      : (screenHeight / 4.7) / 1.7,
                                  child: _getRenderViews()[
                                      isuserenlarged == true ? 1 : 0],
                                ),
                              )
                            : SizedBox(),
                        _panel(
                            context: context,
                            status: snapshot.data!.data()!["STATUS"],
                            ispeermuted: snapshot.data!.data()!["ISMUTED"]),
                      ],
                    ),
                  );
                }
              } else if (!snapshot.hasData) {
                return Center(
                  child: Stack(
                    children: <Widget>[
                      // _viewRows(),
                      onetooneview(
                          screenHeight, screenWidth, false, isuserenlarged),

                      _toolbar(false, 'nonetwork'),
                      _panel(
                          context: context,
                          status: 'nonetwork',
                          ispeermuted: false),
                    ],
                  ),
                );
              }
              return Center(
                child: Stack(
                  children: <Widget>[
                    // _viewRows(),
                    onetooneview(
                        screenHeight, screenWidth, false, isuserenlarged),

                    _toolbar(false, 'calling'),
                    _panel(
                        context: context,
                        status: 'calling',
                        ispeermuted: false),
                  ],
                ),
              );
            },
          )),
    );
  }

  //------ Timer Widget Section Below:
  bool flag = true;
  Stream<int>? timerStream;
  // ignore: cancel_subscriptions
  StreamSubscription<int>? timerSubscription;
  // ignore: close_sinks
  StreamController<int>? streamController;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';

  Stream<int> stopWatchStream() {
    // ignore: close_sinks

    Timer? timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer!.cancel();
        timer = null;
        counter = 0;
        streamController!.close();
      }
    }

    void tick(_) {
      counter++;
      streamController!.add(counter);
      if (!flag) {
        stopTimer();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController!.stream;
  }

  startTimerNow() {
    timerStream = stopWatchStream();
    timerSubscription = timerStream!.listen((int newTick) {
      setState(() {
        hoursStr =
            ((newTick / (60 * 60)) % 60).floor().toString().padLeft(2, '0');
        minutesStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
        secondsStr = (newTick % 60).floor().toString().padLeft(2, '0');
      });
      flutterLocalNotificationsPlugin.cancelAll();
    });
  }

  //------
}
