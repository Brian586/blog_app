import 'package:blogapp/Authentication.dart';
import 'package:blogapp/Posts.dart';
import 'package:blogapp/Upload.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';




class HomePage extends StatefulWidget {

  final AuthImplementation auth;
  final VoidCallback onSignedOut;

  HomePage({
    this.auth,
    this.onSignedOut,
});

  @override
  _HomePageState createState() => _HomePageState();
}




class _HomePageState extends State<HomePage> {


  List<Posts> postList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    DatabaseReference postsRef = FirebaseDatabase.instance.reference().child("Posts");

    postsRef.once().then((DataSnapshot snap) {
      var KEYS = snap.value.keys;
      var DATA = snap.value;

      postList.clear();

      for(var individualKey in KEYS)
        {
          Posts posts = new Posts(
            DATA[individualKey]['image'],
            DATA[individualKey]['description'],
            DATA[individualKey]['time'],
            DATA[individualKey]['date'],
          );

          postList.add(posts);
        }

      setState(() {
        print('Length : $postList.length');
      });
    });
  }


  void _logoutUser() async
  {
    try
    {
      await widget.auth.signOut();
      widget.onSignedOut();
    }
    catch(e)
    {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        centerTitle: true,
      ),
      body: Container(
        child: postList.length == 0 ? Text("No Blog Posts available") : ListView.builder(
          itemCount: postList.length,
          itemBuilder: (_, index) {
            return PostUI(postList[index].image, postList[index].description, postList[index].date, postList[index].time,);
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.pink,
        child: Container(
          margin: const EdgeInsets.only(left: 50.0, right: 50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(icon: Icon(Icons.home, color: Colors.white,), onPressed: _logoutUser, iconSize: 30.0, ),
              IconButton(
                icon: Icon(
                  Icons.add_a_photo,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UploadPage()));
                },
                iconSize: 30.0,),
            ],
          ),
        ),
      ),
    );
  }


  Widget PostUI(String image, String description, String date, String time,)
  {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0)
      ),
      elevation: 10.0,
      margin: EdgeInsets.all(15.0),
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0)
            ),
            padding: EdgeInsets.all(0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.network(image, fit: BoxFit.cover, height: 300.0,),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              height: 100.0,
              padding: EdgeInsets.only(bottom: 0.0, left: 0.0, right: 0.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: FractionalOffset.bottomCenter,
                  end: FractionalOffset.topCenter,
                  colors: [
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [0.0, 1.0]
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15.0,), bottomRight: Radius.circular(15.0)),
              ),
            ),
          ),
          Positioned(
            top: 10.0,
            right: 10.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(time, style: TextStyle(color: Colors.white, fontSize: 15.0, ),),
                SizedBox(width: 20.0,),
                Text(date, style: TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold),)
              ],
            ),
          ),
          Positioned(
            bottom: 10.0,
            left: 20.0,
            child: Text(description, style: TextStyle(color: Colors.white, fontSize: 20.0),),
          )
        ],
      ),
    );
  }

}
