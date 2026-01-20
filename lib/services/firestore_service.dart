import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/car.dart';
import '../models/customer.dart';
import '../models/rental.dart';

class FirestoreService {
  final SupabaseClient _client = Supabase.instance.client;

  // Cars
  Stream<List<Car>> carsStream() {
    return _client
        .from('cars')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (data) => data.map((json) => Car.fromMap(json['id'], json)).toList(),
        );
  }

  Future<Car?> getCar(String id) async {
    final data = await _client.from('cars').select().eq('id', id).maybeSingle();
    if (data != null) {
      return Car.fromMap(data['id'], data);
    }
    return null;
  }

  Future<void> addCar(Map<String, dynamic> data) async {
    // Map keys are likely camelCase from UI, need to converting if not handled by Model toMap
    // Since UI likely calls car.toMap() or passes specific map
    // We expect the map to be compatible or we use the Model helper if possible.
    // However, the original code passed a Map.
    // Let's assume the UI passes a map with keys matching the model or just raw values.
    // Ideally we should accept a Car object, but to keep signature:
    // We'll rely on the fact that we changed the keys in Model.toMap/fromMap.
    // IF the UI constructs the map manually, we might have issues.
    // checking usage in next step. For now, just pass data.
    // Supabase expects snake_case keys if that is the schema.
    await _client.from('cars').insert(data);
  }

  Future<void> updateCar(String id, Map<String, dynamic> data) async {
    await _client.from('cars').update(data).eq('id', id);
  }

  Future<void> setCarAvailable(String id, bool available) async {
    await _client.from('cars').update({'available': available}).eq('id', id);
  }

  // Customers
  Future<String> addCustomer(Map<String, dynamic> data) async {
    final res = await _client.from('customers').insert(data).select().single();
    return res['id'];
  }

  Future<Customer?> getCustomer(String id) async {
    final data = await _client
        .from('customers')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data != null) {
      return Customer.fromMap(data['id'], data);
    }
    return null;
  }

  // Rentals
  Future<String> addRental(Map<String, dynamic> data) async {
    final res = await _client.from('rentals').insert(data).select().single();
    return res['id'];
  }

  Stream<List<Rental>> rentalsStream() {
    return _client
        .from('rentals')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (data) =>
              data.map((json) => Rental.fromMap(json['id'], json)).toList(),
        );
  }

  Future<List<Rental>> getCustomerRentals(String customerId) async {
    final data = await _client
        .from('rentals')
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((json) => Rental.fromMap(json['id'], json))
        .toList();
  }

  Future<Rental?> getRental(String id) async {
    final data = await _client
        .from('rentals')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data != null) {
      return Rental.fromMap(data['id'], data);
    }
    return null;
  }

  Future<List<Customer>> getAllCustomers() async {
    final data = await _client
        .from('customers')
        .select()
        .order('created_at', ascending: false);
    return (data as List)
        .map((json) => Customer.fromMap(json['id'], json))
        .toList();
  }

  Future<void> deleteCustomer(String id) async {
    await _client.from('customers').delete().eq('id', id);
  }

  Future<void> deleteRental(String id) async {
    await _client.from('rentals').delete().eq('id', id);
  }

  Future<void> deleteCar(String id) async {
    await _client.from('cars').delete().eq('id', id);
  }
}
