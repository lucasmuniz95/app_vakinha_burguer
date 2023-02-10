import 'package:flutter/material.dart';

class ColorsApp {
  static ColorsApp? _instance;

  ColorsApp._();

  static ColorsApp get i {
    _instance ??= ColorsApp._();
    return _instance!;
  }

  Color get primay => const Color(0xFF007D21);
  Color get secundary => const Color(0xFFF88B0C);
}

extension ColorAppExcetions on BuildContext {
  ColorsApp get colors => ColorsApp.i;
}
