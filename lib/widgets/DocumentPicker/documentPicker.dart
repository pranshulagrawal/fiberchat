//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:io';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/status/components/VideoPicker/VideoPicker.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/open_settings.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HybridDocumentPicker extends StatefulWidget {
  HybridDocumentPicker(
      {Key? key,
      required this.title,
      required this.callback,
      this.profile = false})
      : super(key: key);

  final String title;
  final Function callback;
  final bool profile;

  @override
  _HybridDocumentPickerState createState() => new _HybridDocumentPickerState();
}

class _HybridDocumentPickerState extends State<HybridDocumentPicker> {
  File? _docFile;

  bool isLoading = false;
  String? error;
  @override
  void initState() {
    super.initState();
  }

  void captureFile() async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    error = null;
    try {
      var file = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (file != null) {
        _docFile = File(file.paths[0]!);

        setState(() {});
        if (_docFile!.lengthSync() / 1000000 >
            observer.maxFileSizeAllowedInMB) {
          error =
              '${getTranslated(this.context, 'maxfilesize')} ${observer.maxFileSizeAllowedInMB}MB\n\n${getTranslated(this.context, 'selectedfilesize')} ${(_docFile!.lengthSync() / 1000000).round()}MB';

          setState(() {
            _docFile = null;
          });
        } else {}
      }
    } catch (e) {
      Fiberchat.toast('Cannot Send this Document type');
      Navigator.of(this.context).pop();
    }
  }

  Widget _buildDoc() {
    if (_docFile != null) {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.file_copy_rounded, size: 100, color: Colors.yellow[800]),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: Text(basename(_docFile!.path).toString(),
                style: new TextStyle(
                  fontSize: 18.0,
                  color: DESIGN_TYPE == Themetype.whatsapp
                      ? fiberchatWhite
                      : fiberchatBlack,
                )),
          ),
        ],
      );
    } else {
      return new Text(getTranslated(this.context, 'takefile'),
          style: new TextStyle(
            fontSize: 18.0,
            color: DESIGN_TYPE == Themetype.whatsapp
                ? fiberchatWhite
                : fiberchatBlack,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Fiberchat.getNTPWrappedWidget(WillPopScope(
      child: Scaffold(
        backgroundColor:
            DESIGN_TYPE == Themetype.whatsapp ? fiberchatBlack : fiberchatWhite,
        appBar: new AppBar(
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
            title: new Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                color: DESIGN_TYPE == Themetype.whatsapp
                    ? fiberchatWhite
                    : fiberchatBlack,
              ),
            ),
            backgroundColor: DESIGN_TYPE == Themetype.whatsapp
                ? fiberchatBlack
                : fiberchatWhite,
            actions: _docFile != null
                ? <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.check,
                          color: DESIGN_TYPE == Themetype.whatsapp
                              ? fiberchatWhite
                              : fiberchatBlack,
                        ),
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          widget.callback(_docFile).then((imageUrl) {
                            Navigator.pop(context, imageUrl);
                          });
                        }),
                    SizedBox(
                      width: 8.0,
                    )
                  ]
                : []),
        body: Stack(children: [
          new Column(children: [
            new Expanded(
                child: new Center(
                    child: error != null
                        ? fileSizeErrorWidget(error!)
                        : _buildDoc())),
            _buildButtons(context)
          ]),
          Positioned(
            child: isLoading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(fiberchatBlue)),
                    ),
                    color: DESIGN_TYPE == Themetype.whatsapp
                        ? fiberchatBlack.withOpacity(0.8)
                        : fiberchatWhite.withOpacity(0.8))
                : Container(),
          )
        ]),
      ),
      onWillPop: () => Future.value(!isLoading),
    ));
  }

  Widget _buildButtons(BuildContext context) {
    return new ConstrainedBox(
        constraints: BoxConstraints.expand(height: 60.0),
        child: new Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(new Key('retake'), Icons.add, () {
                Fiberchat.checkAndRequestPermission(Platform.isIOS
                        ? Permission.mediaLibrary
                        : Permission.storage)
                    .then((res) {
                  if (res) {
                    captureFile();
                  } else {
                    Fiberchat.showRationale(
                      getTranslated(this.context, 'psac'),
                    );
                    Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => OpenSettings()));
                  }
                });
              }),
            ]));
  }

  Widget _buildActionButton(Key key, IconData icon, Function onPressed) {
    return new Expanded(
      // ignore: deprecated_member_use
      child: new RaisedButton(
          key: key,
          child: Icon(icon, size: 30.0),
          shape: new RoundedRectangleBorder(),
          color: DESIGN_TYPE == Themetype.whatsapp
              ? fiberchatDeepGreen
              : fiberchatgreen,
          textColor: fiberchatWhite,
          onPressed: onPressed as void Function()?),
    );
  }
}
