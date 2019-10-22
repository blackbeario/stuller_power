import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String category;
  final String customer;
  final String description;
  final bool done;
  final DateTime created;
  final DateTime scheduled;
  final DateTime started;
  final DateTime ended;
  final String techID;
  final String title;
  final List<String> notes;

  Job({ this.id, this.category, this.customer, this.created, this.scheduled, this.description, this.done, this.started, this.ended, this.techID, this.title, this.notes });

  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Job(
      id: doc.documentID,
      category: data['category'] ?? '',
      customer: data['customer'] ?? '',
      created: data['created'] != null ? DateTime.fromMillisecondsSinceEpoch(data['created']) : null,
      scheduled: data['scheduled'] != null ? DateTime.fromMillisecondsSinceEpoch(data['scheduled']) : null,
      description: data['description'] ?? '',
      done: data['done'] ?? true,
      started: data['started'] != null ? DateTime.fromMillisecondsSinceEpoch(data['started']) : null,
      ended: data['ended'] != null ? DateTime.fromMillisecondsSinceEpoch(data['ended']) : null,
      techID: data['techID'] ?? '',
      title: data['title'] ?? '',
      notes: List.from(data['notes']) ?? null
    );
  }

  Map<String, dynamic> toJson() =>
    {
      'done' : done,
      'category' : category,
      'customer' : customer,
      'created' : created?.millisecondsSinceEpoch,
      'scheduled' : scheduled?.millisecondsSinceEpoch,
      'started' : started?.millisecondsSinceEpoch,
      'ended' : ended?.millisecondsSinceEpoch,
      'title' : title,
      'description' : description,
      'techID' : techID,
      'notes' : notes
    };
}