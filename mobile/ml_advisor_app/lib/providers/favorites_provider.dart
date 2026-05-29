import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<String> _favoriteIds = [];

  List<String> get favoriteIds => _favoriteIds;

  bool isFavorite(String modelId) => _favoriteIds.contains(modelId);

  Future<void> loadFavorites(String userId) async {
    _favoriteIds = await _service.getFavorites(userId);
    notifyListeners();
  }

  Future<void> toggleFavorite(String userId, String modelId) async {
    if (isFavorite(modelId)) {
      await _service.removeFavorite(userId, modelId);
      _favoriteIds.remove(modelId);
    } else {
      await _service.addFavorite(userId, modelId);
      _favoriteIds.add(modelId);
    }
    notifyListeners();
  }

  void clear() {
    _favoriteIds = [];
    notifyListeners();
  }
}