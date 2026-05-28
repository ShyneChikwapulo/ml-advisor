import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/model_provider.dart';
import '../utils/app_theme.dart';
import 'model_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final models = context.watch<ModelProvider>().models;
    final auth = context.watch<AuthProvider>();

    final favoriteModels = models.where((m) => favs.isFavorite(m.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favourites'),
      ),
      body: favoriteModels.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No favourites yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on any model to save it',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favoriteModels.length,
              itemBuilder: (_, i) {
                final m = favoriteModels[i];

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0x1A1565C0),
                      child: Icon(
                        Icons.psychology,
                        color: AppTheme.primary,
                      ),
                    ),
                    title: Text(
                      m.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Accuracy: ${(m.accuracy * 100).toStringAsFixed(0)}% · ${m.category}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        if (auth.user != null) {
                          favs.toggleFavorite(
                            auth.user!.uid,
                            m.id,
                          );
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ModelDetailScreen(
                            model: m,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
