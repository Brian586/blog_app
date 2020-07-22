import 'dart:io';

import 'package:blogapp/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';


class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {

  File sampleImage;
  String _myValue;
  String url;
  final formKey = GlobalKey<FormState>();


  Future getImage() async
  {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage = tempImage;
    });
  }


  bool validateAndSave()
  {
    final form = formKey.currentState;

    if(form.validate())
      {
        form.save();
        return true;
      }
    else
      {
        return false;
      }
  }

  void uploadStatusImage() async
  {
    if(validateAndSave())
      {
        final StorageReference postImageRef = FirebaseStorage.instance.ref().child("Post Images");

        var timeKey = DateTime.now();

        final StorageUploadTask uploadTask = postImageRef.child(timeKey.toString() + ".jpg").putFile(sampleImage);

        var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

        url = imageUrl.toString();

        print("Image Url = " + url);

        goToHomePage();
        saveToDatabase(url);

      }
  }


  void saveToDatabase(url) async
  {
    var dbTimeKey = DateTime.now();
    var formatDate = DateFormat('MMM d, yyyy');
    var formatTime = DateFormat('EEEE, hh:mm aaa');

    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    //CollectionReference reference = Firestore.instance.collection('Posts');
    //await reference.add({
      //"image": url,
      //"description": _myValue,
      //"date": date,
      //"time": time
    //});

    DatabaseReference ref = FirebaseDatabase.instance.reference();

    var data = {
      "image": url,
      "description": _myValue,
      "date": date,
      "time": time,
    };

    ref.child("Posts").push().set(data);
  }

  void goToHomePage()
  {
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image"),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: sampleImage == null ? Text("Select an Image") : enableUpload(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Add Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }


  Widget enableUpload()
  {
    return Container(
      child: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            Image.file(sampleImage, height: 330.0,),

            SizedBox(height: 15.0,),

            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Description'
              ),
              validator: (value) {
                return value.isEmpty ? 'Description is required' : null;
              },
              onSaved: (value) {
                return _myValue = value;
              },
            ),

            SizedBox(height: 15.0,),

            RaisedButton(
              elevation: 10.0,
              child: Text("Add a new post"),
              textColor: Colors.white,
              color: Colors.pink,

              onPressed: uploadStatusImage,
            )
          ],
        ),
      ),
    );
  }

}
