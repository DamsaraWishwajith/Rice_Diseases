class Farmer {
  final int id;
  final String name;
  final String phone;
  final String location;
  final String district;
  final String area;
  final String variety;
  final int scans;
  final String disease;
  final String lastScan;

  Farmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    required this.district,
    required this.area,
    required this.variety,
    required this.scans,
    required this.disease,
    required this.lastScan,
  });

  Farmer copyWith({
    int? id,
    String? name,
    String? phone,
    String? location,
    String? district,
    String? area,
    String? variety,
    int? scans,
    String? disease,
    String? lastScan,
  }) {
    return Farmer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      district: district ?? this.district,
      area: area ?? this.area,
      variety: variety ?? this.variety,
      scans: scans ?? this.scans,
      disease: disease ?? this.disease,
      lastScan: lastScan ?? this.lastScan,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'location': location,
    'district': district,
    'area': area,
    'variety': variety,
    'scans': scans,
    'disease': disease,
    'lastScan': lastScan,
  };

  factory Farmer.fromJson(Map<String, dynamic> json) => Farmer(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
    location: json['location'],
    district: json['district'],
    area: json['area'],
    variety: json['variety'],
    scans: json['scans'],
    disease: json['disease'],
    lastScan: json['lastScan'],
  );
}