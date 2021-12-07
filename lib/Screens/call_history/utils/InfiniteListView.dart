//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Services/Providers/call_history_provider.dart';
import 'package:flutter/material.dart';

class InfiniteListView extends StatefulWidget {
  final FirestoreDataProviderCALLHISTORY? firestoreDataProviderCALLHISTORY;
  final String? datatype;
  final Widget? list;
  final Query? refdata;
  final bool? isreverse;
  final EdgeInsets? padding;
  final String? parentid;
  const InfiniteListView({
    this.firestoreDataProviderCALLHISTORY,
    this.datatype,
    this.isreverse,
    this.padding,
    this.parentid,
    this.list,
    this.refdata,
    Key? key,
  }) : super(key: key);

  @override
  _InfiniteListViewState createState() => _InfiniteListViewState();
}

class _InfiniteListViewState extends State<InfiniteListView> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (scrollController.offset >=
            scrollController.position.maxScrollExtent / 2 &&
        !scrollController.position.outOfRange) {
      if (widget.datatype == 'CALLHISTORY') {
        if (widget.firestoreDataProviderCALLHISTORY!.hasNext) {
          widget.firestoreDataProviderCALLHISTORY!
              .fetchNextData(widget.datatype, widget.refdata, false);
        }
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        reverse: widget.isreverse == null || widget.isreverse == false
            ? false
            : true,
        controller: scrollController,
        padding: widget.padding == null ? EdgeInsets.all(0) : widget.padding,
        children: widget.datatype == 'CALLHISTORY'
            ?
            //-----PRODUCTS
            [
                Container(child: widget.list),
                (widget.firestoreDataProviderCALLHISTORY!.hasNext == true)
                    ? Center(
                        child: GestureDetector(
                          onTap: () {
                            widget.firestoreDataProviderCALLHISTORY!
                                .fetchNextData(
                                    widget.datatype, widget.refdata, false);
                          },
                          child: Container(
                            height: widget.firestoreDataProviderCALLHISTORY!
                                        .recievedDocs.length <
                                    1
                                ? 205
                                : 100,
                            width: widget.firestoreDataProviderCALLHISTORY!
                                        .recievedDocs.length <
                                    1
                                ? 205
                                : 100,
                            child: Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      fiberchatLightGreen)),
                            ),
                          ),
                        ),
                      )
                    : widget.firestoreDataProviderCALLHISTORY!.recievedDocs
                                .length <
                            1
                        ? Align(
                            alignment: Alignment.center,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                    28,
                                    MediaQuery.of(context).size.height / 8.7,
                                    28,
                                    10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        padding: EdgeInsets.all(22),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          // borderRadius: BorderRadius.all(
                                          //   Radius.circular(20),
                                          // ),
                                        ),
                                        height: 100,
                                        width: 100,
                                        child: Icon(Icons.call,
                                            size: 60, color: Colors.grey)),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Text(
                                      getTranslated(context, 'nocalls'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      getTranslated(context, 'allav'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13.9,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 0,
                          ),
              ]
            : [],
      );
}
