//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/permissions.dart';
import 'package:fiberchat/Utils/open_settings.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:fiberchat/widgets/AudioRecorder/playButton.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

///
typedef _Fn = void Function();

/// Example app.
class AudioRecord extends StatefulWidget {
  AudioRecord({
    Key? key,
    required this.title,
    required this.callback,
  }) : super(key: key);

  final String title;
  final Function callback;

  @override
  _AudioRecordState createState() => _AudioRecordState();
}

class _AudioRecordState extends State<AudioRecord> {
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  final String _mPath = 'Recording${DateTime.now().millisecondsSinceEpoch}.aac';

  @override
  void initState() {
    _mPlayer!.openAudioSession().then((value) {
      setStateIfMounted(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setStateIfMounted(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void dispose() {
    _mPlayer!.closeAudioSession();
    _mPlayer = null;

    _mRecorder!.closeAudioSession();
    _mRecorder = null;
    stopWatchStream();
    super.dispose();
  }

  bool issinit = true;
  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permissions.getMicrophonePermission();

      if (status != PermissionStatus.granted) {
        Fiberchat.showRationale(getTranslated(this.context, 'pm'));
        Navigator.push(context,
            new MaterialPageRoute(builder: (context) => OpenSettings()));
      } else {
        await _mRecorder!.openAudioSession();
        _mRecorderIsInited = true;
      }
    }
  }

  // ----------------------  Here is the code for recording and playback -------
  Timer? timerr;
  void record() async {
    setStateIfMounted(() {
      recordertime = '00:00:00';
      hoursStr = '00';
      secondsStr = '00';
      hoursStr = '00';
      minutesStr = '00';
    });
    _mRecorder!
        .startRecorder(
      codec: Codec.aacMP4,
      toFile: _mPath,
      //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
    )
        .then((value) {
      setStateIfMounted(() {
        status = 'recording';
        issinit = false;
      });
      startTimerNow();
    });
  }

  File? recordedfile;
  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) async {
      setStateIfMounted(() {
        _mplaybackReady = true;
        status = 'recorded';
      });
      setStateIfMounted(() {
        recordedfile = File(value!);
        recordertime = "$hoursStr:$minutesStr:$secondsStr";
      });

      setStateIfMounted(() {
        streamController!.done;
        streamController!.close();
        timerSubscription!.cancel();
      });
    });
  }

  void play() async {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder!.isStopped &&
        _mPlayer!.isStopped);
    _mPlayer!
        .startPlayer(
            fromURI: _mPath,
            //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
            whenFinished: () {
              setStateIfMounted(() {});
            })
        .then((value) {
      setStateIfMounted(() {
        // status = 'play';
      });
    });
  }

  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {
      setStateIfMounted(() {});
    });
  }

// ----------------------------- UI --------------------------------------------

  _Fn? getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return null;
    }
    return _mRecorder!.isStopped ? record : stopRecorder;
  }

  _Fn? getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder!.isStopped) {
      return null;
    }
    return _mPlayer!.isStopped ? play : stopPlayer;
  }

  String status = 'notrecording';

  Future<bool> onWillPopNEw() {
    return Future.value(issinit == true
        ? true
        : status == 'recorded'
            ? _mPlayer!.isPlaying
                ? false
                : true
            : false);
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Center(
        child: isLoading == true
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(fiberchatLightGreen))
            : Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 12,
                  ),
                  _mPlayer!.isPlaying
                      ? SizedBox(
                          height: 223,
                        )
                      : Container(
                          margin: const EdgeInsets.all(3),
                          padding: const EdgeInsets.all(13),
                          // height: 160,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Column(children: [
                            // Text(
                            //   _mRecorder!.isRecording
                            //       ? getTranslated(this.context, 'recording')
                            //       : recordertime == '00:00:00'
                            //           ? ''
                            //           : getTranslated(
                            //               this.context, 'recorderstopped'),
                            //   style: TextStyle(fontSize: 16, color: Colors.white),
                            // ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              _mRecorder!.isRecording
                                  ? "$hoursStr:$minutesStr:$secondsStr"
                                  : recordertime,
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.w700,
                                color: DESIGN_TYPE == Themetype.whatsapp
                                    ? fiberchatWhite
                                    : fiberchatBlack,
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            PlayButton(
                              pauseIcon: Icon(
                                Icons.stop,
                                color: Colors.red,
                                size: 60,
                              ),
                              playIcon:
                                  Icon(Icons.mic, color: Colors.red, size: 70),
                              onPressed: getRecorderFn(),
                            ),
                            // RawMaterialButton(
                            //   onPressed: getRecorderFn(),
                            //   elevation: 2.0,
                            //   fillColor:
                            //       _mRecorder!.isRecording ? Colors.red : Colors.white,
                            //   child: Icon(
                            //     _mRecorder!.isRecording
                            //         ? Icons.stop
                            //         : Icons.mic_rounded,
                            //     size: 75.0,
                            //     color: _mRecorder!.isRecording
                            //         ? Colors.white
                            //         : Colors.red,
                            //   ),
                            //   padding: EdgeInsets.all(15.0),
                            //   shape: CircleBorder(),
                            // ),
                          ]),
                        ),
                  status == 'recorded'
                      ? Container(
                          margin: const EdgeInsets.all(3),
                          padding: const EdgeInsets.all(13),
                          // height: 160,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Column(children: [
                            Text(
                              _mPlayer!.isPlaying
                                  ? getTranslated(
                                      this.context, 'playingrecording')
                                  : '',
                              style: TextStyle(
                                fontSize: 16,
                                color: DESIGN_TYPE == Themetype.whatsapp
                                    ? fiberchatWhite
                                    : fiberchatBlack,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            RawMaterialButton(
                              onPressed: getPlaybackFn(),
                              elevation: 2.0,
                              fillColor: _mPlayer!.isPlaying
                                  ? Colors.white
                                  : fiberchatLightGreen,
                              child: Icon(
                                _mPlayer!.isPlaying
                                    ? Icons.stop
                                    : Icons.play_arrow,
                                size: 45.0,
                                color: _mPlayer!.isPlaying
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              padding: EdgeInsets.all(15.0),
                              shape: CircleBorder(),
                            ),
                          ]),
                        )
                      : SizedBox(
                          height: 20,
                        ),
                  SizedBox(
                    height: 20,
                  ),
                  status == 'recorded'
                      ? _mPlayer!.isPlaying
                          ? SizedBox()
                          // ignore: deprecated_member_use
                          : RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(color: fiberchatLightGreen)),
                              elevation: 0.2,
                              color: fiberchatLightGreen,
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              onPressed: () {
                                final observer = Provider.of<Observer>(
                                    this.context,
                                    listen: false);
                                if (recordedfile!.lengthSync() / 1000000 >
                                    observer.maxFileSizeAllowedInMB) {
                                  Fiberchat.toast(
                                      '${getTranslated(this.context, 'maxfilesize')} ${observer.maxFileSizeAllowedInMB}MB\n\n${getTranslated(this.context, 'selectedfilesize')} ${(recordedfile!.lengthSync() / 1000000).round()}MB');
                                } else {
                                  setStateIfMounted(() {
                                    isLoading = true;
                                  });
                                  Fiberchat.toast(getTranslated(
                                      this.context, 'sendingrecord'));
                                  widget
                                      .callback(recordedfile)
                                      .then((recordedUrl) {
                                    Navigator.pop(context, recordedUrl);
                                  });
                                }
                              },
                              child: Text(
                                getTranslated(this.context, 'sendrecord'),
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ))
                      : SizedBox()
                ],
              ),
      );
    }

    return WillPopScope(
        onWillPop: onWillPopNEw,
        child: Scaffold(
          backgroundColor: DESIGN_TYPE == Themetype.whatsapp
              ? fiberchatDeepGreen
              : fiberchatWhite,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.keyboard_arrow_left,
                size: 30,
                color: DESIGN_TYPE == Themetype.whatsapp
                    ? fiberchatWhite
                    : fiberchatBlack,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: DESIGN_TYPE == Themetype.whatsapp
                ? fiberchatDeepGreen
                : fiberchatWhite,
            title: Text(
              widget.title,
              style: TextStyle(
                color: DESIGN_TYPE == Themetype.whatsapp
                    ? fiberchatWhite
                    : fiberchatBlack,
              ),
            ),
          ),
          body: makeBody(),
        ));
  }

  //------ Timer Widget Section Below:
  bool flag = true;
  Stream<int>? timerStream;
  // ignore: cancel_subscriptions
  StreamSubscription<int>? timerSubscription;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';
  String recordertime = '00:00:00';
  // ignore: close_sinks
  StreamController<int>? streamController;
  Stream<int> stopWatchStream() {
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
      setStateIfMounted(() {
        hoursStr =
            ((newTick / (60 * 60)) % 60).floor().toString().padLeft(2, '0');
        minutesStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
        secondsStr = (newTick % 60).floor().toString().padLeft(2, '0');
      });
      print(secondsStr);
    });
  }

  //------
}
