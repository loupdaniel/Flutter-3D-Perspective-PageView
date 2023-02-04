import 'package:flutter/foundation.dart';

class PageViewHolder extends ChangeNotifier {
  double? value;

  PageViewHolder({this.value});

  void setValue(newValue) {
    value = newValue;
    notifyListeners();
  }
}
