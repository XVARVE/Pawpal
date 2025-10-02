import 'package:firebase_database/firebase_database.dart';

class RTDBService {
  static final db = FirebaseDatabase.instance.ref();

  // ---------- VETS ----------
  static Future<String> addVet(Map<String, dynamic> vet) async {
    final ref = db.child('vets').push();
    await ref.set({
      ...vet,
      'nameLower': vet['name']?.toString().toLowerCase() ?? '',
      'createdAt': ServerValue.timestamp,
    });
    return ref.key!;
  }

  static Stream<DatabaseEvent> latestVets({int limit = 20}) {
    return db
        .child('vets')
        .orderByChild('createdAt')
        .limitToLast(limit)
        .onValue;
  }

  static Future<DataSnapshot> getVet(String id) {
    return db.child('vets/$id').get();
  }

  static Query searchVets(String query) {
    final lower = query.toLowerCase();
    return db
        .child('vets')
        .orderByChild('nameLower')
        .startAt(lower)
        .endAt('$lower\uf8ff');
  }

  static Query filterVets(Map<String, String> filters) {
    Query q = db.child('vets');
    filters.forEach((key, value) {
      if (value.isNotEmpty && value != 'All') {
        q = q.orderByChild(key).equalTo(value);
      }
    });
    return q;
  }

  // ---------- PETS ----------
  static Future<String> addPet(Map<String, dynamic> pet) async {
    final ref = db.child('pets').push();
    await ref.set({
      ...pet,
      'nameLower': pet['name']?.toString().toLowerCase() ?? '',
      'createdAt': ServerValue.timestamp,
    });
    return ref.key!;
  }

  static Stream<DatabaseEvent> latestPets({int limit = 10}) {
    return db.child('pets').orderByChild('createdAt').limitToLast(limit).onValue;
  }

  static Future<DataSnapshot> getPet(String id) {
    return db.child('pets/$id').get();
  }

  static Query searchPets(String query) {
    final lower = query.toLowerCase();
    return db
        .child('pets')
        .orderByChild('nameLower')
        .startAt(lower)
        .endAt('$lower\uf8ff');
  }

  static Query filterPets(Map<String, String> filters) {
    Query q = db.child('pets');
    filters.forEach((key, value) {
      if (value.isNotEmpty && value != 'All') {
        q = q.orderByChild(key).equalTo(value);
      }
    });
    return q;
  }

  // ---------- PRODUCTS ----------
  static Future<String> addProduct(Map<String, dynamic> product) async {
    final ref = db.child('products').push();
    await ref.set({
      ...product,
      'nameLower': product['name']?.toString().toLowerCase() ?? '',
      'createdAt': ServerValue.timestamp,
    });
    return ref.key!;
  }

  static Stream<DatabaseEvent> latestProducts({int limit = 20}) {
    return db
        .child('products')
        .orderByChild('createdAt')
        .limitToLast(limit)
        .onValue;
  }

  static Future<DataSnapshot> getProduct(String id) {
    return db.child('products/$id').get();
  }

  static Query searchProducts(String query) {
    final lower = query.toLowerCase();
    return db
        .child('products')
        .orderByChild('nameLower')
        .startAt(lower)
        .endAt('$lower\uf8ff');
  }
  // ---------- USERS ----------
  static Future<void> createUserProfile({
    required String uid,
    required Map<String, dynamic> profile,
  }) async {
    final name = (profile['name'] ?? '').toString();
    final email = (profile['email'] ?? '').toString();
    await db.child('users/$uid').set({
      ...profile,
      'nameLower': name.toLowerCase(),
      'emailLower': email.toLowerCase(),
      'createdAt': ServerValue.timestamp,
    });
  }

  static Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    if (data.containsKey('name')) {
      data['nameLower'] = (data['name'] ?? '').toString().toLowerCase();
    }
    if (data.containsKey('email')) {
      data['emailLower'] = (data['email'] ?? '').toString().toLowerCase();
    }
    await db.child('users/$uid').update(data);
  }

  static Future<DataSnapshot> getUserProfile(String uid) {
    return db.child('users/$uid').get();
  }

  static Stream<DatabaseEvent> watchUserProfile(String uid) {
    return db.child('users/$uid').onValue;
  }

  /// Call after sign-in with any provider to ensure the profile exists.
  static Future<void> ensureUserProfile({
    required String uid,
    required String name,
    required String email,
    String? phone,
    String? photoUrl,
  }) async {
    final snap = await db.child('users/$uid').get();
    if (!snap.exists) {
      await createUserProfile(uid: uid, profile: {
        'name': name,
        'email': email,
        'phone': phone ?? '',
        'photoUrl': photoUrl ?? '',
        'city': '',
        'address': '',
      });
    }
  }

}
