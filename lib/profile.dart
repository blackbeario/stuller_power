// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './services/auth_service.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
import './models/user.dart';

class Profile extends StatelessWidget {
  final db = DatabaseService();
  final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    if (user == null) {
      return Center(
          child: CupertinoActivityIndicator(
        animating: true,
      ));
    }
    return StreamBuilder<User>(
        stream: db.streamUser(user.uid),
        builder: (context, snapshot) {
          var myUser = snapshot.data;
          if (myUser == null) {
            return Center(
              child: Text('Loading...',
                  style:
                      CupertinoTheme.of(context).textTheme.navTitleTextStyle),
            );
          }
          return CupertinoPageScaffold(
              resizeToAvoidBottomInset: true,
              navigationBar: CupertinoNavigationBar(
                middle: Text('Profile'),
                trailing: CupertinoButton(
                    child: Icon(Icons.power_settings_new),
                    onPressed: () => _requestPop(context)),
              ),
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text(myUser.firstName + ' ' + myUser.lastName),
                      subtitle: Text('username'),
                    ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text(myUser.role),
                      subtitle: Text('role'),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone_iphone),
                      title: Text(myUser.phone),
                      subtitle: Text('mobile'),
                    ),
                  ],
                ),
              ));
        });
  }

  Future<bool> _requestPop(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Signout'),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text('Okay'),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context, 'Discard');
                    auth.signOut();
                  }),
              CupertinoDialogAction(
                child: Text('Cancel'),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context, 'Cancel');
                },
              ),
            ],
          );
        });
    return new Future.value(false);
  }
}
