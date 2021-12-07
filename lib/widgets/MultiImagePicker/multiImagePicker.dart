//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:io';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/status/components/VideoPicker/VideoPicker.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/open_settings.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MultiImagePicker extends StatefulWidget {
  MultiImagePicker(
      {Key? key,
      required this.title,
      required this.callback,
      this.writeMessage,
      this.profile = false})
      : super(key: key);

  final String title;
  final Function callback;
  final bool profile;
  final Future<void> Function(String url, int timestamp)? writeMessage;

  @override
  _MultiImagePickerState createState() => new _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  ImagePicker picker = ImagePicker();
  bool isLoading = false;
  String? error;
  String mode = 'single';
  List<XFile> selectedImages = [];
  int currentUploadingIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  bool checkTotalNoOfFilesIfExceeded() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    if (selectedImages.length > observer.maxNoOfFilesInMultiSharing) {
      return true;
    } else {
      return false;
    }
  }

  bool checkIfAnyFileSizeExceeded() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    int index = selectedImages.indexWhere((file) =>
        File(file.path).lengthSync() / 1000000 >
        observer.maxFileSizeAllowedInMB);
    if (index >= 0) {
      return true;
    } else {
      return false;
    }
  }

  void captureSingleImage(ImageSource captureMode) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    error = null;
    try {
      XFile? pickedImage = await (picker.pickImage(source: captureMode));
      if (pickedImage != null) {
        if (File(pickedImage.path).lengthSync() / 1000000 >
            observer.maxFileSizeAllowedInMB) {
          error =
              '${getTranslated(this.context, 'maxfilesize')} ${observer.maxFileSizeAllowedInMB}MB\n\n${getTranslated(this.context, 'selectedfilesize')} ${(File(pickedImage.path).lengthSync() / 1000000).round()}MB';
          print('errrror');
          setState(() {
            mode = "single";
            selectedImages = [];
          });
        } else {
          setState(() {
            mode = "single";
            selectedImages.add(pickedImage);
          });
        }
      }
    } catch (e) {}
  }

  void captureMultiPageImage(bool isAddOnly) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    error = null;
    try {
      if (isAddOnly) {
        //--- Is adding to already selected images list.
        List<XFile>? images = await picker.pickMultiImage();
        if (images!.length > 0) {
          images.forEach((image) {
            if (!selectedImages.contains(image)) {
              selectedImages.add(image);
            }
          });

          mode = 'multi';
          error = null;
          setState(() {});
        }
      } else {
        //--- Is adding to empty selected image list.
        List<XFile>? images = await picker.pickMultiImage();
        if (images!.length > 1) {
          selectedImages = images;
          mode = 'multi';
          error = null;
          setState(() {});
        } else if (images.length == 1) {
          if (File(images[0].path).lengthSync() / 1000000 >
              observer.maxFileSizeAllowedInMB) {
            error =
                '${getTranslated(this.context, 'maxfilesize')} ${observer.maxFileSizeAllowedInMB}MB\n\n${getTranslated(this.context, 'selectedfilesize')} ${(File(images[0].path).lengthSync() / 1000000).round()}MB';

            setState(() {
              mode = "single";
            });
          } else {
            setState(() {
              mode = "single";
              selectedImages = images;
            });
          }
        }
      }
    } catch (e) {}
  }

  Widget _buildSingleImage({File? file}) {
    if (file != null) {
      return new Image.file(file);
    } else {
      return new Text(getTranslated(context, 'takeimage'),
          style: new TextStyle(
            fontSize: 18.0,
            color: DESIGN_TYPE == Themetype.whatsapp
                ? fiberchatWhite
                : fiberchatBlack,
          ));
    }
  }

  Widget _buildMultiImageLoading() {
    return Container(
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${currentUploadingIndex + 1}/${selectedImages.length}',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 26,
                color: fiberchatLightGreen),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            getTranslated(this.context, 'sending'),
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: DESIGN_TYPE == Themetype.whatsapp
                    ? fiberchatWhite
                    : fiberchatBlack),
          )
        ],
      )),
      color: DESIGN_TYPE == Themetype.whatsapp
          ? fiberchatBlack.withOpacity(0.8)
          : fiberchatWhite.withOpacity(0.8),
    );
  }

  Widget _buildMultiImage() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    if (selectedImages.length > 0) {
      return GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7),
          itemCount: selectedImages.length,
          itemBuilder: (BuildContext context, i) {
            return Container(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Container(
                    height: (MediaQuery.of(context).size.width / 2) - 20,
                    width: (MediaQuery.of(context).size.width / 2) - 20,
                    color: fiberchatGrey.withOpacity(0.4),
                  ),
                  new Image.file(
                    File(selectedImages[i].path),
                    fit: BoxFit.cover,
                    height: (MediaQuery.of(context).size.width / 2) - 20,
                    width: (MediaQuery.of(context).size.width / 2) - 20,
                  ),
                  File(selectedImages[i].path).lengthSync() / 1000000 >
                          observer.maxFileSizeAllowedInMB
                      ? Container(
                          height: (MediaQuery.of(context).size.width / 2) - 20,
                          width: (MediaQuery.of(context).size.width / 2) - 20,
                          color: Colors.white70,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsetsDirectional.all(10),
                              child: Text(
                                '${getTranslated(this.context, 'maxfilesize')} ${observer.maxFileSizeAllowedInMB}MB\n${getTranslated(this.context, 'selectedfilesize')} ${(File(selectedImages[i].path).lengthSync() / 1000000).round()}MB',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 6,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                  Positioned(
                    right: 7,
                    top: 7,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedImages.removeAt(i);
                          if (selectedImages.length <= 1) {
                            mode = "single";
                          }
                        });
                      },
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: new BoxDecoration(
                          color: Colors.black.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: new Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              // decoration: BoxDecoration(
              //     color: Colors.amber, borderRadius: BorderRadius.circular(15)),
            );
          });
    } else {
      return new Text(getTranslated(context, 'takeimage'),
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
    final observer = Provider.of<Observer>(this.context, listen: false);
    return Fiberchat.getNTPWrappedWidget(WillPopScope(
      child: Scaffold(
        backgroundColor:
            DESIGN_TYPE == Themetype.whatsapp ? fiberchatBlack : fiberchatWhite,
        appBar: new AppBar(
            leading: IconButton(
              onPressed: () {
                if (!isLoading) {
                  Navigator.of(context).pop();
                }
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
              selectedImages.length > 0
                  ? '${selectedImages.length} ${getTranslated(this.context, 'selected')}'
                  : widget.title,
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
            actions: selectedImages.length != 0 && !isLoading
                ? <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.check,
                          color: DESIGN_TYPE == Themetype.whatsapp
                              ? fiberchatWhite
                              : fiberchatBlack,
                        ),
                        onPressed: checkTotalNoOfFilesIfExceeded() == false
                            ? (checkIfAnyFileSizeExceeded() == false
                                ? () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    uploadEach(0);
                                  }
                                : () {
                                    final observer = Provider.of<Observer>(
                                        this.context,
                                        listen: false);
                                    Fiberchat.toast(getTranslated(
                                            context, 'filesizeexceeded') +
                                        ': ${observer.maxFileSizeAllowedInMB}MB');
                                  })
                            : () {
                                Fiberchat.toast(
                                    '${getTranslated(this.context, 'maxnooffiles')}: ${observer.maxNoOfFilesInMultiSharing}');
                              }),
                    SizedBox(
                      width: 8.0,
                    )
                  ]
                : []),
        body: Stack(children: [
          new Column(children: [
            mode == 'single'
                ? new Expanded(
                    child: new Center(
                        child: error != null
                            ? fileSizeErrorWidget(error!)
                            : _buildSingleImage(
                                file: selectedImages.length > 0
                                    ? File(selectedImages[0].path)
                                    : null)))
                : new Expanded(child: new Center(child: _buildMultiImage())),
            _buildButtons()
          ]),
          Positioned(
            child: isLoading
                ? mode == "multi" && selectedImages.length > 1
                    ? _buildMultiImageLoading()
                    : Container(
                        child: Center(
                          child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(fiberchatBlue)),
                        ),
                        color: DESIGN_TYPE == Themetype.whatsapp
                            ? fiberchatBlack.withOpacity(0.8)
                            : fiberchatWhite.withOpacity(0.8),
                      )
                : Container(),
          )
        ]),
      ),
      onWillPop: () => Future.value(!isLoading),
    ));
  }

  uploadEach(int index) async {
    if (index > selectedImages.length) {
      Navigator.of(context).pop();
    } else {
      int messagetime = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        currentUploadingIndex = index;
      });
      await widget
          .callback(File(selectedImages[index].path),
              timestamp: messagetime, totalFiles: selectedImages.length)
          .then((imageUrl) async {
        await widget.writeMessage!(imageUrl, messagetime).then((value) {
          if (selectedImages.last == selectedImages[index]) {
            Navigator.of(context).pop();
          } else {
            uploadEach(currentUploadingIndex + 1);
          }
        });
      });
    }
  }

  Widget _buildButtons() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    return new ConstrainedBox(
        constraints: BoxConstraints.expand(height: 80.0),
        child: new Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(
                  new Key('multi'),
                  Icons.photo_library,
                  checkTotalNoOfFilesIfExceeded() == false
                      ? () {
                          Fiberchat.checkAndRequestPermission(Permission.photos)
                              .then((res) {
                            if (res == true) {
                              captureMultiPageImage(false);
                            } else if (res == false) {
                              Fiberchat.showRationale(
                                  getTranslated(context, 'pgi'));
                              Navigator.pushReplacement(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => OpenSettings()));
                            } else {}
                          });
                        }
                      : () {
                          Fiberchat.toast(
                              '${getTranslated(this.context, 'maxnooffiles')}: ${observer.maxNoOfFilesInMultiSharing}');
                        }),
              selectedImages.length < 1
                  ? SizedBox()
                  : _buildActionButton(
                      new Key('multi'),
                      Icons.add,
                      checkTotalNoOfFilesIfExceeded() == false
                          ? () {
                              Fiberchat.checkAndRequestPermission(
                                      Permission.photos)
                                  .then((res) {
                                if (res == true) {
                                  captureMultiPageImage(true);
                                } else if (res == false) {
                                  Fiberchat.showRationale(
                                      getTranslated(context, 'pgi'));
                                  Navigator.pushReplacement(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              OpenSettings()));
                                } else {}
                              });
                            }
                          : () {
                              Fiberchat.toast(
                                  '${getTranslated(this.context, 'maxnooffiles')}: ${observer.maxNoOfFilesInMultiSharing}');
                            }),
              _buildActionButton(
                  new Key('upload'),
                  Icons.photo_camera,
                  checkTotalNoOfFilesIfExceeded() == false
                      ? () {
                          Fiberchat.checkAndRequestPermission(Permission.camera)
                              .then((res) {
                            if (res == true) {
                              captureSingleImage(ImageSource.camera);
                            } else if (res == false) {
                              getTranslated(context, 'pci');
                              Navigator.pushReplacement(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => OpenSettings()));
                            } else {}
                          });
                        }
                      : () {
                          Fiberchat.toast(
                              '${getTranslated(this.context, 'maxnooffiles')}: ${observer.maxNoOfFilesInMultiSharing}');
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
