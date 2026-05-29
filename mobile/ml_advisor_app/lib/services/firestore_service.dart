import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ml_model.dart';
import '../models/paper_model.dart';
import '../models/glossary_model.dart';

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

  // ── Analytics ────────────────────────────────────────────
  Future<Map<String, int>> getAnalytics() async {
    final results = await Future.wait([
      _db.collection('models').count().get(),
      _db.collection('papers').count().get(),
      _db.collection('glossary').count().get(),
      _db.collection('users').count().get(),
    ]);
    return {
      'models': results[0].count ?? 0,
      'papers': results[1].count ?? 0,
      'glossary': results[2].count ?? 0,
      'users': results[3].count ?? 0,
    };
  }
}