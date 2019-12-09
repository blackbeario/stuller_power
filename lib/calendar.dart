// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import './models/job.dart';
import './job_details.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  Calendar({
    Key key,
    this.jobs
    }) : super(key: key);
    final List<Job> jobs;

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with SingleTickerProviderStateMixin {
  Map<DateTime, List<Job>> _jobs = {};
  Map<DateTime, List<Job>> _jobsPrelist = {};
  List _selectedJobs;
  final auth = FirebaseAuth.instance;
  final db = DatabaseService();
  AnimationController _animationController;
  CalendarController _calendarController;
  // StreamController<Job> _streamController;
  var _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
    // _streamController = StreamController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    // _streamController.close();
    super.dispose();
  }

  // This isn't run until a day is tapped on the calendar.
  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedDay = day;
      _selectedJobs = events;
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
    // print('CALLBACK: _onVisibleDaysChanged');
  }

  @override
  Widget build(BuildContext context) {
    _jobs?.clear();
    _jobsPrelist?.clear();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _buildTableCalendarWithBuilders(widget.jobs),
        const SizedBox(height: 8.0),
        _buildButtons(),
        const SizedBox(height: 8.0),
        Expanded(child: _buildJobsList()),
      ],
    );
  }

  Widget _buildTableCalendarWithBuilders(jobs) {
    if (jobs == null) {
      return Center(
        child: CupertinoActivityIndicator(
          animating: false,
        )
      );
    }

    // Ideally, we'd have an aggregated db query that combines jobs by date.
    // But for now we're checking the values of the jobs stream and grouping here.
    jobs.forEach((job) {
      if (job != null && job.scheduled != null) {
        // Sets a ymd variable for the year month date of each job.
        var ymd = job.scheduled.year.toString() + '-' + job.scheduled.month.toString() + '-' + job.scheduled.day.toString();
        // Checks to see if the jobsPrelist array has the ymd.
        var dateExists = _jobsPrelist.keys.toString().contains(ymd);
        var jobID = job.id;
        // If the ymd doesn't exist, add it to the array.
        if (!dateExists) {
          _jobsPrelist[job.scheduled] = [job];
        }
        // If the date already exists, loop through the array keys
        else {
          // Create an empty "work" array to use since we can't modify the 
          // _jobsPrelist array directly while looping through it.
          var toAdd = [];
          _jobsPrelist.forEach((key, value) {
            if (key.toString().contains(ymd)) {
              value.forEach((val) {
                // Adds the jobID to a temp array if it doesn't already exist in the value list.
                if (val.id != (jobID)) {
                  print('Adding ' + jobID + ' to ' + ymd);
                  toAdd.add(job);
                }
              });
              // Adds element of the array to the _jobsPrelist value.
              if (toAdd.isNotEmpty) {
                value.add(toAdd[0]);
              }
            }
          });
        }
      }
      if (_selectedJobs == null) {
        var now = DateTime.now();
        var today = now.year.toString() + '-' + now.month.toString() + '-' + now.day.toString();
        _jobsPrelist.forEach((key, value) {
          if (key.toString().contains(today)) {
            _selectedJobs = value;
          }
        });
      }
    });
    
    // Finally, add our _jobsPrelist to our _jobs array that 
    // gets assigned to the Calendar events parameter.
    _jobs.addAll(_jobsPrelist);

    return Material(
      color: Colors.white,
      child: TableCalendar(
        rowHeight: 75,
        calendarController: _calendarController,
        events: _jobs,
        initialCalendarFormat: CalendarFormat.week,
        formatAnimation: FormatAnimation.slide,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        availableGestures: AvailableGestures.all,
        availableCalendarFormats: const {
          CalendarFormat.week: '',
          CalendarFormat.month: ''
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
          markersMaxAmount: 20
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
        ),
        headerStyle: HeaderStyle(
          centerHeaderTitle: true,
          formatButtonVisible: false,
        ),
        builders: CalendarBuilders(
          dayBuilder: (context, date, _) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[50],
              ),
                margin: const EdgeInsets.all(6.0),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  textAlign: TextAlign.center,
                ),
            );
          },
          selectedDayBuilder: (context, date, _) {
            return FadeTransition(
              opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[300],
                ),
                margin: const EdgeInsets.all(6.0),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: TextStyle().copyWith(color: Colors.white, fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
          todayDayBuilder: (context, date, _) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.deepOrange[300]),
                // color: Colors.grey[50],
              ),
              margin: const EdgeInsets.all(6.0),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
            );
          },
          markersBuilder: (context, date, events, holidays) {
            final children = <Widget>[];
            if (events.isNotEmpty) {
              children.add(
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: _buildEventsMarker(date, events),
                ),
              );
            }
            return children;
          },
        ),
        onDaySelected: (date, events) {
          _onDaySelected(date, events);
          _animationController.forward(from: 0.0);
        },
        onVisibleDaysChanged: _onVisibleDaysChanged,
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _calendarController.isSelected(date)
            ? Colors.deepOrange
            : _calendarController.isToday(date) ? Colors.blue[200] : Colors.blueGrey[200],
      ),
      margin: const EdgeInsets.fromLTRB(0,0,20,4),
      alignment: Alignment.center,
      width: 18.0,
      height: 18.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: <Widget>[
        SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CupertinoButton(
              child: Text('Today'),
              color: Colors.white70,
              onPressed: () {
                _calendarController.setSelectedDay(DateTime.now(), runCallback: true);
              },
            ),
            CupertinoButton(
              child: Text('Week'),
              color: Colors.white70,
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.week);
                });
              },
            ),
            CupertinoButton(
              child: Text('Month'),
              color: Colors.white70,
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.month);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJobsList() {
    var user = Provider.of<FirebaseUser>(context);
    if (_selectedJobs == null || _selectedJobs.length == 0) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Text('No jobs currently scheduled for this day.'),
      );
    }

    return ListView(
      padding: EdgeInsets.only(top: 4),
      shrinkWrap: true,
      children: _selectedJobs.map((job) {
        bool status = job.done;
        DateFormat dateFormat = DateFormat.jm();
        String _scheduled = dateFormat.format(job.scheduled);
        var jobPending = Icon(Icons.alarm, color: Colors.deepOrange[300]);
        var jobDone = Icon(Icons.check_circle_outline, color: Colors.green[100]);
        var doneColor = status ? TextStyle().copyWith(color: Colors.grey[350]) : TextStyle();
        return Dismissible(
          direction: DismissDirection.endToStart,
          key: Key(job.id),
          onDismissed: (direction) {
            DatabaseService().removeJob(user, job.id);
          },
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: _buildLeading(_scheduled, status),
                    title: Text(job.title.toUpperCase(),
                      style: doneColor
                    ),
                    subtitle: Text(job.description, style: doneColor),
                    trailing: status ? jobDone : jobPending,
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(builder: (context) {
                          // This is a bit of a hack to get around the fact that the job returned 
                          // by the calendar widget isn't dynamically updated, even though the Calendar 
                          // gets it's data from a StreamProvider. So we're manually taking the job ID
                          // and returning a single job stream so that the JobDetails screen is dynamically 
                          // updated after a save.
                          return StreamBuilder(
                            stream: db.getJob(job.id),
                            builder: (context, snapshot) {
                              var $job = snapshot.data;
                              if (!snapshot.hasData) {
                                return SizedBox(
                                  height: 100.0,
                                  width: 100.0,
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              return JobDetails($job);
                            });
                        }),
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
          background: Container(
            decoration: BoxDecoration(color: Colors.deepOrange[300]), 
            child: Align(
              alignment: Alignment.centerRight, 
              child: Icon(Icons.delete, color: Colors.white, size: 40),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLeading(_scheduled, status) {
    return Container(
      alignment: Alignment.center,
      child: Text(_scheduled, style: status ? TextStyle().copyWith(color: Colors.grey[350]) : TextStyle(),),
      height: 100,
      width: 100,
      padding: EdgeInsets.only(right: 10),
      decoration:
        BoxDecoration(
          border: Border(
            right: BorderSide(color: status ? Colors.deepOrange[100] : Colors.deepOrange)
          )
        )
      );
  }
}