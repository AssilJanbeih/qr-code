import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:flutter/services.dart';

class Scanning extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanningState();
}

class _ScanningState extends State<Scanning> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final Map<String, int> data = {};

  late String barcodeType;
  late String qrResult;
  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      primary: Colors.grey[600],
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text('Scan QRCode'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 3, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => Result: result)),
                    ElevatedButton(
                        style: buttonStyle,
                        child: Text('Show Result'),
                        onPressed: () async {
                          barcodeType = '${describeEnum(result!.format)}';
                          qrResult = '${result!.code}';
                          await Navigator.pushNamed(context, '/result',
                              arguments: {
                                'type': barcodeType,
                                'qrLink': qrResult
                              });
                        })
                  else
                    Text('Scan your QRCode'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            style: buttonStyle,
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                String stat = '${snapshot.data}';
                                if (stat == 'true') {
                                  return Icon(
                                    Icons.flash_on,
                                    size: 2,
                                  );
                                } else {
                                  return Icon(Icons.flash_off);
                                }
                              },
                            ),
                          )),
                      Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            style: buttonStyle,
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Icon(Icons.flip_camera_ios);
                                } else {
                                  return Text('loading');
                                }
                              },
                            )),
                      )
                    ],
                  ),
                  /* Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.toggleFlash();
                            setState(() {});
                          },
                          style: buttonStyle,
                          child: FutureBuilder(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              String stat = '${snapshot.data}';
                              if (stat == 'true') {
                                return Icon(
                                  Icons.flash_on,
                                  size: 2,
                                );
                              } else {
                                return Icon(Icons.flash_off);
                              }
                            },
                          ),
                        )),
                    Container(
                      margin: EdgeInsets.all(8),
                      child: ElevatedButton(
                          onPressed: () async {
                            await controller?.flipCamera();
                            setState(() {});
                          },
                          style: buttonStyle,
                          child: FutureBuilder(
                            future: controller?.getCameraInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return Icon(Icons.flip_camera_ios);
                              } else {
                                return Text('loading');
                              }
                            },
                          )),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      if (result != null)
                        Column(
                          children: <Widget>[
                            InkWell(
                                hoverColor: Colors.red,
                                child: new Text(
                                    //'Barcode Type: ${describeEnum(result!.format)} /nData:
                                    '${result!.code}',
                                    maxLines: 5,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )),
                                onTap: () => launch('${result!.code}')),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/save',
                                    arguments: {'url': '${result!.code}'});
                              },
                              icon: Icon(
                                Icons.save,
                              ),
                              style: buttonStyle,
                              label: Text('Save QR Link'),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Scan a code',
                          textAlign: TextAlign.center,
                        ),*/
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.grey,
          borderRadius: 10,
          borderLength: 35,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
