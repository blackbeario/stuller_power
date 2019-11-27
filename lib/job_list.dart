import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stullerPower/calendar.dart';
import './models/job.dart';
import 'package:flutter/cupertino.dart';
import './calendar.dart';

class JobList extends StatelessWidget {

  Widget build(BuildContext context) {
    var jobs = Provider.of<List<Job>>(context);

    if (jobs == null) {
      return Center(
        child: CupertinoActivityIndicator(
          animating: true,
        )
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Schedule'),
      ),
      child: Calendar(jobs: jobs), 
    );
  }
}