import 'package:flutter/material.dart';
import 'package:qr_scan/pages/home.dart';
import 'package:flutter/services.dart';
import 'package:qr_scan/pages/save_qr.dart';
import 'package:qr_scan/pages/scan.dart';
import 'package:qr_scan/pages/result.dart';

import 'package:flutter/widgets.dart';

void main() async {
  //////////////////////////// Called for the database connection ///////////////////////////////////
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MaterialApp(
    //////////////////////////// Setting the routes for the pages ///////////////////////////////////
    initialRoute: '/home',
    routes: {
      '/scan': (context) => Scanning(),
      '/home': (context) => Home(),
      '/save_qr': (context) => SaveQr(),
      '/result': (context) => Result(
            qrLink: '',
            type: '',
          ),
    },
  ));
}
