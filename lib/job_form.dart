// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './models/customer.dart';
import './models/job.dart';
import './services/db_service.dart';
import 'package:flutter/cupertino.dart';

class JobAddEdit extends StatefulWidget {
  final Job job;
  const JobAddEdit(this.job);

  @override
  State<StatefulWidget> createState() => _JobAddEditState(job);
}

class _JobAddEditState extends State<JobAddEdit>{
  final db = DatabaseService();
  final auth = FirebaseAuth.instance;
  final _categoryController = TextEditingController();
  final _customerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _techController = TextEditingController();
  final _titleController = TextEditingController();

  _JobAddEditState(Job job);

  @override
  void initState() {
    super.initState();
      _categoryController.text = widget.job.category;
      _customerController.text = widget.job.customer;
      _descriptionController.text = widget.job.description;
      _notesController.text = widget.job.notes;
      _techController.text = widget.job.techID;
      _titleController.text = widget.job.title;
  }

  // Resets customer list from child widget action.
  void callback(setAssigned) {
    setState(() {
      _customerController.text = setAssigned;
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _customerController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _techController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var customers = Provider.of<List<Customer>>(context);
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.job.title != null ? '${widget.job.title}' : 'Add Job'),
        trailing: CupertinoButton(
          child: Text('Save', style: TextStyle(fontSize: 12)),
          onPressed: () => _updateJob(widget.job, context)
        ),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // title
                TextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    hintText: 'title',
                    labelText: 'title',
                  ),
                  controller: _titleController,
                  keyboardType: TextInputType.text
                ),
  
                // category
                TextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    hintText: 'category',
                    labelText: 'category',
                  ),
                  controller: _categoryController,
                  keyboardType: TextInputType.text
                ),

                // description
                TextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    hintText: 'description',
                    labelText: 'description',
                  ),
                  controller: _descriptionController,
                  keyboardType: TextInputType.text
                ),

                // Notes input
                TextField(
                  minLines: 2,
                  maxLines: 10,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    icon: Icon(Icons.note),
                    contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    labelText: 'Notes',
                    hintText: 'Notes',
                  ),
                  controller: _notesController,
                  keyboardType: TextInputType.multiline,
                ),
                            
                // techID
                TextField(
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    hintText: 'techID',
                    labelText: 'techID',
                  ),
                  controller: _techController,
                  keyboardType: TextInputType.text
                ),

                // Customer search field
                CustomerSearchWidget(
                  assigned: _customerController.text != null ? _customerController.text : widget.job.customer.toString(), 
                  customers: customers,
                  callback: callback
                ),
            ]
          )
        ),
      ),
    );
  }

  Future<bool> _updateJob(customer, BuildContext context) {
    Navigator.pop(context);
    db.updateJob(
      widget.job.id, _categoryController.text, _customerController.text, 
      _descriptionController.text, _techController.text, _titleController.text,
      _notesController.text
    );
    return Future.value(false);
  }
}

class CustomerSearchWidget extends StatefulWidget {
  CustomerSearchWidget({
    Key key,
    this.assigned,
    this.customers,
    this.callback
  }) : super(key: key);

  var assigned;
  final Function callback;
  // The original stream of customers.
  List<Customer> customers = List();
  @override
  State<StatefulWidget> createState() => _CustomerSearchWidgetState();
}

class _CustomerSearchWidgetState extends State<CustomerSearchWidget> {
  static List<Customer> filteredCustomers = List();
  bool _searchVisible = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      filteredCustomers = widget.customers;
    });
  }

  void _changed(bool visibility, String field) {
    setState(() {
      if (field == "Customer search") {
        _searchVisible = visibility;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (filteredCustomers == null) {
      return Center(
        child: CupertinoActivityIndicator(
          animating: true,
          radius: 18.0,
        )
      );
    }
    return Container(
      height: _searchVisible ? 300 : 80,
      decoration: new BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
                        placeholder: widget.assigned != null ? widget.assigned : 'Select customer',
                        onChanged: (string) {
                          setState(() {
                            filteredCustomers = widget.customers
                              .where((customer) => (
                                customer.firstName
                                  .toLowerCase()
                                  .contains(string.toLowerCase()) ||
                                customer.lastName
                                  .toLowerCase()
                                  .contains(string.toLowerCase()) ||
                                customer.email
                                  .toLowerCase()
                                  .contains(string.toLowerCase())
                                )
                              ).toList();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: CupertinoButton(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(
                          CupertinoIcons.clear,
                          size: 44,
                        ),
                        onPressed: () {
                          _changed(false, "Customer search");
                          filteredCustomers = widget.customers;
                        },
                      ),
                    )
                  ])
              : Row(
                  children: <Widget>[
                    Expanded(
                      child: ListTile(
                        title: Text('Customer'),
                        subtitle: Text(
                          widget.assigned != null ? widget.assigned : 'select customer', style: TextStyle(fontSize: 18)
                        ),
                        // color: Colors.yellow,
                        trailing: CupertinoButton(
                          borderRadius: BorderRadius.zero,
                          padding: EdgeInsets.fromLTRB(340.0, 0, 20, 0),
                          // color: Colors.grey,
                          child: Icon(CupertinoIcons.search),
                          onPressed: () {
                            _changed(true, "Customer search");
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              // Search results
              _searchVisible ? Expanded(
                child: ListView.separated(
                  itemCount: filteredCustomers.length,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    return Divider(height: 0);
                  },
                  itemBuilder: (context, index) {
                    if (index < filteredCustomers.length) {
                      return Material(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              widget.assigned = filteredCustomers[index].firstName + ' ' + filteredCustomers[index].lastName;
                              widget.callback(widget.assigned);
                              _changed(false, "Customer search");
                            });
                          },
                          child: ListTile(
                            leading: Icon(Icons.person, color: Colors.red),
                            title: Text(filteredCustomers[index].firstName + ' ' + filteredCustomers[index].lastName),
                          ),
                        ),
                      );
                    }
                    return Text('loading...');
                  }
                ),
              ) : Container(),
        ],
      ),
    );

  }
}