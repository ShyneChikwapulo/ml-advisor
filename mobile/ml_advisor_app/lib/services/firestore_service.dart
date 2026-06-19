import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ml_model.dart';
import '../models/paper_model.dart';
import '../models/glossary_model.dart';
import '../models/user_model.dart'; // 👈 ADD THIS LINE

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ── Models ──────────────────────────────────────────────
  Future<List<MlModel>> getModels() async {
    final snap = await _db.collection('models').get();
    return snap.docs
        .map((d) => MlModel.fromJson({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<void> addModel(MlModel model) =>
      _db.collection('models').add(model.toJson());

  Future<void> updateModel(String id, MlModel model) =>
      _db.collection('models').doc(id).update(model.toJson());

  Future<void> deleteModel(String id) =>
      _db.collection('models').doc(id).delete();

  // ── Favorites ────────────────────────────────────────────
  Future<List<String>> getFavorites(String userId) async {
    final snap = await _db
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .get();
    return snap.docs.map((d) => d['modelId'] as String).toList();
  }

  Future<void> addFavorite(String userId, String modelId) =>
      _db.collection('favorites').add({
        'userId': userId,
        'modelId': modelId,
        'savedAt': FieldValue.serverTimestamp(),
      });

  Future<void> removeFavorite(String userId, String modelId) async {
    final snap = await _db
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('modelId', isEqualTo: modelId)
        .get();

    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ── Papers ───────────────────────────────────────────────
  Future<List<PaperModel>> getPapers() async {
    final snap = await _db.collection('papers').get();
    return snap.docs
        .map((d) => PaperModel.fromJson({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<void> addPaper(PaperModel paper) =>
      _db.collection('papers').add(paper.toJson());

  Future<void> deletePaper(String id) =>
      _db.collection('papers').doc(id).delete();

  Future<void> updatePaper(String id, PaperModel paper) async {
    await _db.collection('papers').doc(id).update(paper.toJson());
  }

  // ── Glossary ─────────────────────────────────────────────
  Future<List<GlossaryTerm>> getGlossary() async {
    final snap = await _db.collection('glossary').get();
    return snap.docs
        .map((d) => GlossaryTerm.fromJson({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<void> addGlossaryTerm(GlossaryTerm term) =>
      _db.collection('glossary').add(term.toJson());

  Future<void> deleteGlossaryTerm(String id) =>
      _db.collection('glossary').doc(id).delete();

  Future<void> updateGlossaryTerm(String id, GlossaryTerm term) async {
    await _db.collection('glossary').doc(id).update(term.toJson());
  }

  // ── Analytics ────────────────────────────────────────────
  Future<Map<String, int>> getAnalytics() async {
    final results = await Future.wait([
      _db.collection('models').get(),
      _db.collection('papers').get(),
      _db.collection('glossary').get(),
      _db.collection('users').get(),
    ]);

    return {
      'models': results[0].docs.length,
      'papers': results[1].docs.length,
      'glossary': results[2].docs.length,
      'users': results[3].docs.length,
    };
  }

  // 🌟 NEW: Pulls chronological entries ordered by monthIndex for the multi-series line chart
  Future<List<Map<String, dynamic>>> getHistoricalAnalytics() async {
    final snapshot = await _db
        .collection('analytics_history')
        .orderBy('monthIndex')
        .get();
        
    return snapshot.docs.map((doc) => doc.data()).toList();
  }


// ── Users ────────────────────────────────────────────────
  Future<List<UserModel>> getUsers() async {
    final snap = await _db.collection('users').get();
    return snap.docs
        .map((d) => UserModel.fromJson({'uid': d.id, ...d.data()}))
        .toList();
  }

  Future<void> addUser(UserModel user) =>
     _db.collection('users').add(user.toMap());

  Future<void> updateUser(String uid, UserModel user) =>
      _db.collection('users').doc(uid).update(user.toMap());

  Future<void> deleteUser(String uid) =>
      _db.collection('users').doc(uid).delete();

      

  // ── Document Reference Resolution ────────────────────────
  Future<PaperModel?> getPaperById(String id) async {
    if (id.isEmpty) return null;
    try {
      final doc = await _db.collection('papers').doc(id).get();
      if (!doc.exists) return null;
      return PaperModel.fromJson({'id': doc.id, ...?doc.data()});
    } catch (e) {
      return null;
    }
  }

  // ── Models (Add this right below your traditional getModels function) ──
  Stream<List<MlModel>> streamModels() {
    return _db.collection('models').snapshots().map((snapshot) {
      return snapshot.docs
          .map((d) => MlModel.fromJson({'id': d.id, ...d.data()}))
          .toList();
    });
  }

}