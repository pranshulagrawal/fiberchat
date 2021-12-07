//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:flutter/foundation.dart';

class DownloadInfoprovider with ChangeNotifier {
  int totalsize = 0;
  double downloadedpercentage = 0.0;
  calculatedownloaded(
    double newdownloadedpercentage,
    int newtotal,
  ) {
    totalsize = newtotal;
    downloadedpercentage = newdownloadedpercentage;
    notifyListeners();
  }
}
