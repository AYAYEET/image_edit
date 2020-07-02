import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shake/shake.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_launcher_icons/android.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/ios.dart';
import 'package:flutter_launcher_icons/main.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path/path.dart' as Path;


void main(){
  runApp(new MaterialApp(
    title: "Photo Editor",
    home: LandingScreen(),
  ));
}

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {

  File imageFile;
  final picker = ImagePicker();
  imageLib.Image _image;
  String fileName;
  List<Filter> filters = presetFiltersList;

  _openGallary(BuildContext context) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    this.setState(() {
      imageFile = File(pickedFile.path);
      fileName = Path.basename(imageFile.path);
      _image = imageLib.decodeImage(imageFile.readAsBytesSync());
    });
    Navigator.of(context).pop();


  }
  _openCamera(BuildContext context) async{
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    this.setState(() {
      imageFile = File(pickedFile.path);
      fileName = Path.basename(imageFile.path);
      _image = imageLib.decodeImage(imageFile.readAsBytesSync());
    });
    Navigator.of(context).pop();
  }
  //no mistakes grr
  
  @override
  void initState() {
  super.initState();
  ShakeDetector detector = ShakeDetector.autoStart(onPhoneShake: () {
  // Do stuff on phone shake
    _showChoiceDialog(context);
    Vibration.vibrate();

  });
  // To close: detector.stopListening();
  // ShakeDetector.waitForStart() waits for user to call detector.startListening();
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(context: context,builder: (BuildContext context){
      return AlertDialog(
        title: Text("How will you import an image?"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text("Gallery"),
                onTap: (){
                  _openGallary(context);
                },
              ),
              Padding(padding: EdgeInsets.all(6.0)),
              GestureDetector(
                child: Text("Camera"),
                onTap: (){
                  _openCamera(context);
                },
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _isImageView(){
    if (imageFile == null) {
      return Text("No Image Selected");
    } else {
      return Image.file(imageFile,width: 400,height: 400);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Editor"),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _isImageView(),
              RaisedButton(onPressed: (){
                _showChoiceDialog(context);
              },child: Text("Select Image or Shake to Select"),),
              RaisedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(
                  builder: (context)=> PhotoFilterSelector(
                    image: _image,
                    filters: filters,
                    filename: fileName,
                    loader: Center(child: CircularProgressIndicator()), title: Text("Filter"),
                  ),
                ));
              },child: Text("Edit!"),)
            ],
          ),
        )
      )
    );
  }
}
