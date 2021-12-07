//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:fiberchat/Configs/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

void notificationViwer(BuildContext context, String? desc, String? title,
    String? imageurl, String? timeString) {
  var h = MediaQuery.of(context).size.height;
  var w = MediaQuery.of(context).size.width;
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return new Container(
          margin: EdgeInsets.only(top: 0),
          height: h > w ? h / 1.3 : w / 1.2,
          color: Colors.transparent,
          child: new Container(
              decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0))),
              child: SingleChildScrollView(
                  child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeString!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            fontSize: 13.9,
                            color: Colors.black87.withOpacity(0.6),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: fiberchatGrey,
                          ),
                          alignment: Alignment.centerRight,
                        ),
                      ],
                    ),
                    // Divider(),
                    SizedBox(height: 10),
                    imageurl == null
                        ? SizedBox(
                            height: 0,
                          )
                        : Align(
                            alignment: Alignment.center,
                            child: Image.network(
                              imageurl,
                              height: (w * 0.654) - 36,
                              width: w,
                              fit: BoxFit.cover,
                            ),
                          ),
                    SizedBox(height: 30),
                    SelectableText(
                      title ?? 'This is title',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 19,
                          color: fiberchatBlack,
                          fontWeight: FontWeight.w800),
                    ),

                    Divider(),
                    SizedBox(height: 10),
                    SelectableLinkify(
                      style: TextStyle(fontSize: 15, height: 1.4),
                      text: desc ?? "This is description",
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                    ),
                  ],
                ),
              ))),
        );
      });
}
