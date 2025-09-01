class UserData {
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String email;
  final DateTime registrationDate;

  UserData({
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.email,
    required this.registrationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'email': email,
      'registration_date': registrationDate.toIso8601String(),
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      height: map['height']?.toDouble() ?? 0.0,
      weight: map['weight']?.toDouble() ?? 0.0,
      email: map['email'] ?? '',
      registrationDate: DateTime.parse(map['registration_date'] ?? DateTime.now().toIso8601String()),
    );
  }
}