import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file/local.dart';
import 'package:final_project/providers/program_provider.dart';
import 'package:final_project/recorder/feature_buttons_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

class Home extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  Home({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String phone = "";

  // File _file;
  // List<Reference> references;
  // bool _isLoading = false;
  int account_number = 0;

  void initState() {
    // TODO: implement initState
    super.initState();
    //
    getData();
  }

  Future<void> getPhone() async {
    var userData = await FirebaseFirestore.instance
        .collection('phone')
        .doc('JjSw6iyXSTAkVPb2nsOP')
        .get();
    phone = userData['phone'];
    print(phone);
  }

  void getData() async {
    await getPhone();
    print("1");
    listenOTP();
    await signatureOTP();
    print("2");
    await _submitPhoneNumber(phone);
    print("3");
  }

  TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var p = Provider.of<ProgramProvider>(context, listen: true);
    p.otpController = _otpController;
    var clientData = FirebaseFirestore.instance.collection('clients_data');
    TextStyle theme1 = TextStyle(
        fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold);
    TextStyle theme2 = TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic);

    double sizeX = MediaQuery.of(context).size.width;
    double sizeY = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Azhar Multi-Media OTP System', style: theme1),
        backgroundColor: Colors.white10,
      ),
      body: Container(
        width: sizeX,
        child: ListView(
          children: [
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            'Verification Code ',
                            style: theme2,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                            width: 150,
                            child: PinFieldAutoFill(
                                textInputAction: TextInputAction.none,
                                controller: _otpController,
                                keyboardType: TextInputType.number,

                                // decoration: // UnderlineDecoration, BoxLooseDecoration or BoxTightDecoration see https://github.com/TinoGuo/pin_input_text_field for more info,
                                currentCode: _otpController.text,
                                // prefill with a code
                                onCodeSubmitted: (val) {},
                                //code submitted callback
                                onCodeChanged: (val) {
                                  _otpController.text = val;
                                  p.ableScreen();
                                },
                                //code changed callback
                                codeLength: 6 //code length, default 6
                                ),
                            // child: TextField(
                            //   readOnly: true,
                            //   decoration: InputDecoration(
                            //     enabledBorder: OutlineInputBorder(
                            //       borderRadius:
                            //           BorderRadius.all(Radius.circular(15)),
                            //       borderSide: BorderSide(color: Colors.grey),
                            //     ),
                            //     //enabled: false,
                            //     border: InputBorder.none,
                            //     focusedBorder: OutlineInputBorder(
                            //       borderRadius:
                            //           BorderRadius.all(Radius.circular(15)),
                            //       borderSide: BorderSide(color: Colors.grey),
                            //     ),
                            //   ),
                            // ),
                          ),
                        ],
                      ),
                      if (p.verificationSend)
                        Column(
                          children: [
                            SizedBox(
                              height: 25,
                            ),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Recorder',
                                    style: theme2,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            FeatureButtonsView(
                              onUploadComplete: Provider.of<ProgramProvider>(
                                      context,
                                      listen: true)
                                  .onUploadComplete,
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Take A Picture ',
                                  style: theme2,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            IconButton(
                              icon: Icon(Icons.camera_alt),
                              iconSize: 80,
                              onPressed: () {
                                Provider.of<ProgramProvider>(context,
                                        listen: false)
                                    .pickercamera();
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              child: Provider.of<ProgramProvider>(context,
                                              listen: true)
                                          .file ==
                                      null
                                  ? Text('There Is No Pic')
                                  : Image.file(
                                      Provider.of<ProgramProvider>(context,
                                              listen: true)
                                          .file,
                                      scale: 6,
                                    ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // if (Provider.of<ProgramProvider>(context, listen: true)
                //     .isPhotoTaken)
                //   ElevatedButton(
                //     onPressed: () {
                //       Provider.of<ProgramProvider>(context, listen: false)
                //           .resetImage();
                //     },
                //     child: Text("Take another picture"),
                //   ),
                if (p.verificationSend)
                  ElevatedButton(
                    onPressed: () async {
                      final _userData = await FirebaseFirestore.instance
                          .collection('clients_data')
                          .doc('2')
                          .get();

                      print(
                          "phone: ${_userData['phone']}\nname : ${_userData['name']}\naccount Number : ${_userData['account_number']}");
                    },
                    child: Text("clint Data"),
                  ),
                if (p.verificationSend)
                  // ignore: deprecated_member_use
                  RaisedButton(
                    child: Text(
                      'Verify',
                      style: theme1,
                    ),
                    color: Colors.black,
                    onPressed: () async {
                      await Provider.of<ProgramProvider>(context, listen: false)
                          .uploadData(Provider.of<ProgramProvider>(context,
                                  listen: false)
                              .file);
                      await Provider.of<ProgramProvider>(context, listen: false)
                          .onFileUploadButtonPressed(context);
                      Provider.of<ProgramProvider>(context, listen: false)
                          .uploadPhoneData(phone);
                      await Provider.of<ProgramProvider>(context, listen: false)
                          .increaseIndex();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<List> _submitPhoneNumber(String phoneNumber) async {
    /// NOTE: Either append your phone number country code or add in the code itself
    AuthCredential _phoneAuthCredential =
        AuthCredential(providerId: '', signInMethod: '');
    String _verifectionId = '';
    print(phoneNumber);

    /// The below functions are the callbacks, separated so as to make code more readable
    void verificationCompleted(AuthCredential phoneAuthCredential) async {
      print('verificationCompleted');
      _phoneAuthCredential = phoneAuthCredential;
      print(phoneAuthCredential);
      await FirebaseAuth.instance
          .signInWithCredential(_phoneAuthCredential)
          .then((UserCredential authRes) async {
        print(authRes.user.toString());
      });
    }

    void verificationFailed(Exception error) {
      print(error.toString() + "  ossosososoos");
    }

    void codeSent(dynamic verificationId, dynamic code) {
      _verifectionId = verificationId;
      print('تم ارسال رمز التحقق');
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      print('codeAutoRetrievalTimeout');
      //Navigator.push(context, MaterialPageRoute(builder: (context)=>VerfectionScreen(verificationId)));
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      /// Make sure to prefix with your country code
      phoneNumber: phoneNumber,

      /// `seconds` didn't work. The underlying implementation code only reads in `milliseconds`
      timeout: Duration(milliseconds: 1000),

      /// If the SIM (with phoneNumber) is in the current device this function is called.
      /// This function gives `AuthCredential`. Moreover `login` function can be called from this callback
      verificationCompleted: verificationCompleted,

      /// Called when the verification is failed
      verificationFailed: verificationFailed,

      /// This is called after the OTP is sent. Gives a `verificationId` and `code`
      codeSent: codeSent,

      /// After automatic code retrival `tmeout` this function is called
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
    return [
      _phoneAuthCredential,
      _verifectionId
    ]; // All the callbacks are above
  }

  void listenOTP() async {
    await SmsAutoFill().listenForCode;
  }

  Future<void> signatureOTP() async {
    final res = await SmsAutoFill().getAppSignature;
    print(res);
  }

// Future<void> _onUploadComplete() async {
//   FirebaseStorage firebaseStorage = FirebaseStorage.instance;
//   ListResult listResult =
//   await firebaseStorage.ref().child('upload-voice-firebase').list();
//   setState(() {
//     references = listResult.items;
//     print(references);
//   });
// }
//
// Future pickercamera() async {
//   final image = await ImagePicker().getImage(
//     source: ImageSource.camera,
//   );
//   if (image != null) {
//     setState(() {
//       _file = File(image.path);
//     });
//     print("Done!");
//   } else {
//     print("no image selected");
//   }
// }
//
// void _uploadData(File image) async {
//   //try to upload the image
//   try {
//     print("1");
//     //make a reference have two child the first one for file name, second for image name
//     final ref =
//     FirebaseStorage.instance.ref().child('clint_images').child('1.jpg');
//     //upload the image into the server
//     print("2");
//     await ref.putFile(image);
//     print("3");
//     setState(() {
//       _isLoading = false;
//       print("Image uploaded successfully");
//     });
//   }
//   //if an error occurred try to know the reason of error and handle it
//   catch (e) {
//     print(e);
//   }
// }
}
