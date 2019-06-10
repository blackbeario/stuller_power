// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './models/job.dart';
import './db_service.dart';
import 'package:flutter/cupertino.dart';


class Jobs extends StatelessWidget {
  final db = DatabaseService();
  
  @override
  Widget build(BuildContext context) {
    var jobs = Provider.of<List<Job>>(context);
    var user = Provider.of<FirebaseUser>(context);

    if (jobs == null) {
      return Center(
        child: CupertinoActivityIndicator(
          animating: true,
        )
      );
    }
    else return ListView(
      shrinkWrap: true,
      children: jobs.map((job) {
        return Dismissible(
          direction: DismissDirection.endToStart,
          key: Key(job.id),
          onDismissed: (direction) {
            DatabaseService().removeJob(user, job.id);
          },
          child: Card(
            margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.access_alarms),
                    title: Text(job.title.toUpperCase()),
                    subtitle: Text(job.description),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(builder: (context) {
                          return JobDetails(job);
                        }),
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
          background: Container(
            decoration: BoxDecoration(color: Colors.red), 
            child: Align(
              alignment: Alignment.centerRight, 
              child: Icon(Icons.delete, color: Colors.white, size: 40),
            ),
          ),
        );
      }).toList(),
    );
  }
}


class JobList extends StatelessWidget {
  final auth = FirebaseAuth.instance;
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('My Jobs'),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          StreamProvider<List<Job>>.value(
            stream: db.streamJobs(user),
            child: Jobs(),
          ),
        ],
      ),
    );
  }
}

class JobDetails extends StatefulWidget {
  final Job job;
  const JobDetails(this.job);

  @override
  _JobDetailsState createState() => _JobDetailsState();
}

class _JobDetailsState extends State<JobDetails> {
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    // var user = Provider.of<FirebaseUser>(context);
    bool status = widget.job.done;
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      navigationBar: CupertinoNavigationBar(
        middle: Text('${widget.job.title}'),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(20.0),
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.info),
                  subtitle:  Text('${widget.job.description}'),
                ),
                ListTile(
                  title: Text('Status'),
                  trailing: CupertinoSwitch(
                    value: status,
                    onChanged: (bool value) {
                      db.updateDone(widget.job.id, value);
                      setState(() { status = value; });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}