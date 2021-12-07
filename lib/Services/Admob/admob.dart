//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:io';
import 'package:fiberchat/Configs/app_constants.dart';

String? getBannerAdUnitId() {
  if (Platform.isIOS) {
    return Admob_BannerAdUnitID_Ios;
  } else if (Platform.isAndroid) {
    return Admob_BannerAdUnitID_Android;
  }
  return null;
}

String? getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return Admob_InterstitialAdUnitID_Ios;
  } else if (Platform.isAndroid) {
    return Admob_InterstitialAdUnitID_Android;
  }
  return null;
}

String? getRewardBasedVideoAdUnitId() {
  if (Platform.isIOS) {
    return Admob_RewardedAdUnitID_Ios;
  } else if (Platform.isAndroid) {
    return Admob_RewardedAdUnitID_Android;
  }
  return null;
}
