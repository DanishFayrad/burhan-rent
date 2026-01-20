class Customer {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String idNumber;
  final String address;
  final String? photoUrl;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.idNumber,
    required this.address,
    this.photoUrl,
    required this.createdAt,
  });

  factory Customer.fromMap(String id, Map<String, dynamic> map) {
    return Customer(
      id: id,
      fullName: map['full_name'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      idNumber: map['id_number'] ?? '',
      address: map['address'] ?? '',
      photoUrl: map['photo_url'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'id_number': idNumber,
      'address': address,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
