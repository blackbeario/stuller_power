import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stullerPower/login_page.dart';
import './services/auth_service.dart';
import 'package:stullerPower/customer_list.dart';
import 'package:stullerPower/job_list.dart';
import 'package:stullerPower/profile.dart';
import 'package:flutter/cupertino.dart';
import './models/customer.dart';
import './models/user.dart';
import './models/job.dart';
import './services/db_service.dart';

void main() => runApp(MyApp());
final db = DatabaseService();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>(builder: (context) => AuthService().user),
        StreamProvider<List<Customer>>(builder: (context) => db.streamCustomers()),
      ],
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(
          primaryColor: Color(0xFFFF822E),
          primaryContrastingColor: Color(0xFF007AFF), // iOS 10's default blue 
          barBackgroundColor: Color(0xFFE5E5EA)
        ),
        home: AppHomePage(),
      ),
    );
  }
}


class AppHomePage extends StatelessWidget {
  // final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    bool loggedIn = user != null;
    
    if (loggedIn) {
      return FutureBuilder<User>(
        future: db.getUser(user),
        builder: (context, snapshot) {
          var $user = snapshot.data;
          if ($user == null) {
            return Center(
              child: Text('Loading...',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle),
            );
          }
          return CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.clock),
                title: Text('Schedule'),
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                title: Text('Customers'),
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
              return StreamProvider<List<Job>>(
                builder: (context) => $user.role != 'admin' ? db.streamJobsByUser(user) : db.streamJobs(),
                child: CupertinoTabView(
                  builder: (BuildContext context) => JobList(),
                ));
                break;
              case 1:
                return CupertinoTabView(
                  builder: (BuildContext context) => Customers(),
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
      });
    }
    else return LoginPage();
  }
}