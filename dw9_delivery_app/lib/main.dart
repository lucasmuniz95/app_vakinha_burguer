import 'package:dw9_delivery_app/app/core/ui/config/env/env.dart';
import 'package:flutter/cupertino.dart';

import 'app/dw9_delivery_app.dart';

Future<void> main() async {
  await Env.i.load();
  runApp(const Dw9DeliveryApp());
}
