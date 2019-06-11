import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stullerPower/login_page.dart';
import 'package:stullerPower/models/auth_service.dart';
import 'package:stullerPower/customer_list.dart';
import 'package:stullerPower/job_list.dart';
import 'package:stullerPower/profile.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>.value(stream: AuthService().user)
        // Provider<Location>.value(value: Location())
      ],
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(
          primaryColor: Color(0xFFFF2E99),
          primaryContrastingColor: Color(0xFF007AFF), // iOS 10's default blue 
          barBackgroundColor: Color(0xFFE5E5EA)
        ),
        home: UserInfoPage(),
      ),
    );
  }
}


class UserInfoPage extends StatelessWidget {
  final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    bool loggedIn = user != null;
    
    if (loggedIn) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              title: Text('Customers'),
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.clock),
              title: Text('Jobs'),
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.profile_circled),
              title: Text('Profile'),
            ),
          ],
        ),
        resizeToAvoidBottomInset: false,
        tabBuilder: (BuildContext context, int index) {
          assert(index >= 0 && index <=2);
          switch (index) {
            case 0: 
              return CupertinoTabView(
                builder: (BuildContext context) => CustomerList(),
              );
              break;
            case 1:
              return CupertinoTabView(
                builder: (BuildContext context) => JobList(),
              );
              break;
            case 2:
              return CupertinoTabView(
                builder: (BuildContext context) => Profile(),
              );
              break;
            }
            return null;
        },
      );
    }
    else return LoginPage();
  }
}