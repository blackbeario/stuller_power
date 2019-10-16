// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stullerPower/models/user.dart';
import './models/job.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import './job_details.dart';

class JobList extends StatefulWidget {
  @override
  _JobListState createState() => _JobListState();
}

class _JobListState extends State<JobList> with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  List _selectedEvents;
  final auth = FirebaseAuth.instance;
  final db = DatabaseService();
  AnimationController _animationController;
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    final _selectedDay = DateTime.now();

    _events = {
      _selectedDay.subtract(Duration(days: 30)): ['Event A0', 'Event B0', 'Event C0'],
      _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
      _selectedDay.subtract(Duration(days: 20)): ['Event A2', 'Event B2', 'Event C2', 'Event D2'],
      _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
      _selectedDay.subtract(Duration(days: 10)): ['Event A4', 'Event B4', 'Event C4'],
      _selectedDay.subtract(Duration(days: 4)): ['Event A5', 'Event B5', 'Event C5'],
      _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
      _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7', 'Event E7', 'Event F7'],
      _selectedDay.add(Duration(days: 1)): ['Event A8', 'Event B8', 'Event C8', 'Event D8'],
      _selectedDay.add(Duration(days: 3)): Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
      _selectedDay.add(Duration(days: 7)): ['Event A10', 'Event B10', 'Event C10'],
      _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
      _selectedDay.add(Duration(days: 17)): ['Event A12', 'Event B12', 'Event C12', 'Event D12'],
      _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
      _selectedDay.add(Duration(days: 26)): ['Event A14', 'Event B14', 'Event C14'],
    };

    _selectedEvents = _events[_selectedDay] ?? [];

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
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

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
        var myUser = snapshot.data;
        if (myUser == null) {
          return Center(
            child: Text('Loading...',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle),
          );
        }
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Schedule'),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildTableCalendarWithBuilders(),
              const SizedBox(height: 8.0),
              _buildButtons(),
              const SizedBox(height: 8.0),
              Expanded(child: _buildEventList()),
              StreamProvider<List<Job>>.value(
                // Gets a stream of jobs assigned to the logged-in user.
                // If user has admin role, get all jobs.
                stream: myUser.role != 'admin' ? db.streamJobsByUser(user) : db.streamJobs(),
                child: Jobs(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableCalendarWithBuilders() {
    return Material(
      color: Colors.white,
      child: TableCalendar(
        rowHeight: 75,
        calendarController: _calendarController,
        events: _events,
        initialCalendarFormat: CalendarFormat.month,
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

  Widget _buildEventList() {
    return Material(
      child: ListView(
      children: _selectedEvents
        .map((event) => Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.8),
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                title: Text(event.toString()),
                // onTap: () => print('$event tapped!'),
              ),
            ))
        .toList(),
      ),
    );
  }
}


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

    return ListView(
      shrinkWrap: true,
      children: jobs.map((job) {
        bool status = job.done;
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
                    leading: Icon(status ? Icons.check_circle_outline : Icons.access_alarms),
                    title: Text(job.title.toUpperCase()),
                    subtitle: Text(job.description),
                    // isThreeLine: true,
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