import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:rxdart/rxdart.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
// import 'package:stullerPower/models/user.dart';
import 'package:table_calendar/table_calendar.dart';
import './models/job.dart';
import './job_details.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with TickerProviderStateMixin {
  Map<DateTime, List> _jobs;
  List _selectedJobs;
  final auth = FirebaseAuth.instance;
  final db = DatabaseService();
  AnimationController _animationController;
  CalendarController _calendarController;
  var _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    print('CALLBACK: _onDaySelected ' + _selectedDay.toString());


    _jobs = {};
      // _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7', 'Event E7', 'Event F7'],
      // _selectedDay.add(Duration(days: 1)): ['Event A8', 'Event B8', 'Event C8', 'Event D8'],
    // };

    _selectedJobs = _jobs[_selectedDay] ?? [];
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected ' + day.toString());
    setState(() {
      _selectedDay = day;
      _selectedJobs = events;
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  Widget _buildTableCalendarWithBuilders() {
    var jobs = Provider.of<List<Job>>(context);
    final _selectedDay = DateTime.now();

    if (jobs == null) {
      return Center(
        child: CupertinoActivityIndicator(
          animating: true,
        )
      );
    }

    
    _jobs = {
      // _selectedDay is always today = DateTime.now()
      // so we don't want to make every job shown for today.
      // Need to create a new object(?) and 
      _selectedDay: jobs.map((job) {
          return job;
        }).toList(),
      _selectedDay.add(Duration(days: 1)): ['Event A8', 'Event B8', 'Event C8', 'Event D8'],
    };

    setState(() {
      _selectedJobs = _jobs[_selectedDay] ?? [];
    });

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
          // formatButtonTextStyle: TextStyle(color: Colors.white, fontSize: 14),
          // formatButtonDecoration: BoxDecoration(
          //   borderRadius: BorderRadius.all(Radius.circular(12.0)),
          //   color: Colors.deepOrange[300],
          // ),
          // formatButtonShowsNext: false
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
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CupertinoButton(
              child: Text('Today'),
              onPressed: () {
                _calendarController.setSelectedDay(DateTime.now(), runCallback: true);
              },
            ),
            CupertinoButton(
              child: Text('Week'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.week);
                });
              },
            ),
            CupertinoButton(
              child: Text('Month'),
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

    if (_selectedJobs == null) {          
      return Center(
        child: CupertinoActivityIndicator(
          animating: true,
        )
      );
    }
    return ListView(
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

  @override
  Widget build(BuildContext context) {
    // List<Widget> jobs = [];
    // var user = Provider.of<FirebaseUser>(context);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _buildTableCalendarWithBuilders(),
        const SizedBox(height: 8.0),
        _buildButtons(),
        const SizedBox(height: 8.0),
        Expanded(child: _buildJobsList()),
      ],
    );
  }
}