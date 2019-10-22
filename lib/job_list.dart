// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stullerPower/calendar.dart';
import 'package:stullerPower/models/user.dart';
import './models/job.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
import './calendar.dart';

class JobList extends StatelessWidget {
  final auth = FirebaseAuth.instance;
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);

    if (user == null) {
      return Center(
        child: CupertinoActivityIndicator(
          animating: true,
        )
      );
    }
    return StreamBuilder<User>(
      stream: db.streamUser(user.uid),
      builder: (context, snapshot) {
        var $user = snapshot.data;
        if ($user == null) {
          return Center(
            child: Text('Loading...',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle),
          );
        }
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Schedule'),
          ),
          child: Container(
            child: StreamProvider<List<Job>>.value(
              // Gets a stream of jobs assigned to the logged-in user.
              // If user has admin role, get all jobs.
              stream: $user.role != 'admin' ? db.streamJobsByUser(user) : db.streamJobs(),
              // child: _buildCalendar()
              child: Calendar(),
            ),
          ),
        );
      },
    );
  }

  // Widget _buildCalendar() {
  //   var jobs = Provider.of<List<Job>>(context);

  //   if (jobs == null) {
  //     return Center(
  //       child: CupertinoActivityIndicator(
  //         animating: true,
  //       )
  //     );
  //   }
  //   return Calendar(jobs: jobs);
  // }
}


// class Jobs extends StatelessWidget {
//   final db = DatabaseService();
  
//   @override
//   Widget build(BuildContext context) {
//     var jobs = Provider.of<List<Job>>(context);
//     var user = Provider.of<FirebaseUser>(context);

//     if (jobs == null) {
//       return Center(
//         child: CupertinoActivityIndicator(
//           animating: true,
//         )
//       );
//     }

//     return ListView(
//       shrinkWrap: true,
//       children: jobs.map((job) {
//         bool status = job.done;
//         return Dismissible(
//           direction: DismissDirection.endToStart,
//           key: Key(job.id),
//           onDismissed: (direction) {
//             DatabaseService().removeJob(user, job.id);
//           },
//           child: Card(
//             margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
//             child: Container(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   ListTile(
//                     leading: Icon(status ? Icons.check_circle_outline : Icons.access_alarms),
//                     title: Text(job.title.toUpperCase()),
//                     subtitle: Text(job.description),
//                     // isThreeLine: true,
//                     onTap: () {
//                       Navigator.of(context).push(
//                         CupertinoPageRoute(builder: (context) {
//                           return JobDetails(job);
//                         }),
//                       );
//                     }
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           background: Container(
//             decoration: BoxDecoration(color: Colors.red), 
//             child: Align(
//               alignment: Alignment.centerRight, 
//               child: Icon(Icons.delete, color: Colors.white, size: 40),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }