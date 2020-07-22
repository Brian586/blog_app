import 'package:blogapp/Authentication.dart';
import 'package:blogapp/DialogBox.dart';
import 'package:flutter/material.dart';


class LoginRegisterPage extends StatefulWidget {

  final AuthImplementation auth;
  final VoidCallback onSignedIn;

  LoginRegisterPage({
    this.auth,
    this.onSignedIn
});

  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}


enum FormType
{
  login,
  register
}


class _LoginRegisterPageState extends State<LoginRegisterPage> {

  DialogBox dialogBox = new DialogBox();

  final formKey = GlobalKey<FormState>();
  FormType _formType = FormType.login;
  String _email = "";
  String _password = "";

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


  void validateAndSubmit() async
  {
    if(validateAndSave())
      {
        try
            {
              if(_formType == FormType.login)
                {
                  String userId = await widget.auth.SignIn(_email, _password);
                  //dialogBox.information(context, "Congratulations", "Login successful");
                  print("login userId = " + userId);
                }
              else
                {
                  String userId = await widget.auth.SignUp(_email, _password);
                  //dialogBox.information(context, "Congratulations", "Your Account has been created successfully");
                  print("Register userId = " + userId);
                }

              widget.onSignedIn();

            }
        catch(e)
            {
              dialogBox.information(context, "Error = ", e.toString());
              print("Error = " + e.toString());
            }
      }
  }


  void moveToRegister()
  {
    formKey.currentState.reset();

    setState(() {
      _formType = FormType.register;
    });
  }


  void moveToLogin()
  {
    formKey.currentState.reset();

    setState(() {
      _formType = FormType.login;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Blog App"),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(15.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: createInputs() + createButtons(),
              ),
            ),
          ),
        ],
      )
    );
  }


  List<Widget> createInputs() {
    return [
      SizedBox(height: 10,),
      logo(),
      SizedBox(height: 20,),

      TextFormField(
        decoration: InputDecoration(
          labelText: "Email"
        ),
        validator: (value) {
          return value.isEmpty ? 'Email is required' : null;
        },
        onSaved: (value) {
          return _email = value;
        },
      ),

      SizedBox(height: 10,),

      TextFormField(
        decoration: InputDecoration(
            labelText: "Password"
        ),
        obscureText: true,
        validator: (value) {
          return value.isEmpty ? 'Password is required' : null;
        },
        onSaved: (value) {
          return _password = value;
        },
      )
    ];
  }

  Widget logo()
  {
    return Hero(
        tag: 'hero',
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 110.0,
          //child: Image.asset('images/app_logo.png'),
        )
    );
  }

  List<Widget> createButtons() {
    if(_formType == FormType.login)
      {
        return [
          RaisedButton(
            color: Colors.pink,
            onPressed: validateAndSubmit,
            child: Text("Login", style: TextStyle(fontSize: 20.0, color: Colors.white),),
          ),

          FlatButton(
            onPressed: moveToRegister,
            textColor: Colors.red,
            child: Text("Create Account", style: TextStyle(fontSize: 14.0, ),),
          ),

        ];
      }
    else
      {
        return [
          RaisedButton(
            onPressed: validateAndSubmit,
            color: Colors.pink,
            child: Text("Create Account", style: TextStyle(fontSize: 20.0, color: Colors.white),),
          ),

          FlatButton(
            onPressed: moveToLogin,
            textColor: Colors.red,
            child: Text("Already have an Account? Login", style: TextStyle(fontSize: 14.0, ),),
          ),

        ];
      }
  }

}
