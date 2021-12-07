//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:fiberchat/Screens/chat_screen/utils/downloadMedia.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class PreviewVideo extends StatefulWidget {
  final bool isdownloadallowed;
  final String filename;
  final String videourl;
  final String? id;
  final double? aspectratio;

  PreviewVideo(
      {required this.id,
      required this.videourl,
      required this.isdownloadallowed,
      required this.filename,
      this.aspectratio});
  @override
  _PreviewVideoState createState() => _PreviewVideoState();
}

class _PreviewVideoState extends State<PreviewVideo> {
  late VideoPlayerController _videoPlayerController1;
  late VideoPlayerController _videoPlayerController2;
  late ChewieController _chewieController;
  String videoUrl = '';
  bool isShowvideo = false;
  double? thisaspectratio = 1.14;

  @override
  void initState() {
    setState(() {
      thisaspectratio = widget.aspectratio;
    });
    super.initState();

    _videoPlayerController1 = VideoPlayerController.network(
        // 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'
        widget.videourl);
    _videoPlayerController2 = VideoPlayerController.network(widget.videourl
        // 'https://www.radiantmediaplayer.com/media/bbb-360p.mp4'
        );
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      allowFullScreen: true,
      showControlsOnInitialize: false,
      aspectRatio: thisaspectratio,
      autoPlay: true,
      looping: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _videoPlayerController2.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  GlobalKey<State> _keyLoader =
      new GlobalKey<State>(debugLabel: 'qqqdseqeqsseaadqeqe');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.2,
        elevation: 0.4,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          widget.isdownloadallowed == true
              ? IconButton(
                  icon: Icon(Icons.file_download),
                  onPressed: Platform.isIOS || Platform.isAndroid
                      ? () {
                          launch(widget.videourl);
                        }
                      : () async {
                          await downloadFile(
                            context: context,
                            fileName: 'Recording_' + widget.filename,
                            isonlyview: false,
                            keyloader: _keyLoader,
                            uri: widget.videourl,
                          );
                        })
              : SizedBox()
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
          child: Padding(
        padding: EdgeInsets.only(bottom: Platform.isIOS ? 30 : 10),
        child: Chewie(
          controller: _chewieController,
        ),
      )),
    );
  }
}
