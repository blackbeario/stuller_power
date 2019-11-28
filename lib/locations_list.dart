// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './models/customer.dart';
import './services/db_service.dart';
// import 'package:mobile/ui/elements/cupertino_area_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:date_format/date_format.dart';

class Locations extends StatelessWidget {
  Locations({
    Key key,
    @required this.customer,
  }) : super(key: key);

  final Customer customer;
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    var locations = Provider.of<List<CustomerLocation>>(context);

    if (locations == null) {
      return Text('No locations. Add one for this customer.');
    }

    return ListView(
      shrinkWrap: true,
      children: locations.map((location) {
        bool _billing = location.billing;

        if(locations.length == 1) {
          return LocationTile(
            billing: _billing, customer: customer, location: location
          );
        }
        return ExpansionTile(
          initiallyExpanded: true,
          key: PageStorageKey<CustomerLocation>(location),
          title: Text(location.name.toUpperCase()),
          children: <Widget>[
            LocationTile(billing: _billing, customer: customer, location: location)
          ],
        );
      }).toList(),
    );
    
  }
}

class LocationTile extends StatelessWidget {
  const LocationTile({
    Key key,
    @required bool billing,
    @required this.customer,
    @required this.location,
  }) : _billing = billing, super(key: key);

  final bool _billing;
  final Customer customer;
  final CustomerLocation location;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.location_on, color: CupertinoColors.destructiveRed),
          title: location.address != '?' ? 
            Text(location.address + '\n' + location.city + ' ' + location.state + ', ' + location.zipcode) :  
            Text(
              'Customer has no address in database! Edit this customer to correct address.',
              style: TextStyle(color: CupertinoColors.destructiveRed)
            ),
        ),
        ListTile(
          leading: Icon(_billing ? CupertinoIcons.check_mark : CupertinoIcons.clear),
          title: Text(_billing ? 'Primary Billing' : 'Do Not Bill'),
        ),
        GeneratorTile(customer: customer, location: location),
      ],
    );
  }
}

class GeneratorTile extends StatelessWidget {
  GeneratorTile({
    Key key,
    @required this.customer,
    @required this.location,
  }) : super(key: key);

  final db = DatabaseService();
  final Customer customer;
  final CustomerLocation location;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Generator>(
      future: db.getGenerator(customer.id, location.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return ListTile(
            leading: Icon(Icons.gamepad, color: Colors.orange),
            title: Text('There was an error'),
          );
        }
        else if (snapshot.hasData) {
          return GestureDetector(
            child: Material(
              child: ListTile(
                leading: Image(image: AssetImage('assets/generator.jpg'), height: 20,),
                title: Text('Generator Details'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) {
                return GeneratorDetail(generator: snapshot.data);
              }));
            },
          );
        }
        else {
          return ListTile(
            leading: Icon(Icons.gamepad, color: Colors.orange),
            title: Text('No generator yet'),
          );
        }
      },
    );
  }
}

class GeneratorDetail extends StatelessWidget {
  const GeneratorDetail({
    Key key,
    @required this.generator,
    this.old
    }) : super(key: key);

    final Generator generator;
    final bool old;

  @override
  Widget build(BuildContext context) {
      final _batteryTime = generator.battery != null ? formatDate(generator.battery, [M, ' ', d, ' ', yyyy]) : '';
      final _batteryAge = generator.battery != null ? DateTime.now().difference(generator.battery).inDays : null;
      // Bool is battery older than four years (1460 days)?
      bool _oldBattery = _batteryAge != null ? _batteryAge >= 1460 ? true : false : false;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Generator Details'),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(40,20,40,0),
              leading: Icon(Icons.filter_drama),
              title: Text('Air Filter:'),
              trailing: Text(generator.airFilter),
            ),
            Divider(),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(40,0,40,0),
              leading: _oldBattery ? Icon(Icons.battery_alert, color: Colors.red,) : Icon(Icons.battery_charging_full),
              title: Text('Battery Age:'),
              trailing: _oldBattery ? Text(_batteryTime, style: TextStyle(color: Colors.red)) : Text(_batteryTime),
            ),
            Divider(),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(40,0,40,0),
              leading: Icon(Icons.directions_run),
              title: Text('Excercise Time:'),
              trailing: Text(generator.exerciseTime)
            ),
            Divider(),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(40,0,40,0),
              leading: Icon(Icons.build),
              title: Text('Model:'),
              trailing: Text(generator.model),
            ),
            Divider(),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(40,0,40,0),
              leading: Icon(Icons.format_color_fill),
              title: Text('Oil filter:'),
              trailing: Text(generator.oilFilter)
            ),
            Divider(),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(40,0,40,0),
              leading: Icon(Icons.gamepad),
              title: Text('Serial Number:'),
              trailing: Text(generator.serial),
            ),
            Divider(),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(40,0,40,0),
              leading: Icon(Icons.flash_on),
              title: Text('Spark Plugs:'),
              trailing: Text(generator.sparkPlugs),
            ),
            Divider(),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(40,0,40,0),
              leading: Icon(Icons.swap_vertical_circle),
              title: Text('Xfer Location:'),
              trailing: Text(generator.transferLocation),
            ),
            Divider(),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(40,0,40,0),
              leading: Icon(Icons.swap_vert),
              title: Text('Xfer Serial:'),
              trailing: Text(generator.transferSerial),
            ),
            Divider(),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(40,0,40,0),
              leading: Icon(Icons.lock_outline),
              title: Text('Warranty:'),
              trailing: Text(generator.warranty),
            ),
            Divider(),
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(40,0,40,0),
              leading: Icon(Icons.wifi),
              title: Text('Wifi:'),
              trailing: Text(generator.wifi.toString()),
            ),
          ],
        ),
      ),
    );
  }
}