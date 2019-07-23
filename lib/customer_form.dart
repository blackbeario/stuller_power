// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './models/customer.dart';
import './db_service.dart';
// import 'package:mobile/ui/elements/cupertino_area_picker.dart';
import 'package:flutter/cupertino.dart';

class CustomerAddEdit extends StatefulWidget {

  final Customer customer;
  const CustomerAddEdit(this.customer);

  @override
  State<StatefulWidget> createState() => _CustomerAddEditState(customer);
}

class _CustomerAddEditState extends State<CustomerAddEdit>{
  final db = DatabaseService();
  final auth = FirebaseAuth.instance;
  // String _area;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cellController = TextEditingController();
  final _emailController = TextEditingController();

  _CustomerAddEditState(Customer customer);

  @override
  void initState() {
    super.initState();
      _firstNameController.text = widget.customer.firstName;
      _lastNameController.text = widget.customer.lastName;
      _phoneController.text = widget.customer.main;
      _cellController.text = widget.customer.mobile;
      _emailController.text = widget.customer.email;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _cellController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _validatePhoneNumber(String value) {
    // _formWasEdited = true;
    final RegExp phoneExp = RegExp(r'^\(\d\d\d\) \d\d\d\-\d\d\d\d$');
    if (!phoneExp.hasMatch(value))
      return '(###) ###-#### - Enter a US phone number.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      navigationBar: CupertinoNavigationBar(
        middle: Text('${widget.customer.firstName}' + ' ' + '${widget.customer.lastName}'),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // First Name input
              TextField(
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                // onChanged: (text) => _customerAddEditBloc.firstNameSink.add(text),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  hintText: 'First name',
                  labelText: 'First name',
                  // errorText: errorSnapshot.data == 0 ? Localization.of(context).firstNameEmpty : null
                ),
                controller: _firstNameController,
              ),

              // Last Name input
              TextField(
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                // onChanged: (text) => _customerAddEditBloc.firstNameSink.add(text),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  hintText: 'Last name',
                  labelText: 'Last name',
                  // errorText: errorSnapshot.data == 0 ? Localization.of(context).firstNameEmpty : null
                ),
                controller: _lastNameController,
              ),

              // Email input
              TextField(
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                // onChanged: (text) => _customerAddEditBloc.firstNameSink.add(text),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  hintText: 'Email',
                  labelText: 'Email',
                  // errorText: errorSnapshot.data == 0 ? Localization.of(context).firstNameEmpty : null
                ),
                controller: _emailController,
              ),
              
              // Main phone input
              TextFormField(
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                // onSaved: (text) => _customerAddEditBloc.phoneSink.add(text),
                validator: _validatePhoneNumber,
                decoration: InputDecoration(
                  icon: Icon(Icons.phone),
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  hintText: 'Main',
                  labelText: 'Main',
                  // errorText: errorSnapshot.data == 0 ? Localization.of(context).phoneEmpty : null
                ),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),

              // Cell input
              TextFormField(
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                // onSaved: (text) => _customerAddEditBloc.phoneSink.add(text),
                validator: _validatePhoneNumber,
                decoration: InputDecoration(
                  icon: Icon(Icons.phone),
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  labelText: 'Cell',
                  hintText: 'Cell',
                  // errorText: errorSnapshot.data == 0 ? Localization.of(context).phoneEmpty : null
                ),
                controller: _cellController,
                keyboardType: TextInputType.phone,
              ),

              // Add some space between sections
              SizedBox(height: 40),

              StreamProvider<List<CustomerLocation>>.value(
                stream: db.streamlocations(widget.customer.id),
                child: LocationWidget(customer: widget.customer),
              ),
            ]
          )
        ),
      ),
    );
  }
}

class LocationWidget extends StatefulWidget {
  LocationWidget({
    Key key,
    @required this.customer,
  }) : super(key: key);

  final Customer customer;
  final db = DatabaseService();

  @override
  State<StatefulWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {

  @override
  Widget build(BuildContext context) {
    var locations = Provider.of<List<CustomerLocation>>(context);

    if (locations == null) {
      return Center(
        child: Text('No locations. Add one for this customer.')
      );
    }

    return ListView(
      shrinkWrap: true,
      children: locations.map((location) {
        bool _billing = location.billing;
        if(locations.length == 1) {
          return LocationForm(location: location, billing: _billing);
        }
        return ExpansionTile(
          initiallyExpanded: false,
          title: Text(location.name.toUpperCase()),
          children: <Widget>[
            LocationForm(location: location, billing: _billing),
          ],
        );
      }).toList(),
    );
  }
}

class LocationForm extends StatefulWidget {
  LocationForm({
    Key key,
    @required this.location,
    @required this.billing,
  }) : super(key: key);

  bool billing;
  final CustomerLocation location;

  @override
  _LocationFormState createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.location.address;
    _cityController.text = widget.location.city;
    _stateController.text = widget.location.state;
    _zipcodeController.text = widget.location.zipcode;
  }

  void _billingChanged(bool value) {
    setState(() => widget.billing = value);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Area filter
            // DropdownButtonFormField(
            //   items: areas.map((String area) {
            //     return new DropdownMenuItem(
            //       value: area,
            //       child: new Text(area),
            //     );
            //   }).toList(),
            //   // onChanged: (newValue) {
            //   //   _customerAddEditBloc.areaSink.add(newValue);
            //   //   setState(() => _area = newValue);
            //   // },
            //   // This needs work to get saved value from Firebase.
            //   value: _area,
            //   decoration: InputDecoration(
            //     contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
            //     filled: true,
            //     fillColor: Colors.grey[200],
            //     hintText: 'Area', 
            //     // errorText: errorSnapshot.data == 0 ? Localization.of(context).areaEmpty : null),
            //   ),
            // ),

            // Billing
            CheckboxListTile(
              value: widget.billing,
              // onChanged: (bool) => _customerAddEditBloc.billingSink.add(bool),
              onChanged: _billingChanged,
              title: new Text('Billing Address?'),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: CupertinoColors.activeBlue,
            ),

            // Address input
            TextField(
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              // onChanged: (text) => _customerAddEditBloc.addressSink.add(text),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                labelText: 'Address',
                hintText: 'Address', 
                // errorText: errorSnapshot.data == 1 ? Localization.of(context).addressEmpty : null
              ),
              controller: _addressController,
            ),

            // City input
            TextField(
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              // onChanged: (text) => _customerAddEditBloc.citySink.add(text),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                labelText: 'City',
                hintText: "City", 
                // errorText: errorSnapshot.data == 0 ? Localization.of(context).cityEmpty : null
              ),
              controller: _cityController,
            ),

            // State input
            TextField(
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              // onChanged: (text) => _customerAddEditBloc.stateSink.add(text),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                labelText: 'State',
                hintText: "State", 
                // errorText: errorSnapshot.data == 0 ? Localization.of(context).stateEmpty : null
                ),
              controller: _stateController,
            ),

            // Zipcode input
            TextField(
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              // onChanged: (text) => _customerAddEditBloc.zipcodeSink.add(text),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                labelText: 'ZipCode',
                hintText: 'Zipcode', 
                // errorText: errorSnapshot.data == 0 ? Localization.of(context).zipcodeEmpty : null
              ),
              controller: _zipcodeController,
            ),
          ],
        ),
    );
  }
}