import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './models/customer.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';

class CustomerAddEdit extends StatefulWidget {
  final Customer customer;
  const CustomerAddEdit(this.customer);

  @override
  State<StatefulWidget> createState() => _CustomerAddEditState(customer);
}

class _CustomerAddEditState extends State<CustomerAddEdit> {
  final db = DatabaseService();
  final auth = FirebaseAuth.instance;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mainController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  // final _billingController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  List locations = [];
  List<String> locationTypes = <String>['', 'home', 'work', 'billing'];
  String locationType = '';

  _CustomerAddEditState(Customer customer);

  @override
  void initState() {
    super.initState();
    bool $customer = widget.customer != null;
    _firstNameController.text = $customer ? widget.customer.firstName : '';
    _lastNameController.text = $customer ? widget.customer.lastName : '';
    _mainController.text = $customer ? widget.customer.main : '';
    _mobileController.text = $customer ? widget.customer.mobile : '';
    _emailController.text = $customer ? widget.customer.email : '';
    _notesController.text = $customer ? widget.customer.notes : '';
    // _nameController.text = $customer ? widget.customer.locations['primary']['name'] : '';
    // _addressController.text = $customer ? widget.customer.locations['primary']['address'] : '';
    // _areaController.text = $customer ? widget.customer.locations['primary']['area'] : '';
    // _cityController.text = $customer ? widget.customer.locations['primary']['city'] : '';
    // _stateController.text = $customer ? widget.customer.locations['primary']['state'] : '';
    // _zipController.text = $customer ? widget.customer.locations['primary']['zipcode'] : '';
  }

  // Pass LocationForm child class text field values via callback.
  // void locationCallback(
  //   String _name, String _address, String _area,
  //   String _city, String _state, String _zip) {
  //   setState(() {
  //     _nameController.text = _name;
  //     _addressController.text = _address;
  //     _areaController.text = _area;
  //     _cityController.text = _city;
  //     _stateController.text = _state;
  //     _zipController.text = _zip;
  //   });
  // }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mainController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    // locations
    _nameController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
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
    var $name = widget.customer != null
        ? widget.customer.firstName + ' ' + widget.customer.lastName
        : 'New Customer';
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      navigationBar: CupertinoNavigationBar(
        middle: Text($name),
        trailing: CupertinoButton(
            child: Text('Save', style: TextStyle(fontSize: 12)),
            onPressed: () => _updateCustomer(widget.customer, context)),
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
                  TextFormField(
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText: 'First name',
                        labelText: 'First name',
                      ),
                      controller: _firstNameController,
                      keyboardType: TextInputType.text),

                  // Last Name input
                  TextFormField(
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText: 'Last name',
                        labelText: 'Last name',
                      ),
                      controller: _lastNameController,
                      keyboardType: TextInputType.text),

                  // Email input
                  TextFormField(
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText: 'Email',
                        labelText: 'Email',
                      ),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress),

                  // Main phone input
                  TextFormField(
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    validator: _validatePhoneNumber,
                    decoration: InputDecoration(
                      icon: Icon(Icons.phone),
                      contentPadding: EdgeInsets.all(10),
                      hintText: 'Main',
                      labelText: 'Main',
                    ),
                    controller: _mainController,
                    keyboardType: TextInputType.phone,
                  ),

                  // Cell input
                  TextFormField(
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    validator: _validatePhoneNumber,
                    decoration: InputDecoration(
                      icon: Icon(Icons.phone),
                      contentPadding: EdgeInsets.all(10),
                      labelText: 'Mobile',
                      hintText: 'Mobile',
                    ),
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                  ),

                  // Notes input
                  TextFormField(
                    minLines: 2,
                    maxLines: 10,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    decoration: InputDecoration(
                      icon: Icon(Icons.note),
                      contentPadding: EdgeInsets.all(10),
                      labelText: 'Notes',
                      hintText: 'Notes',
                    ),
                    controller: _notesController,
                    keyboardType: TextInputType.text,
                  ),

                  // Add some space between sections
                  SizedBox(height: 40),

                  Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CupertinoButton(
                          // color: CupertinoColors.systemFill,
                          child: Text('+ Address'),
                          onPressed: null,
                          // onPressed: () => addLocation(locations.length),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        // addAutomaticKeepAlives: true,
                        itemCount: locations.length,
                        itemBuilder: (context, index) => _locationWidget(
                          widget.customer,
                          locations[index],
                          locations.length,
                          () => onDelete(index),
                        ),
                      ),
                    ],
                  ),
                ])),
      ),
    );
  }

  /// Add locations widget
  void addLocation(qty) {
    setState(() {
      locations.add(_locationWidget(null, null, null, null));
    });
  }

  void onDelete(int index) {
    setState(() {
      locations.removeAt(index);
    });
  }

  Widget _locationWidget(customer, location, locations, Function onDelete) {
    return ExpansionTile(
      backgroundColor: locations % 2 == 0 ? Colors.grey[50] : Colors.white,
      leading: Icon(CupertinoIcons.location, size: 28),
      initiallyExpanded: true,
      title: Text('New Location',
          style: TextStyle(fontSize: 24, color: Colors.grey[700])),
      trailing: IconButton(
        icon: Icon(CupertinoIcons.delete, size: 28),
        onPressed: () => onDelete(),
      ),
      subtitle: Container(height: 0.0, width: 0.0),
      children: <Widget>[
        Form(
          key: GlobalKey<FormState>(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        labelText: 'Location',
                        hintText: 'Location',
                      ),
                      isEmpty: locationType == '',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: locationType,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              location.type = newValue;
                              locationType = newValue;
                              state.didChange(newValue);
                            });
                          },
                          items: locationTypes.map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),

                // Address input
                TextFormField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    labelText: 'Address',
                    hintText: 'Address',
                  ),
                  keyboardType: TextInputType.text,
                  controller: _addressController,
                ),

                // Area input
                TextFormField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    labelText: 'Area',
                    hintText: 'Area',
                  ),
                  controller: _areaController,
                ),

                // City input
                TextFormField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    labelText: 'City',
                    hintText: "City",
                  ),
                  controller: _cityController,
                ),

                // State input
                TextFormField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    labelText: 'State',
                    hintText: "State",
                  ),
                  controller: _stateController,
                ),

                // Zipcode input
                TextFormField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                    labelText: 'ZipCode',
                    hintText: 'Zipcode',
                  ),
                  controller: _zipController,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> _updateCustomer(customer, BuildContext context) {
    var $id = widget.customer != null
        ? widget.customer.id
        : _firstNameController.text + ' ' + _lastNameController.text;
    Navigator.pop(context);
    db.addUpdateCustomer(
        $id,
        _firstNameController.text,
        _lastNameController.text,
        _emailController.text,
        _mainController.text,
        _mobileController.text,
        _notesController.text,
        // We're not editing them here, but need to pass the job ids with
        // this form so they're not lost on save.
        customer.jobs
        // I have to rework the address form since the db model changed.
        // _nameController.text,
        // _addressController.text,
        // _areaController.text,
        // _cityController.text,
        // _stateController.text,
        // _zipController.text
        );
    return Future.value(false);
  }
}

typedef OnDelete();
