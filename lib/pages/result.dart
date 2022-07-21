import 'package:flutter/material.dart';

import 'package:qr_scan/data_service/db.dart';
import 'package:flutter/services.dart';
import 'package:qr_scan/data_service/saved_qr_data.dart';
import 'package:url_launcher/url_launcher.dart';

class Result extends StatefulWidget {
  //////////////////////////// Initiating the variables ///////////////////////////////////

  final String type; //type of barcode
  final String qrLink; // link from the qr
  final SavedQRData?
      qrsave; //a variable from the class SavedQRData in which we save the qr
  const Result(
      {Key? key, this.qrsave, required this.type, required this.qrLink})
      : super(key: key);

  //const Result({Key? key}) : super(key: key);
  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  final myController =
      TextEditingController(); //to save the text written in text field

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  //////////////////////////// Creating the PopUp Message and save the input field ///////////////////////////////////
  createSavePopMessage(BuildContext context) {
    final routeData =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    final newQR = routeData['qrLink'];
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(title: Text('Save Link'), children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                  controller: myController,
                  maxLength: 20, // set maximum 20 characters
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    labelText: 'Enter Link Name',
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                  onPressed: () async {
                    ///Save the variables for a new instance SavedQR & add it to DB
                    final note = SavedQRData(
                      title: myController.text,
                      link: newQR.toString(),
                    );
                    await QRDatabase.instance.create(note);
                    Navigator.pop(context, true);
                  },
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[600],
                  )),
            )
          ]);
        });
  }

  //////////////////////////// Creating the result Page ///////////////////////////////////
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      primary: Colors.grey[600],
    );

    final routeData =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    final newTyoe = routeData['type'];
    final newQR = routeData['qrLink'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text('QRCode Result'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/barcode-scanner.png',
                  alignment: Alignment.topCenter,
                  scale: 4,
                ),
                SizedBox(
                  height: 50,
                ),
                Text('Barcode type: ' + newTyoe.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(
                  height: 20,
                ),
                // InkWell(
                //   hoverColor: Colors.red,
                //   child: new Text('Link: ' + newQR.toString(),
                //       maxLines: 5,
                //       style: TextStyle(
                //         fontWeight: FontWeight.bold,
                //       )),
                //   onTap: () => launch(newQR.toString()),
                // ),
                ElevatedButton.icon(
                  onPressed: () {
                    launch(newQR.toString());
                  },
                  icon: Icon(
                    Icons.language,
                  ),
                  style: buttonStyle,
                  label: Text('Go To QRLink'),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    createSavePopMessage(context);
                  },
                  icon: Icon(
                    Icons.save,
                  ),
                  style: buttonStyle,
                  label: Text('Save QR Link'),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/save_qr');
                  },
                  icon: Icon(
                    Icons.qr_code,
                  ),
                  style: buttonStyle,
                  label: Text('  Saved QRs '),
                ),
              ],
            )),
      ),
    );
  }
}
