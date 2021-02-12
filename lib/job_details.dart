import 'package:flutter/material.dart';
import './models/job.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
// import './job_form.dart';
import 'models/user.dart';

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
    bool status = widget.job.done;
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      navigationBar: CupertinoNavigationBar(
        middle: Text('${widget.job.title}'),
        // trailing: CupertinoButton(
        //     child: Text('Edit', style: TextStyle(fontSize: 12)),
        //     onPressed: () => _editJob(widget.job, context)),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(20.0),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    title: Text('Completed', style: TextStyle(fontSize: 24)),
                    trailing: CupertinoSwitch(
                      value: status,
                      onChanged: (bool value) {
                        db.updateDone(widget.job.id, value);
                        setState(() {
                          status = value;
                        });
                      },
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text(widget.job.description,
                        style: TextStyle(fontSize: 16)),
                  ),
                  Divider(),
                  ListTile(
                      leading: Icon(Icons.note_add),
                      title: Text(widget.job.notes)),
                  Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Colors.orange,
                    ),
                    title: Text(widget.job.customer,
                        style: TextStyle(fontSize: 16)),
                    subtitle: Text('Customer'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Colors.cyan,
                    ),
                    title: _getTech(widget.job.techID),
                    subtitle: Text('Technician'),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Parts List', style: TextStyle(fontSize: 24)),
                  ),
                  ListView(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      shrinkWrap: true,
                      children: <Widget>[
                        ListTile(
                          dense: true,
                          leading: Image(
                            image: AssetImage('assets/generator.jpg'),
                            height: 20,
                          ),
                          title: Text('Generator: Generac 16kw #123456789'),
                          trailing: Text('Qty: 1'),
                        ),
                        Divider(),
                        ListTile(
                          dense: true,
                          leading: Icon(Icons.filter_drama, color: Colors.grey),
                          title: Text('Air Filter: #123456789'),
                          trailing: Text('Qty: 1'),
                        ),
                        Divider(),
                        ListTile(
                          dense: true,
                          leading: Icon(Icons.battery_charging_full,
                              color: Colors.red),
                          title: Text('Battery: #123456789'),
                          trailing: Text('Qty: 1'),
                        ),
                        Divider(),
                        ListTile(
                            dense: true,
                            leading: Icon(Icons.format_color_fill,
                                color: Colors.black),
                            title: Text('Oil filter: #123456789'),
                            trailing: Text('Qty: 1')),
                        Divider(),
                        ListTile(
                          dense: true,
                          leading: Icon(Icons.flash_on, color: Colors.grey),
                          title: Text('Spark Plugs: #123456789'),
                          trailing: Text('Qty: 2'),
                        ),
                        Divider(),
                        ListTile(
                          dense: true,
                          leading: Icon(Icons.swap_vertical_circle,
                              color: Colors.red),
                          title: Text('Transfer Switch: #123456789'),
                          trailing: Text('Qty: 1'),
                        ),
                        Divider(),
                        ListTile(
                          dense: true,
                          leading: Icon(Icons.swap_calls, color: Colors.grey),
                          title: Text('Conduit: #123456789'),
                          trailing: Text('Length: 4\''),
                        ),
                        Divider(),
                        ListTile(
                          dense: true,
                          leading: Icon(Icons.swap_calls, color: Colors.grey),
                          title: Text('Wire: #123456789'),
                          trailing: Text('Length: 4\''),
                        ),
                        Divider(),
                        SizedBox(height: 10),
                        Flex(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          direction: Axis.horizontal,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 30),
                              color: Colors.green,
                              disabledColor: Colors.grey,
                              child: Text('Start Job',
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () => _startJob(context),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 30),
                              color: Colors.red,
                              disabledColor: Colors.grey,
                              child: Text('Stop Job',
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () => _endJob(context),
                            ),
                          ],
                        ),
                        SizedBox(height: 20)
                      ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTech(String id) {
    return FutureBuilder<User>(
        future: db.getTech(id),
        builder: (context, snapshot) {
          var $tech = snapshot.data;
          if ($tech == null) {
            return Center(
              child: Text('Loading...',
                  style:
                      CupertinoTheme.of(context).textTheme.navTitleTextStyle),
            );
          }
          return Text($tech.firstName + ' ' + $tech.lastName,
              style: TextStyle(fontSize: 16));
        });
  }

  // Future<bool> _editJob(job, BuildContext context) {
  //   showCupertinoDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return CupertinoAlertDialog(
  //           title: Text('Edit Job?'),
  //           content: Text('Are you sure you really want to update this job?' +
  //               ' This will affect all instances of this job on all devices immediately.'),
  //           actions: <Widget>[
  //             CupertinoDialogAction(
  //                 child: Text('Yes'),
  //                 isDestructiveAction: true,
  //                 onPressed: () async {
  //                   Navigator.pop(context, 'Discard');
  //                   await Navigator.of(context).push(
  //                     CupertinoPageRoute(builder: (context) {
  //                       return JobAddEdit(job);
  //                     }),
  //                   );
  //                 }),
  //             CupertinoDialogAction(
  //               child: Text('Cancel'),
  //               isDefaultAction: true,
  //               onPressed: () {
  //                 Navigator.pop(context, 'Cancel');
  //               },
  //             ),
  //           ],
  //         );
  //       });
  //   return Future.value(false);
  // }

  Future<bool> _startJob(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Start Job'),
            content: Text('This will set the start time for this job.'),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text('Confirm'),
                  isDestructiveAction: true,
                  onPressed: () {
                    db.startJob(widget.job.id);
                    Navigator.pop(context, 'Discard');
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
    return Future.value(false);
  }

  Future<bool> _endJob(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('End Job'),
            content: Text('This will set the completion time for this job.'),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text('Confirm'),
                  isDestructiveAction: true,
                  onPressed: () {
                    db.updateDone(widget.job.id, true);
                    Navigator.pop(context, 'Discard');
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
    return Future.value(false);
  }
}
