import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file/local.dart';

import 'package:final_project/providers/program_provider.dart';
import 'package:final_project/recorder/feature_buttons_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
  bool isLoading = false;

  // int account_number = 0;

  void initState() {
    // TODO: implement initState
    listenOTP();
    //
    // getData();
    super.initState();
  }

  Future<void> getPhone() async {
    var userData = await FirebaseFirestore.instance
        .collection('phone')
        .doc('JjSw6iyXSTAkVPb2nsOP')
        .get();
    phone = userData['phone'];
    print(phone);
  }

  @override
  void dispose() {
    // TODO: implement dispose
//   cancel();
    SmsAutoFill().unregisterListener();
    super.dispose();
//
  }

  String appSignature = '';

  void getData() async {
    //   await listenOTP();
    // print("3");

    await signatureOTP();
    print("2");
    await getPhone();
    print("1");

    await _submitPhoneNumber(phone);
    print("4");
  }

  TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var p = Provider.of<ProgramProvider>(context, listen: true);
    p.otpController = _otpController;

    TextStyle theme1 = TextStyle(
        fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold);
    TextStyle theme2 = TextStyle(
        fontSize: 22,
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic);

    double sizeX = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black45,
        title: Text('Biometric Authentication App', style: theme1),
        //  backgroundColor: Colors.white10,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          width: sizeX,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Text(
                          'OTP Code ',
                          style: theme2,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 120,
                          child: PinFieldAutoFill(
                              textInputAction: TextInputAction.done,
                              // focusNode: AlwaysDisabledFocusNode(),
                              controller: _otpController,
                              // keyboardType: TextInputType.number,
                              decoration: UnderlineDecoration(
                                textStyle: TextStyle(
                                    fontSize: 22, color: Colors.black),
                                colorBuilder: FixedColorBuilder(
                                  Colors.black.withOpacity(0.3),
                                ),
                              ),
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
                        ),
                      ],
                    ),
                    if (p.verificationSend)
                      Column(
                        children: [
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            'Recorder',
                            style: theme2,
                          ),
                          FeatureButtonsView(
                            onUploadComplete: Provider.of<ProgramProvider>(
                                    context,
                                    listen: true)
                                .onUploadComplete,
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            'Take A Picture ',
                            style: theme2,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                            ),
                            iconSize: 60,
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
                                ? Text(
                                    'There is no picture yet',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 15),
                                  )
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
              if (p.verificationSend)
                isLoading
                    ? Column(
                        children: [
                          Text("Uploading..."),
                          SizedBox(
                            height: 15,
                          ),
                          CircularProgressIndicator(),
                        ],
                      )
                    :
                    // ignore: deprecated_member_use
                    SizedBox(
                        width: sizeX,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.black87),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ))),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'Verify',
                              style: TextStyle(fontSize: 25),
                              // style: theme1,
                            ),
                          ),
                          // color: Colors.black,
                          onPressed: (p.file != null && p.filePath != null)
                              ? () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await Provider.of<ProgramProvider>(context,
                                          listen: false)
                                      .uploadData(Provider.of<ProgramProvider>(
                                              context,
                                              listen: false)
                                          .file);
                                  await Provider.of<ProgramProvider>(context,
                                          listen: false)
                                      .onFileUploadButtonPressed(context);
                                  Provider.of<ProgramProvider>(context,
                                          listen: false)
                                      .uploadPhoneData(phone);
                                  Provider.of<ProgramProvider>(context,
                                          listen: false)
                                      .increaseIndex();
                                  Provider.of<ProgramProvider>(context,
                                          listen: false)
                                      .file = null;
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              : null,
                        ),
                      ),
            ],
          ),
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

  Future<void> listenOTP() async {
    await SmsAutoFill().listenForCode;
    print('3');
  }

  signatureOTP() async {
    SmsAutoFill().getAppSignature.then((signature) {
      setState(() {
        appSignature = signature;
      });
    });

    print('ttttttttttttttttttttttt $appSignature');
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
