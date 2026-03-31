class Supervisor {
  final String username;
  final String email;
  final String district;

  Supervisor({
    required this.username,
    required this.email,
    required this.district,
  });

  factory Supervisor.fromJson(Map<String, dynamic> json) {
    return Supervisor(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      district: json['district'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'district': district,
    };
  }
}