//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:fiberchat/Services/Providers/seen_state.dart';
import 'package:fiberchat/Screens/chat_screen/Widget/bubble.dart';
import 'package:flutter/widgets.dart';

class SeenProvider extends StatefulWidget {
  const SeenProvider({this.timestamp, this.data, this.child});
  final SeenState? data;
  final Bubble? child;
  final String? timestamp;
  static of(BuildContext context) {
    _SeenInheritedProvider? p = context.dependOnInheritedWidgetOfExactType(
        aspect: _SeenInheritedProvider);
    return p!.data;
  }

  @override
  State<StatefulWidget> createState() => new _SeenProviderState();
}

class _SeenProviderState extends State<SeenProvider> {
  @override
  initState() {
    super.initState();
    widget.data!.addListener(didValueChange);
  }

  didValueChange() {
    if (mounted) this.setState(() {});
  }

  @override
  dispose() {
    widget.data!.removeListener(didValueChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new _SeenInheritedProvider(
      data: widget.data,
      child: widget.child ?? SizedBox(),
    );
  }
}

class _SeenInheritedProvider extends InheritedWidget {
  _SeenInheritedProvider({required this.data, required this.child})
      : _dataValue = data.value,
        super(child: child);
  final data;
  final Widget child;
  final _dataValue;
  @override
  bool updateShouldNotify(_SeenInheritedProvider oldWidget) {
    return _dataValue != oldWidget._dataValue;
  }
}
