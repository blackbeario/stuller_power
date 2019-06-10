import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:providerlogin/models/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:providerlogin/main.dart';

class LoginPage extends StatefulWidget {
  createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  AuthService auth = AuthService();

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
        if (user != null) {
          return UserInfoPage();
        }
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
            FlutterLogo(size: 150),
            SafeArea(
              child: Form(
                key: _formKey,
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CupertinoTextField(
                          controller: _email,
                          // validator: (value) =>
                              // (value.isEmpty) ? "Please Enter Email" : null,
                          placeholder: "email",
                          style: TextStyle(color: CupertinoColors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CupertinoTextField(
                          controller: _password,
                          // validator: (value) =>
                          //     (value.isEmpty) ? "Please Enter Password" : null,
                          placeholder: "password",
                          style: TextStyle(color: CupertinoColors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.green,
                          child: CupertinoButton(
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                var user = await auth.signIn(
                                  _email.text, _password.text);
                                if (user != null) {
                                  return UserInfoPage();
                                }
                              }
                            },
                            child: Text(
                              "Sign In",
                              style: style.copyWith(
                                color: Colors.white,
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
