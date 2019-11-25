import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import './services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:stullerPower/main.dart';

class LoginPage extends StatefulWidget {
  createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  AuthService auth = AuthService();
  bool _hidePassword = true;
  String animationName = 'flash';

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController _email;
  TextEditingController _password;
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: "");
    _password = TextEditingController(text: "");
    auth.getUser.then(
      (user) {
        if (user == null) {
          return CupertinoActivityIndicator(animating: true);
        }
        return AppHomePage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<AuthService>(context);
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.darkBackgroundGray,
      key: _key,
      child: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        
          children: <Widget>[
            Expanded(
              child: FlareActor(
                'assets/bolt2.flr',
                alignment: Alignment.center,
                fit: BoxFit.contain,
                animation: animationName
              ),
            ),
            SafeArea(
              child: Form(
                key: _formKey,
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CupertinoTextField(
                          controller: _email,
                          padding: EdgeInsets.all(10.0),
                          // validator: (value) =>
                              // (value.isEmpty) ? "Please Enter Email" : null,
                          placeholder: "email",
                          style: TextStyle(color: CupertinoColors.darkBackgroundGray),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CupertinoTextField(
                          padding: EdgeInsets.all(10.0),
                          controller: _password,
                          placeholder: "password",
                          obscureText: _hidePassword,
                          style: TextStyle(color: CupertinoColors.darkBackgroundGray),
                          suffix: FlatButton(
                            onPressed: _toggle,
                            child: Icon(_hidePassword ? Icons.lock : Icons.lock_open, color: CupertinoColors.inactiveGray)
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.orange[400],
                          child: CupertinoButton(
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                var user = await auth.signIn(
                                  _email.text, _password.text);
                                if (user == null) {
                                  return CupertinoActivityIndicator(animating: true);
                                }
                              }
                              return AppHomePage();
                            },
                            child: Text(
                              "Sign In",
                              style: style.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}
