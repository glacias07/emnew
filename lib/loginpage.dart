import 'package:flutter/material.dart';
import 'colorcheme.dart';
import 'calander.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'colorcheme.dart';
import 'colorcheme.dart';
import 'resetpass.dart';

class LoginPage extends StatefulWidget {
  static String id = 'welcome';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  String _email;
  String _password;

  final GlobalKey<FormState> _loginkey = GlobalKey<FormState>();
  bool passwordVisible = false;

  Widget _buildEmailRow() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: TextField(
        onChanged: (value) {
          _email = value;
        },
        keyboardType: TextInputType.emailAddress,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          hintText: 'Email address',
          prefixIcon: Icon(
            Icons.email,
            color: mainColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRow() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: TextField(
        keyboardType: TextInputType.text,
        obscureText: !passwordVisible,
        onChanged: (value) {
          _password = value;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock,
            color: mainColor,
          ),
          hintText: 'Password',
          suffixIcon: IconButton(
              icon: Icon(
                // Based on passwordVisible state choose the icon
                passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).textTheme.bodyText2.color,
              ),
              onPressed: () {
                setState(() {
                  passwordVisible = !passwordVisible;
                });
              }
              // Update the state i.e. toogle the state of passwordVisible variable

              ),
        ),
      ),
    );
  }

  Widget _buildForgetPasswordButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          child: Text('Forgot Password?'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ResetScreen()),
          ),
        )
      ],
    );
  }

  Widget _buildLoginButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 1 * (MediaQuery.of(context).size.height / 20),
          width: 5 * (MediaQuery.of(context).size.width / 10),
          margin: EdgeInsets.only(bottom: 10, top: 10),
          child: RaisedButton(
            elevation: 4.0,
            color: logincolor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () async {
              try {
                final user = await _auth.signInWithEmailAndPassword(
                    email: _email, password: _password);
                if (user != null) {
                  Fluttertoast.showToast(
                      msg: "Logged in Successful",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      fontSize: 16.0);
                  Navigator.pushNamed(context, CalendarPage.id);
                }
              } catch (e) {
                Fluttertoast.showToast(
                    msg: "Wrong Email/Password",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    fontSize: 16.0);
              }
            },
            child: Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: MediaQuery.of(context).size.height / 40,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildEmailRow(),
                _buildPasswordRow(),
                _buildForgetPasswordButton(),
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          // elevation: 0,
          backgroundColor: purple,
          title: Text(
            'Event Management',
            style: TextStyle(color: Colors.white),
          ),
        ),
        resizeToAvoidBottomPadding: false,
        body: Stack(
          key: _loginkey,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Container(
                decoration: BoxDecoration(
                  color: purple,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 55, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'LOG IN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      wordSpacing: 1,
                      letterSpacing: 2,
                      fontSize: 40,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildContainer(),
                //_buildSignUpBtn(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
