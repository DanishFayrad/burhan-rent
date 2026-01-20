class Car {
  final String id;
  final String name;
  final String registrationNumber;
  final double rentPricePerDay;
  final bool available;
  final String? imageUrl;
  final DateTime createdAt;

  // New Fields
  final String transmission; // 'Automatic' or 'Manual'
  final int seatingCapacity;
  final String fuelType; // 'Petrol', 'Diesel', 'Hybrid', 'Electric'

  Car({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.rentPricePerDay,
    required this.available,
    this.imageUrl,
    required this.createdAt,
    this.transmission = 'Automatic',
    this.seatingCapacity = 4,
    this.fuelType = 'Petrol',
  });

  factory Car.fromMap(String id, Map<String, dynamic> map) {
    return Car(
      id: id,
      name: map['name'] ?? '',
      registrationNumber: map['registration_number'] ?? '',
      rentPricePerDay: (map['rent_price_per_day'] ?? 0).toDouble(),
      available: map['available'] ?? true,
      imageUrl: map['image_url'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      transmission: map['transmission'] ?? 'Automatic',
      seatingCapacity: map['seating_capacity'] ?? 4,
      fuelType: map['fuel_type'] ?? 'Petrol',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'registration_number': registrationNumber,
      'rent_price_per_day': rentPricePerDay,
      'available': available,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'transmission': transmission,
      'seating_capacity': seatingCapacity,
      'fuel_type': fuelType,
    };
  }
}
