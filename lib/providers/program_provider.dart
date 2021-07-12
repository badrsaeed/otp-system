import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProgramProvider with ChangeNotifier {
  bool isPlaying;
  bool isUploading;
  bool isRecorded;
  bool isRecording;
  bool isPhotoTaken = false;
  File file;
  List<Reference> references;
  bool isLoading = false;

  var otpController;
  bool verificationSend = false;

  List<int> numbers = [0, 1, 2, 3, 4, 5, 6,7,8,9];
  int index = 0;

  AudioPlayer audioPlayer;
  String filePath;

  FlutterAudioRecorder audioRecorder;

  void ableScreen() {
    if (otpController.text.length > 0) {
      verificationSend = true;
      notifyListeners();
    } else {
      verificationSend = false;
      notifyListeners();
    }
  }

  Future<void> onFileUploadButtonPressed(BuildContext ctx) async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    isUploading = true;

    try {
      await firebaseStorage
          .ref('Client${numbers[index]} Data')
          .child(filePath.substring(filePath.lastIndexOf('/'), filePath.length))
          .putFile(File(filePath));
      onUploadComplete();
    } catch (error) {
      print('Error occured while uplaoding to Firebase ${error.toString()}');
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('Error occured while uplaoding'),
        ),
      );
    } finally {
      isUploading = false;
    }
    notifyListeners();
  }

  void onRecordAgainButtonPressed() {
    isRecorded = false;
    notifyListeners();
  }

  Future<void> onRecordButtonPressed(BuildContext ctx) async {
    if (isRecording) {
      audioRecorder.stop();
      isRecording = false;
      isRecorded = true;
      notifyListeners();
    } else {
      isRecorded = false;
      isRecording = true;

      await startRecording(ctx);
      notifyListeners();
    }
  }

  void onPlayButtonPressed() {
    if (!isPlaying) {
      isPlaying = true;
      notifyListeners();
      audioPlayer.play(filePath, isLocal: true);
      audioPlayer.onPlayerCompletion.listen((duration) {
        isPlaying = false;
        notifyListeners();
      });
    } else {
      audioPlayer.pause();
      isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> startRecording(BuildContext ctx) async {
    final bool hasRecordingPermission =
        await FlutterAudioRecorder.hasPermissions;
    if (hasRecordingPermission) {
      Directory directory = await getApplicationDocumentsDirectory();
      String filepath = directory.path +
          '/' +
          DateTime.now().millisecondsSinceEpoch.toString() +
          '.aac';
      audioRecorder =
          FlutterAudioRecorder(filepath, audioFormat: AudioFormat.AAC);
      await audioRecorder.initialized;
      audioRecorder.start();
      filePath = filepath;
      notifyListeners();
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Center(
          child: Text('Please enable recording permission'),
        ),
      ));
      notifyListeners();
    }
  }

  Future<void> onUploadComplete() async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    ListResult listResult = await firebaseStorage
        .ref()
        .child('Client${numbers[index]} Data')
        .list();

    references = listResult.items;
    notifyListeners();
    print(references);
  }

  Future pickercamera() async {
    final image = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    if (image != null) {
      file = File(image.path);
      print("Done!");
      notifyListeners();
    } else {
      print("no image selected");
      notifyListeners();
    }
    isPhotoTaken = true;
    notifyListeners();
  }

  void resetImage() {
    isPhotoTaken = false;
    file = null;
    pickercamera();
    notifyListeners();
  }

  Future<void> uploadData(File image) async {
    //try to upload the image
    try {
      print("1");
      //make a reference have two child the first one for file name, second for image name
      final ref = FirebaseStorage.instance
          .ref()
          .child('Client${numbers[index]} Data')
          .child('${numbers[index]}.jpg');
      //upload the image into the server
      print("2");
      await ref.putFile(image);
      print("3");
      print("Image uploaded successfully");
      notifyListeners();
    } catch (e) {
      print(e);
      notifyListeners();
    }
  }

  void uploadPhoneData(String phone) async {
    //try to upload the image
    try {
      print("1");
      //make a reference have two child the first one for file name, second for image name
      final ref = FirebaseStorage.instance
          .ref()
          .child('Client${numbers[index]} Data')
          .child('phone number.txt');
      //upload the image into the server
      print("2");
      await ref.putString(phone);
      print("3");
      print("phone uploaded successfully");
      notifyListeners();
    } catch (e) {
      print(e);
      notifyListeners();
    }
  }

 void increaseIndex() {
    if (index == numbers.length) {
      index = 0;
    }
    index++;
    isLoading = false;
    notifyListeners();
  }
  void showAlertDialog() {
      isLoading = true;
      notifyListeners();
  }
  }
