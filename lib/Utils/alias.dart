//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:io';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';

class AliasForm extends StatefulWidget {
  final Map<String, dynamic> user;
  final DataModel? model;
  AliasForm(this.user, this.model);

  @override
  _AliasFormState createState() => _AliasFormState();
}

class _AliasFormState extends State<AliasForm> {
  TextEditingController? _alias;

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _alias =
        new TextEditingController(text: Fiberchat.getNickname(widget.user));
  }

  Future getImage(File image) {
    setState(() {
      _imageFile = image;
    });
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    String? name = Fiberchat.getNickname(widget.user);
    return AlertDialog(
      actions: <Widget>[
        // ignore: deprecated_member_use
        FlatButton(
            child: Text(
              getTranslated(context, 'removealias'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: widget.user[Dbkeys.aliasName] != null ||
                    widget.user[Dbkeys.aliasAvatar] != null
                ? () {
                    widget.model!.removeAlias(widget.user[Dbkeys.phone]);
                    Navigator.pop(context);
                  }
                : null),
        // ignore: deprecated_member_use
        FlatButton(
            child: Text(
              getTranslated(context, 'setalias'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              if (_alias!.text.isNotEmpty) {
                if (_alias!.text != name || _imageFile != null) {
                  widget.model!.setAlias(
                      _alias!.text, _imageFile, widget.user[Dbkeys.phone]);
                }
                Navigator.pop(context);
              }
            })
      ],
      contentPadding: EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 120,
              height: 120,
              child: Stack(children: [
                Center(
                    child: Fiberchat.avatar(widget.user,
                        image: _imageFile, radius: 50)),
              ])),
          TextFormField(
            autovalidateMode: AutovalidateMode.always,
            controller: _alias,
            decoration: InputDecoration(
              hintText: getTranslated(context, 'aliasname'),
            ),
            validator: (val) {
              if (val!.trim().isEmpty) return getTranslated(context, 'nameem');
              return null;
            },
          )
        ]),
      ),
    );
  }
}
