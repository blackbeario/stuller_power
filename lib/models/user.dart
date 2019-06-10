class User {

  final String firstName;
  final String lastName;
  final String role;
  final String phone;

  User({ this.firstName, this.lastName, this.role, this.phone });

  factory User.fromMap(Map data) {
    return User(
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      role: data['role'] ?? '',
      phone: data['phone'] ?? ''
    );
  }
}