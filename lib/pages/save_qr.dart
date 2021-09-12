import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_scan/data_service/saved_qr_data.dart';

import 'package:qr_scan/data_service/db.dart';
import 'dart:core';

import 'package:flutter/widgets.dart';

import 'package:url_launcher/url_launcher.dart';

class SaveQr extends StatefulWidget {
  //const SaveQr({Key? key}) : super(key: key);

  @override
  _SaveQrState createState() => _SaveQrState();
}

class _SaveQrState extends State<SaveQr> {
  late List<SavedQRData> savedQR;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshQR();
  }

  @override
  void dispose() {
    QRDatabase.instance.close();

    super.dispose();
  }

  Future refreshQR() async {
    setState(() => isLoading = true);

    this.savedQR = await QRDatabase.instance.readAllNotes();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final TextStyle textStyle = TextStyle(
      fontWeight: FontWeight.bold,
    );
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[800],
          title: Text('Saved QRCode'),
          centerTitle: true,
          elevation: 0,
        ),
        body: isLoading
            ? CircularProgressIndicator()
            : savedQR.isEmpty
                ? Text(
                    'No QR saved',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  )
                : ListView.builder(
                    itemCount: savedQR.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 1, horizontal: 4),
                        child: Card(
                          child: ListTile(
                              onTap: () =>
                                  launch(savedQR[index].link.toString()),
                              title: Text(
                                savedQR[index].title,
                                style: textStyle,
                              ),
                              subtitle: Text(savedQR[index].link),
                              trailing: Container(
                                width: 100,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            QRDatabase.instance.delete(index);
                                          });
                                        },
                                        icon: Icon(Icons.delete),
                                      ),
                                      /*IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.edit),
                              ),*/
                                    ]),
                              ),
                              leading: CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/barcode-scanner.png'),
                                backgroundColor: Colors.white,
                              )),
                        ),
                      );
                    }));
  }
}
