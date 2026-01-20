class Rental {
  final String id;
  final String carId;
  final String customerId;
  final DateTime startAt;
  final int durationHours;
  final DateTime createdAt;

  Rental({
    required this.id,
    required this.carId,
    required this.customerId,
    required this.startAt,
    required this.durationHours,
    required this.createdAt,
  });

  factory Rental.fromMap(String id, Map<String, dynamic> map) {
    return Rental(
      id: id,
      carId: map['car_id'] ?? '',
      customerId: map['customer_id'] ?? '',
      startAt: map['start_at'] != null
          ? DateTime.parse(map['start_at'])
          : DateTime.now(),
      durationHours: (map['duration_hours'] ?? 0).toInt(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'car_id': carId,
      'customer_id': customerId,
      'start_at': startAt.toIso8601String(),
      'duration_hours': durationHours,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
