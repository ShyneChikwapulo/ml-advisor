import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore
      .instance; //creating a session/connection/instance of session to firebase database

  List<String> get favoriteIds => _favoriteIds;

  bool isFavorite(String modelId) {
    //checks if a model is a favorite. if the modelID is found in the favourites ID, the model is a favorite and return true or false if not found
    return _favoriteIds.contains(modelId);
  }

  int get favoritesCount => _favoriteIds
      .length; //return how many favorites a user(current user, not all) has

  Future<void> loadFavorites(String userId) async {
    final doc = await _firestore
        .collection('favorites')
        .doc(userId)
        .get(); //get the documnet of the current user to load their favourites

    if (doc.exists) {
      final data = doc.data()
          as Map<String, dynamic>; //convert json from Firebase to map
      _favoriteIds = List<String>.from(data['favoriteIds'] ?? []);
    } else {
      _favoriteIds = [];
    }

    notifyListeners();
  }

  Future<void> toggleFavorite(String userId, String modelId) async {
    if (isFavorite(modelId)) {
      await _service
          .removeFavorite(modelId); //if already a favourite, remove the heart
    } else {
      await _service.addFavourite(userId,
          modelId); //add the model id to the favourites if it is not a favourite already

      _favoriteIds.add(modelId);
    }

    notifyListeners();
  }
}
