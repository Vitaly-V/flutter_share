import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File file;

  Future<void> handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  Future<void> handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      this.file = file;
    });
  }

  Future<void> selectImage(BuildContext ctx) {
    return showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Create Post'),
            children: <Widget>[
              SimpleDialogOption(
                child: const Text('Photo with Camera'),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: const Text('Image from Gallery'),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 260,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
            ),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Upload image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              color: Colors.deepOrange,
              onPressed: () => selectImage(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUploadForm() {
    return const Text('File loaded');
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
