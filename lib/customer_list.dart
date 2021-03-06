import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './models/customer.dart';
import './models/job.dart';
import './services/db_service.dart';
import './locations_list.dart';
import './customer_map.dart';
import './customer_form.dart';
import './job_details.dart';
// import 'package:mobile/ui/elements/cupertino_area_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class Customers extends StatefulWidget {
  const Customers({Key key}) : super(key: key);

  @override
  _CustomersState createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  final db = DatabaseService();
  final auth = FirebaseAuth.instance;
  final Completer<GoogleMapController> _mapController = Completer();
  bool _searchVisible = false;
  Customer customer;

  @override
  void initState() {
    super.initState();
  }

  void _changed(bool visibility, String field) {
    setState(() {
      if (field == "search") {
        _searchVisible = visibility;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var customers = Provider.of<List<Customer>>(context);
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Customers'),
        trailing: CupertinoButton(
            child: Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) {
                    return CustomerAddEdit(customer);
                  }),
                )),
      ),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        Flexible(
          child: CustomerMap(
              initialPosition: const LatLng(35.31873, -82.46095),
              mapController: _mapController),
          flex: 3,
        ),
        Flexible(
            flex: 2,
            child: CustomerList(
                customers: customers, mapController: _mapController))
      ]),
    );
  }
}

// Creates the Customer ListTiles, etc for the CustomerList
class CustomerList extends StatefulWidget {
  CustomerList({
    Key key,
    this.customers,
    @required this.mapController,
  }) : super(key: key);

  // The original stream of customers.
  List<Customer> customers = List();
  final Completer<GoogleMapController> mapController;

  @override
  _CustomerListState createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  final auth = FirebaseAuth.instance;
  final db = DatabaseService();

  List<Customer> filteredCustomers = List();

  @override
  void initState() {
    super.initState();
    setState(() {
      filteredCustomers = widget.customers;
    });
  }

  // Resets customer list from child widget action.
  void callback(resetCustomers) {
    setState(() {
      _changed(false, "search");
      filteredCustomers = resetCustomers;
    });
  }

  bool _searchVisible = false;

  void _changed(bool visibility, String field) {
    setState(() {
      if (field == "search") {
        _searchVisible = visibility;
      }
    });
  }

  // Customers Listview
  @override
  Widget build(BuildContext context) {
    if (filteredCustomers == null) {
      return Center(
        child: Stack(children: <Widget>[
          Text('loading...'),
          // CupertinoActivityIndicator(
          //   animating: true,
          //   radius: 18.0,
          // )
        ]),
      );
    }
    return Container(
      decoration: new BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ListView.separated(
                itemCount: filteredCustomers.length,
                shrinkWrap: true,
                separatorBuilder: (context, index) {
                  return Divider(height: 0);
                },
                itemBuilder: (context, index) {
                  if (index < filteredCustomers.length) {
                    return CustomerTile(
                      callback: callback,
                      changed: _changed,
                      customers: widget.customers,
                      db: db,
                      filtered: filteredCustomers,
                      index: index,
                      lastItem: index == filteredCustomers.length - 1,
                      customer: filteredCustomers[index],
                      mapController: widget.mapController,
                    );
                  }
                  return Text('loading...');
                }),
          ),

          // Search Bar
          _searchVisible
              ? new Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                      Expanded(
                        flex: 11,
                        child: CupertinoTextField(
                          padding: EdgeInsets.all(10.0),
                          expands: true,
                          autofocus: true,
                          minLines: null,
                          maxLines: null,
                          placeholder: " search",
                          onChanged: (string) {
                            setState(() {
                              filteredCustomers = widget.customers
                                  .where((customer) => (customer.firstName
                                          .toLowerCase()
                                          .contains(string.toLowerCase()) ||
                                      customer.lastName
                                          .toLowerCase()
                                          .contains(string.toLowerCase()) ||
                                      customer.email
                                          .toLowerCase()
                                          .contains(string.toLowerCase())))
                                  .toList();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: new CupertinoButton(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Icon(
                            CupertinoIcons.clear,
                            size: 44,
                          ),
                          onPressed: () {
                            _changed(false, "search");
                            filteredCustomers = widget.customers;
                          },
                        ),
                      )
                    ])
              : Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        alignment: Alignment.bottomRight,
                        // color: Colors.yellow,
                        child: CupertinoButton(
                          borderRadius: BorderRadius.zero,
                          padding: EdgeInsets.fromLTRB(340.0, 0, 20, 0),
                          // color: Colors.grey,
                          child: Icon(CupertinoIcons.search),
                          onPressed: () {
                            _changed(true, "search");
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class CustomerTile extends StatelessWidget {
  CustomerTile({
    Key key,
    this.callback,
    this.changed,
    this.customers,
    this.db,
    this.filtered,
    this.index,
    this.lastItem,
    @required this.customer,
    @required this.mapController,
  }) : super(key: key);

  final Function callback;
  final changed;
  List<Customer> customers;
  final db;
  List<Customer> filtered;
  final int index;
  final bool lastItem;
  final Customer customer;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CustomerLocation>(
        future: db.getLocation(customer.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Material(
              child: InkWell(
                onDoubleTap: () async {
                  await Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) {
                      return StreamProvider<Customer>(
                        create: (context) => db.streamCustomer(customer.id),
                        child: CustomerDetails(customer.id),
                      );
                    }),
                  );
                  await callback(filtered = customers);
                },
                child: ListTile(
                  leading: Icon(Icons.error_outline, color: Colors.red),
                  title: Text(customer.id + ':' + snapshot.error),
                ),
              ),
            );
          } else if (snapshot.hasData) {
            return Material(
              child: InkWell(
                onTap: () {
                  _goToLocation(mapController, snapshot.data.position);
                  callback(filtered = customers);
                },
                onDoubleTap: () async {
                  await Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) {
                      return StreamProvider<Customer>(
                        create: (context) => db.streamCustomer(customer.id),
                        child: CustomerDetails(customer.id),
                      );
                    }),
                  );
                  await callback(filtered = customers);
                },
                // Call the customer
                onLongPress: () {
                  _callCustomer(customer, context);
                },
                child: ListTile(
                  dense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
                  leading: Icon(Icons.person_pin_circle,
                      color: db.markerColor(snapshot.data.area), size: 36),
                  title: Text(customer.firstName + ' ' + customer.lastName),
                  subtitle: snapshot.data.address != '?'
                      ? Text(snapshot.data.address + ', ' + snapshot.data.city)
                      : Text(
                          'Customer has no address in database!',
                          style:
                              TextStyle(color: CupertinoColors.destructiveRed),
                        ),
                  trailing: Icon(Icons.phone, color: Colors.green),
                ),
              ),
            );
          } else {
            return CupertinoActivityIndicator();
          }
        });
  }

  void _goToLocation(mapController, location) async {
    double lat = location['geopoint'].latitude;
    double long = location['geopoint'].longitude;
    final controller = await mapController.future;
    await controller
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, long), 16));
  }
}

/// Customer Details screen
class CustomerDetails extends StatelessWidget {
  final String customerId;
  CustomerDetails(this.customerId);
  final db = DatabaseService();
  Customer customer;

  Widget _getJobs(List<String> jobs) {
    return Column(
        children: jobs.map((job) {
      return StreamBuilder<Job>(
          stream: db.getJob(job),
          builder: (context, snapshot) {
            var $job = snapshot.data;

            if ($job == null) {
              return CupertinoActivityIndicator(
                animating: true,
              );
            }
            if (snapshot.hasError) {
              return Text('Error fetching jobs');
            }
            var status = $job.done;
            var jobDate = $job.scheduled.year.toString() +
                '-' +
                $job.scheduled.month.toString() +
                '-' +
                $job.scheduled.day.toString();
            return GestureDetector(
              child: Material(
                child: ListTile(
                  contentPadding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                  leading: status
                      ? Icon(Icons.check_circle_outline,
                          color: Colors.green[300])
                      : Icon(Icons.timer, color: Colors.orangeAccent[300]),
                  title: Text($job.title),
                  subtitle: Text(jobDate),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
              onTap: () {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return JobDetails($job);
                }));
              },
            );
          });
    }).toList());
  }

  // The client wants to show all job notes in the CustomerDetails view.
  // So I need to get the Jobs by id, then display the notes field.
  // Alternatively, I could have one Jobs stream where customer is defined, but that would require an index in Firestore.
  // No biggie, but that wouldn't be as performant. Need to do some tests to compare.
  Widget _getNotes(List<String> jobs) {
    return Column(
        children: jobs.map((job) {
      return StreamBuilder<Job>(
          stream: db.getJob(job),
          builder: (context, snapshot) {
            var $job = snapshot.data;

            if ($job == null) {
              return CupertinoActivityIndicator(
                animating: true,
              );
            }
            if (snapshot.hasError) {
              return Text('Error fetching job notes');
            }
            var jobDate = $job.scheduled.year.toString() +
                '-' +
                $job.scheduled.month.toString() +
                '-' +
                $job.scheduled.day.toString();
            return ListTile(
              title: Text(jobDate, style: TextStyle(fontSize: 14)),
              subtitle: Text($job.notes, style: TextStyle(fontSize: 16)),
              contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 6),
            );
          });
    }).toList());
  }

  @override
  Widget build(BuildContext context) {
    var customer = Provider.of<Customer>(context);
    if (customer == null) {
      return CupertinoActivityIndicator(animating: true);
    }
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      navigationBar: CupertinoNavigationBar(
        middle: Text('${customer.firstName}' + ' ' + '${customer.lastName}'),
        trailing: CupertinoButton(
            child: Text('Edit Customer', style: TextStyle(fontSize: 12)),
            onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) {
                    return CustomerAddEdit(customer);
                  }),
                )),
      ),
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.all(10),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // Email
                          ListTile(
                            leading:
                                Icon(Icons.email, color: Colors.orangeAccent),
                            title: Text(customer.email),
                          ),
                          // Notes
                          ListTile(
                            leading: Icon(Icons.edit, color: Colors.grey),
                            title: Text(customer.notes),
                          ),
                          // Main phone
                          customer.main != ''
                              ? ListTile(
                                  leading:
                                      Icon(Icons.phone, color: Colors.green),
                                  title: Text(customer.main),
                                  onTap: () {
                                    _callCustomer(customer, context);
                                  },
                                )
                              : Container(),
                          // Cell phone
                          customer.mobile != ''
                              ? ListTile(
                                  leading:
                                      Icon(Icons.phone, color: Colors.green),
                                  title: Text(customer.mobile),
                                  onTap: () {
                                    _callCustomer(customer, context);
                                  },
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.all(10),
                child: StreamProvider<List<CustomerLocation>>(
                  create: (context) => db.streamlocations(customer.id),
                  child: Locations(customer: customer),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.all(10),
                child: ExpansionTile(
                  leading: Icon(Icons.timer),
                  initiallyExpanded: true,
                  title: Text('Job History'),
                  trailing: Container(height: 0.0, width: 0.0),
                  children: <Widget>[
                    customer.jobs != null
                        ? _getJobs(customer.jobs)
                        : ListTile(
                            title: Text(
                              'No job history for this customer. See customer notes above for recorded details.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ],
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.all(10),
                child: ExpansionTile(
                  leading: Icon(Icons.event_note),
                  initiallyExpanded: true,
                  title: Text('Job Notes'),
                  trailing: Container(height: 0.0, width: 0.0),
                  children: <Widget>[
                    customer.jobs != null
                        ? _getNotes(customer.jobs)
                        : ListTile(
                            title: Text(
                              'No notes history for this job.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _editCustomer(customer, BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Edit Customer?'),
            content: Text('Are you sure you really want to update this customer?' +
                ' This will immediately affect all instances of this customer on all devices.'),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text('Yes'),
                  isDestructiveAction: false,
                  onPressed: () async {
                    Navigator.pop(context, 'Discard');
                    await Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) {
                        return CustomerAddEdit(customer);
                      }),
                    );
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

Future<bool> _callCustomer(customer, BuildContext context) {
  showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
              'Call ' + customer.firstName + ' ' + customer.lastName + '?'),
          actions: <Widget>[
            CupertinoDialogAction(
                child: Text('Okay'),
                isDestructiveAction: true,
                onPressed: () {
                  bool hasMain = customer.main != '';
                  var phone = hasMain ? customer.main : customer.mobile;
                  UrlLauncher.launch("tel:" + phone);
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
