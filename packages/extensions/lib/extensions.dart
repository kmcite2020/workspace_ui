library extensions;

import 'package:uuid/uuid.dart';

import 'extensions.dart';

export 'package:flutter/material.dart';

String get randomID => const Uuid().v1();

extension Dynamics on dynamic {
  Widget text({double textScaleFactor = 1}) {
    return Text(
      toString(),
      textScaler: TextScaler.linear(textScaleFactor),
    );
  }
}

extension WidgetExtensions on Widget {
  Widget pad({EdgeInsets? customPad}) {
    return Padding(
      padding: customPad ?? const EdgeInsets.all(8.0),
      child: this,
    );
  }

  Center center() => Center(child: this);
}
