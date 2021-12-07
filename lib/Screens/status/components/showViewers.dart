//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/status/components/formatStatusTime.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:flutter/material.dart';

showViewers(BuildContext context, DocumentSnapshot myStatusDoc, var filtered) {
  showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        // return your layout
        return Container(
            padding: EdgeInsets.all(12),
            height: MediaQuery.of(context).size.height / 1.1,
            child: ListView(
              physics: ScrollPhysics(),
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        getTranslated(context, 'viewedby'),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.visibility, color: fiberchatGrey),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          ' ${myStatusDoc[Dbkeys.statusVIEWERLIST].length}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: fiberchatBlack),
                        ),
                        SizedBox(
                          width: 7,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  // height: 96,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      // physics: ScrollPhysics(),
                      itemCount: myStatusDoc[Dbkeys.statusVIEWERLIST].length,
                      itemBuilder: (context, int i) {
                        List viewerslist =
                            myStatusDoc[Dbkeys.statusVIEWERLISTWITHTIME]
                                .reversed
                                .toList();

                        return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection(DbPaths.collectionusers)
                                .doc(viewerslist[i]['phone'])
                                .get(),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return ListTile(
                                  isThreeLine: false,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(5, 6, 10, 6),
                                  leading: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Container(
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.26),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    filtered!.entries.toList().indexWhere(
                                                (element) =>
                                                    element.key ==
                                                    viewerslist[i]['phone']) >
                                            0
                                        ? filtered!.entries
                                            .elementAt(filtered!.entries
                                                .toList()
                                                .indexWhere((element) =>
                                                    element.key ==
                                                    viewerslist[i]['phone']))
                                            .value
                                            .toString()
                                        : viewerslist[i]['phone'],
                                    maxLines: 1,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    getStatusTime(
                                        viewerslist[i]['time'], context),
                                    style: TextStyle(height: 1.4),
                                  ),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data.exists) {
                                return ListTile(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(5, 6, 10, 6),
                                  leading: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: snapshot.data[Dbkeys.photoUrl] ==
                                              null
                                          ? Container(
                                              width: 50.0,
                                              height: 50.0,
                                              child: Icon(Icons.person),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                shape: BoxShape.circle,
                                              ),
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: snapshot
                                                      .data[Dbkeys.photoUrl] ??
                                                  '',
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                width: 50.0,
                                                height: 50.0,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Container(
                                                width: 50.0,
                                                height: 50.0,
                                                child: Icon(Icons.person),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                width: 50.0,
                                                height: 50.0,
                                                child: Icon(Icons.person),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  title: Text(
                                    filtered!.entries.toList().indexWhere(
                                                (element) =>
                                                    element.key ==
                                                    viewerslist[i]['phone']) >
                                            0
                                        ? filtered!.entries
                                            .elementAt(filtered!.entries
                                                .toList()
                                                .indexWhere((element) =>
                                                    element.key ==
                                                    viewerslist[i]['phone']))
                                            .value
                                            .toString()
                                        : snapshot.data[Dbkeys.nickname],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    getStatusTime(
                                        viewerslist[i]['time'], context),
                                    style: TextStyle(height: 1.4),
                                  ),
                                );
                              }
                              return ListTile(
                                contentPadding:
                                    EdgeInsets.fromLTRB(5, 6, 10, 6),
                                leading: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.26),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  filtered!.entries.toList().indexWhere(
                                              (element) =>
                                                  element.key ==
                                                  viewerslist[i]['phone']) >
                                          0
                                      ? filtered!.entries
                                          .elementAt(filtered!.entries
                                              .toList()
                                              .indexWhere((element) =>
                                                  element.key ==
                                                  viewerslist[i]['phone']))
                                          .value
                                          .toString()
                                      : viewerslist[i]['phone'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  getStatusTime(
                                      viewerslist[i]['time'], context),
                                  style: TextStyle(height: 1.4),
                                ),
                              );
                            });
                      }),
                ),
              ],
            ));
      });
}
