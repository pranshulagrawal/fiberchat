//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:fiberchat/Services/Providers/seen_provider.dart';
import 'package:flutter/material.dart';

class Message {
  Message(Widget child,
      {required this.timestamp,
      required this.from,
      required this.onTap,
      required this.onDoubleTap,
      required this.onDismiss,
      required this.onLongPress,
      this.saved = false})
      : child = wrapMessage(
            child: child as SeenProvider,
            onDismiss: onDismiss,
            onDoubleTap: onDoubleTap,
            onTap: onTap,
            onLongPress: onLongPress,
            saved: saved);

  final String? from;
  final Widget child;
  final int? timestamp;
  final VoidCallback? onTap, onDoubleTap, onDismiss, onLongPress;
  final bool saved;
  static Widget wrapMessage(
      {required SeenProvider child,
      required onDismiss,
      required onDoubleTap,
      required onTap,
      required onLongPress,
      required bool saved}) {
    return Dismissible(
        direction: DismissDirection.startToEnd,
        key: Key(child.timestamp!),
        confirmDismiss: (direction) {
          onDismiss();
          return Future.value(false);
        },
        child: child.child!.isMe
            ? GestureDetector(
                child: child,
                onTap: onTap,
                onDoubleTap: onDoubleTap,
                onLongPress: onLongPress,
              )
            : GestureDetector(
                child: child,
                onDoubleTap: onDoubleTap,
                onTap: onTap,
                onLongPress: onLongPress,
              ));
  }
}
